import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

part 'material_model.g.dart';

@HiveType(typeId: 1)
class MaterialModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double unitCost;

  @HiveField(3)
  final String unitType; // kg, liter, piece, etc.

  @HiveField(4)
  final double stockQuantity;

  @HiveField(5)
  final double minStockThreshold;

  @HiveField(6)
  final String barcode;

  @HiveField(7)
  final DateTime lastUpdated;

  @HiveField(8)
  final String category;

  @HiveField(9)
  final String? supplierId;

  @HiveField(10)
  final bool isLowStock;

  @HiveField(11)
  final bool isSynced; // To track if this record is synced with Firebase

  MaterialModel({
    String? id,
    required this.name,
    required this.unitCost,
    required this.unitType,
    required this.stockQuantity,
    required this.minStockThreshold,
    required this.barcode,
    DateTime? lastUpdated,
    required this.category,
    this.supplierId,
    bool? isLowStock,
    bool? isSynced,
  }) : this.id = id ?? const Uuid().v4(),
       this.lastUpdated = lastUpdated ?? DateTime.now(),
       this.isLowStock = isLowStock ?? stockQuantity <= minStockThreshold,
       this.isSynced = isSynced ?? false;

  // Create a copy with updated fields
  MaterialModel copyWith({
    String? name,
    double? unitCost,
    String? unitType,
    double? stockQuantity,
    double? minStockThreshold,
    String? barcode,
    DateTime? lastUpdated,
    String? category,
    String? supplierId,
    bool? isLowStock,
    bool? isSynced,
  }) {
    return MaterialModel(
      id: this.id,
      name: name ?? this.name,
      unitCost: unitCost ?? this.unitCost,
      unitType: unitType ?? this.unitType,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      barcode: barcode ?? this.barcode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      supplierId: supplierId ?? this.supplierId,
      isLowStock: isLowStock ?? this.isLowStock,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Convert to Firebase map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unitCost': unitCost,
      'unitType': unitType,
      'stockQuantity': stockQuantity,
      'minStockThreshold': minStockThreshold,
      'barcode': barcode,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'category': category,
      'supplierId': supplierId,
      'isLowStock': stockQuantity <= minStockThreshold,
    };
  }

  // Create from Firebase document
  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MaterialModel(
      id: doc.id,
      name: data['name'] ?? '',
      unitCost: (data['unitCost'] ?? 0.0).toDouble(),
      unitType: data['unitType'] ?? '',
      stockQuantity: (data['stockQuantity'] ?? 0.0).toDouble(),
      minStockThreshold: (data['minStockThreshold'] ?? 0.0).toDouble(),
      barcode: data['barcode'] ?? '',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '',
      supplierId: data['supplierId'],
      isLowStock: data['isLowStock'] ?? false,
      isSynced: true,
    );
  }

  // Create from local map (for Hive)
  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'],
      name: map['name'] ?? '',
      unitCost: (map['unitCost'] ?? 0.0).toDouble(),
      unitType: map['unitType'] ?? '',
      stockQuantity: (map['stockQuantity'] ?? 0.0).toDouble(),
      minStockThreshold: (map['minStockThreshold'] ?? 0.0).toDouble(),
      barcode: map['barcode'] ?? '',
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
              : DateTime.now(),
      category: map['category'] ?? '',
      supplierId: map['supplierId'],
      isLowStock: map['isLowStock'] ?? false,
      isSynced: map['isSynced'] ?? false,
    );
  }

  // Convert to Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unitCost': unitCost,
      'unitType': unitType,
      'stockQuantity': stockQuantity,
      'minStockThreshold': minStockThreshold,
      'barcode': barcode,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'category': category,
      'supplierId': supplierId,
      'isLowStock': isLowStock,
      'isSynced': isSynced,
    };
  }
}
