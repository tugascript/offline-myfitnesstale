import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'equipment';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    picture_uri TEXT,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS idx_equipment_name_id ON $_table (name);
  ''';

enum EquipmentColumns {
  id("id"),
  name("name"),
  pictureUri("picture_uri"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const EquipmentColumns(this.value);
}

class Equipment implements Model {
  @override
  final int? id;
  final String name;
  final String? pictureUri;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Equipment({
    this.id,
    required this.name,
    this.pictureUri,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      EquipmentColumns.id.value: id,
      EquipmentColumns.name.value: name,
      EquipmentColumns.pictureUri.value: pictureUri,
      EquipmentColumns.createdBy.value: createdBy.value,
      EquipmentColumns.createdAt.value: createdAt,
      EquipmentColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory Equipment.fromMap(Map<String, Object?> map) {
    return Equipment(
      id: map[EquipmentColumns.id.value] as int?,
      name: map[EquipmentColumns.name.value] as String,
      pictureUri: map[EquipmentColumns.pictureUri.value] as String?,
      createdBy:
          CreatedBy.fromValue(map[EquipmentColumns.createdBy.value] as String),
      createdAt: map[EquipmentColumns.createdAt.value] as int,
      updatedAt: map[EquipmentColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Equipment.create({
    required String name,
    String? pictureUri,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Equipment(
      name: name,
      pictureUri: pictureUri,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Equipment copyWith({
    int? id,
    String? name,
    String? pictureUri,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUri: pictureUri ?? this.pictureUri,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, pictureUri: $pictureUri, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
