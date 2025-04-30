// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialModelAdapter extends TypeAdapter<MaterialModel> {
  @override
  final int typeId = 1;

  @override
  MaterialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      unitCost: fields[2] as double,
      unitType: fields[3] as String,
      stockQuantity: fields[4] as double,
      minStockThreshold: fields[5] as double,
      barcode: fields[6] as String,
      lastUpdated: fields[7] as DateTime?,
      category: fields[8] as String,
      supplierId: fields[9] as String?,
      isLowStock: fields[10] as bool?,
      isSynced: fields[11] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unitCost)
      ..writeByte(3)
      ..write(obj.unitType)
      ..writeByte(4)
      ..write(obj.stockQuantity)
      ..writeByte(5)
      ..write(obj.minStockThreshold)
      ..writeByte(6)
      ..write(obj.barcode)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.supplierId)
      ..writeByte(10)
      ..write(obj.isLowStock)
      ..writeByte(11)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
