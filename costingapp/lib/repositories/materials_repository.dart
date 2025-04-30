import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/material_model.dart';

class MaterialsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<Map> _materialsBox;
  final String _collectionName = 'materials';

  // Stream controllers
  final _materialsStreamController =
      StreamController<List<MaterialModel>>.broadcast();
  Stream<List<MaterialModel>> get materialsStream =>
      _materialsStreamController.stream;

  // Connectivity status
  bool _isConnected = true;
  StreamSubscription? _connectivitySubscription;

  // Queue of operations to perform when back online
  final List<Map<String, dynamic>> _pendingOperations = [];

  // Initialize repository
  Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(MaterialModelAdapter());

    // Open box
    _materialsBox = await Hive.openBox<Map>('materials');

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      _isConnected = result != ConnectivityResult.none;

      if (_isConnected) {
        await _syncWithFirebase();
      }
    });

    // Initial connectivity check
    final connectivityResult = await Connectivity().checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;

    // Set up Firestore listener if online
    if (_isConnected) {
      _setupFirestoreListener();
    } else {
      // Load from local storage
      _loadMaterialsFromLocal();
    }
  }

  // Setup Firestore listener
  void _setupFirestoreListener() {
    _firestore
        .collection(_collectionName)
        .snapshots()
        .listen(
          (snapshot) async {
            final materials =
                snapshot.docs
                    .map((doc) => MaterialModel.fromFirestore(doc))
                    .toList();

            // Update local cache
            await _updateLocalCache(materials);

            // Update stream
            _materialsStreamController.add(materials);
          },
          onError: (error) {
            // On error, load from local storage
            _loadMaterialsFromLocal();
          },
        );
  }

  // Load materials from local cache
  void _loadMaterialsFromLocal() {
    final materials =
        _materialsBox.values
            .map(
              (map) =>
                  MaterialModel.fromMap(Map<String, dynamic>.from(map as Map)),
            )
            .toList();

    _materialsStreamController.add(materials);
  }

  // Update local cache with materials from Firestore
  Future<void> _updateLocalCache(List<MaterialModel> materials) async {
    // Clear existing cache
    await _materialsBox.clear();

    // Add all materials to cache
    for (final material in materials) {
      await _materialsBox.put(material.id, material.toMap());
    }
  }

  // Sync pending operations with Firebase
  Future<void> _syncWithFirebase() async {
    if (_pendingOperations.isEmpty) return;

    // Process all pending operations
    for (final operation in _pendingOperations) {
      final type = operation['type'] as String;
      final material = MaterialModel.fromMap(operation['material']);

      switch (type) {
        case 'add':
          await _addToFirebase(material);
          break;
        case 'update':
          await _updateInFirebase(material);
          break;
        case 'delete':
          await _deleteFromFirebase(material.id);
          break;
      }
    }

    // Clear pending operations
    _pendingOperations.clear();

    // Refresh local cache
    final snapshot = await _firestore.collection(_collectionName).get();
    final materials =
        snapshot.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList();

    await _updateLocalCache(materials);

    // Update stream
    _materialsStreamController.add(materials);
  }

  // Add material to Firebase
  Future<void> _addToFirebase(MaterialModel material) async {
    await _firestore
        .collection(_collectionName)
        .doc(material.id)
        .set(material.toFirestore());
  }

  // Update material in Firebase
  Future<void> _updateInFirebase(MaterialModel material) async {
    await _firestore
        .collection(_collectionName)
        .doc(material.id)
        .update(material.toFirestore());
  }

  // Delete material from Firebase
  Future<void> _deleteFromFirebase(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  // PUBLIC METHODS

  // Get material by barcode
  Future<MaterialModel?> getMaterialByBarcode(String barcode) async {
    try {
      // Try to find in local cache first
      final materials =
          _materialsBox.values
              .map(
                (map) => MaterialModel.fromMap(
                  Map<String, dynamic>.from(map as Map),
                ),
              )
              .where((m) => m.barcode == barcode)
              .toList();

      if (materials.isNotEmpty) {
        final localMaterial = materials.first;
        return localMaterial;
      }

      // If not found locally and online, check Firebase
      if (_isConnected) {
        final snapshot =
            await _firestore
                .collection(_collectionName)
                .where('barcode', isEqualTo: barcode)
                .limit(1)
                .get();

        if (snapshot.docs.isNotEmpty) {
          final material = MaterialModel.fromFirestore(snapshot.docs.first);

          // Cache the result
          await _materialsBox.put(material.id, material.toMap());

          return material;
        }
      }

      return null;
    } catch (e) {
      print('Error getting material by barcode: $e');
      return null;
    }
  }

  // Add new material
  Future<void> addMaterial(MaterialModel material) async {
    // Save locally
    await _materialsBox.put(material.id, material.toMap());

    // Add to online if connected
    if (_isConnected) {
      await _addToFirebase(material);
    } else {
      // Add to pending operations
      _pendingOperations.add({'type': 'add', 'material': material.toMap()});
    }

    // Refresh local materials
    _loadMaterialsFromLocal();
  }

  // Update material
  Future<void> updateMaterial(MaterialModel material) async {
    // Update locally
    await _materialsBox.put(
      material.id,
      material
          .copyWith(lastUpdated: DateTime.now(), isSynced: _isConnected)
          .toMap(),
    );

    // Update online if connected
    if (_isConnected) {
      await _updateInFirebase(material);
    } else {
      // Add to pending operations
      _pendingOperations.add({'type': 'update', 'material': material.toMap()});
    }

    // Refresh local materials
    _loadMaterialsFromLocal();
  }

  // Delete material
  Future<void> deleteMaterial(String id) async {
    // Delete locally
    await _materialsBox.delete(id);

    // Delete online if connected
    if (_isConnected) {
      await _deleteFromFirebase(id);
    } else {
      // Get material data for pending operation
      final material = _materialsBox.get(id);

      // Add to pending operations
      if (material != null) {
        _pendingOperations.add({'type': 'delete', 'material': material});
      }
    }

    // Refresh local materials
    _loadMaterialsFromLocal();
  }

  // Update stock quantity
  Future<void> updateStock(String id, double newQuantity) async {
    // Get current material
    final materialMap = _materialsBox.get(id);

    if (materialMap != null) {
      final material = MaterialModel.fromMap(
        Map<String, dynamic>.from(materialMap as Map),
      );

      // Create updated material
      final updatedMaterial = material.copyWith(
        stockQuantity: newQuantity,
        lastUpdated: DateTime.now(),
        isLowStock: newQuantity <= material.minStockThreshold,
        isSynced: _isConnected,
      );

      // Update material
      await updateMaterial(updatedMaterial);
    }
  }

  // Get all materials that are low in stock
  List<MaterialModel> getLowStockMaterials() {
    return _materialsBox.values
        .map(
          (map) => MaterialModel.fromMap(Map<String, dynamic>.from(map as Map)),
        )
        .where((material) => material.isLowStock)
        .toList();
  }

  // Force sync with Firebase
  Future<void> syncWithFirebase() async {
    if (_isConnected) {
      await _syncWithFirebase();
    }
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _materialsStreamController.close();
  }
}

// Create a Hive adapter for MaterialModel
class MaterialModelAdapter extends TypeAdapter<MaterialModel> {
  @override
  final int typeId = 1;

  @override
  MaterialModel read(BinaryReader reader) {
    final map = reader.readMap();
    return MaterialModel.fromMap(Map<String, dynamic>.from(map as Map));
  }

  @override
  void write(BinaryWriter writer, MaterialModel obj) {
    writer.writeMap(obj.toMap());
  }
}
