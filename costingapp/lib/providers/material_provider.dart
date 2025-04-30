import 'package:flutter/foundation.dart';
import '../models/material_model.dart';
import '../repositories/materials_repository.dart';
import '../services/barcode_service.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialsRepository _repository = MaterialsRepository();
  final BarcodeService _barcodeService = BarcodeService();

  List<MaterialModel> _materials = [];
  MaterialModel? _scannedMaterial;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MaterialModel> get materials => _materials;
  MaterialModel? get scannedMaterial => _scannedMaterial;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MaterialModel> get lowStockMaterials =>
      _materials.where((material) => material.isLowStock).toList();

  MaterialProvider() {
    _initialize();
  }

  // Initialize provider
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.initialize();

      // Listen to materials stream
      _repository.materialsStream.listen((materials) {
        _materials = materials;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error initializing materials: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Scan barcode and fetch material
  Future<void> scanAndFetchMaterial() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Scan barcode
      final barcode = await _barcodeService.scanBarcode();

      if (barcode == null) {
        _error = 'Scanning canceled';
        _scannedMaterial = null;
      } else {
        // Fetch material by barcode
        final material = await _repository.getMaterialByBarcode(barcode);

        if (material == null) {
          _error = 'No material found with barcode: $barcode';
          _scannedMaterial = null;
        } else {
          _scannedMaterial = material;
        }
      }
    } catch (e) {
      _error = 'Error scanning barcode: $e';
      _scannedMaterial = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Log material usage (reduce stock)
  Future<void> logMaterialUsage({
    required String materialId,
    required double quantity,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find material in list
      final materialIndex = _materials.indexWhere((m) => m.id == materialId);

      if (materialIndex == -1) {
        _error = 'Material not found';
      } else {
        final material = _materials[materialIndex];
        final newQuantity = material.stockQuantity - quantity;

        if (newQuantity < 0) {
          _error = 'Not enough stock available';
        } else {
          // Update stock in repository
          await _repository.updateStock(materialId, newQuantity);

          // Update local cached material if it's the scanned one
          if (_scannedMaterial?.id == materialId) {
            _scannedMaterial = _scannedMaterial!.copyWith(
              stockQuantity: newQuantity,
              isLowStock: newQuantity <= _scannedMaterial!.minStockThreshold,
            );
          }
        }
      }
    } catch (e) {
      _error = 'Error logging material usage: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new material
  Future<void> addMaterial(MaterialModel material) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addMaterial(material);
    } catch (e) {
      _error = 'Error adding material: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update material
  Future<void> updateMaterial(MaterialModel material) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateMaterial(material);

      // Update scanned material if it's the same one
      if (_scannedMaterial?.id == material.id) {
        _scannedMaterial = material;
      }
    } catch (e) {
      _error = 'Error updating material: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete material
  Future<void> deleteMaterial(String materialId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteMaterial(materialId);

      // Clear scanned material if it's the deleted one
      if (_scannedMaterial?.id == materialId) {
        _scannedMaterial = null;
      }
    } catch (e) {
      _error = 'Error deleting material: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force sync with Firebase
  Future<void> syncWithFirebase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.syncWithFirebase();
    } catch (e) {
      _error = 'Error syncing with Firebase: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear scanned material
  void clearScannedMaterial() {
    _scannedMaterial = null;
    notifyListeners();
  }

  // Generate QR codes for materials
  Future<List<MaterialModel>> generateQRCodesForMaterials(
    List<String> materialIds,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final selectedMaterials =
          _materials
              .where((material) => materialIds.contains(material.id))
              .toList();

      return selectedMaterials;
    } catch (e) {
      _error = 'Error generating QR codes: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
