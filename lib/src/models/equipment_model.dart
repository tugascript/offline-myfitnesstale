import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'equipment';

enum EquipmentColumns with Columns {
  id("id"),
  name("name"),
  picture("picture"),
  isFavorite("is_favorite"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const EquipmentColumns(this.value);
}

class Equipment implements Model {
  @override
  final int? id;
  final String name;
  final PictureData? picture;
  final bool isFavorite;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Equipment({
    this.id,
    required this.name,
    this.picture,
    required this.isFavorite,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${EquipmentColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${EquipmentColumns.name.value} TEXT NOT NULL,
    ${EquipmentColumns.picture.value} TEXT,
    ${EquipmentColumns.isFavorite.value} INTEGER NOT NULL,
    ${EquipmentColumns.createdBy.value} TEXT NOT NULL,
    ${EquipmentColumns.createdAt.value} INTEGER NOT NULL,
    ${EquipmentColumns.updatedAt.value} INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS idx_equipment_name_id ON $_table (${EquipmentColumns.name.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      EquipmentColumns.id.value: id,
      EquipmentColumns.name.value: name,
      EquipmentColumns.picture.value: picture?.toJson(),
      EquipmentColumns.isFavorite.value: isFavorite ? 1 : 0,
      EquipmentColumns.createdBy.value: createdBy.value,
      EquipmentColumns.createdAt.value: createdAt,
      EquipmentColumns.updatedAt.value: updatedAt,
    };
  }

  factory Equipment.fromMap(Map<String, Object?> map) {
    return Equipment(
      id: map[EquipmentColumns.id.value] as int?,
      name: map[EquipmentColumns.name.value] as String,
      picture: map[EquipmentColumns.picture.value] != null
          ? PictureData.fromJson(map[EquipmentColumns.picture.value] as String)
          : null,
      isFavorite: map[EquipmentColumns.isFavorite.value] as int == 1,
      createdBy:
          CreatedBy.fromValue(map[EquipmentColumns.createdBy.value] as String),
      createdAt: map[EquipmentColumns.createdAt.value] as int,
      updatedAt: map[EquipmentColumns.updatedAt.value] as int,
    );
  }

  factory Equipment.create({
    required String name,
    PictureData? picture,
    bool isFavorite = false,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Equipment(
      name: name,
      picture: picture,
      isFavorite: isFavorite,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Equipment copyWith({
    int? id,
    String? name,
    PictureData? picture,
    bool? isFavorite,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, picture: $picture, isFavorite: $isFavorite, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
