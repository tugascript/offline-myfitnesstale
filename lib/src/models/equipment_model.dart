import 'model.dart';
import 'utilities.dart';

const String _table = 'equipment';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    picture_uri TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS idx_equipment_name_id ON $_table (name);
  ''';

enum EquimentColumns {
  id("id"),
  name("name"),
  pictureUri("picture_uri"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const EquimentColumns(this.value);
}

class Equipment implements Model {
  @override
  final int? id;
  final String name;
  final String? pictureUri;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Equipment({
    this.id,
    required this.name,
    this.pictureUri,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      EquimentColumns.id.value: id,
      EquimentColumns.name.value: name,
      EquimentColumns.pictureUri.value: pictureUri,
      EquimentColumns.createdAt.value: createdAt,
      EquimentColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory Equipment.fromMap(Map<String, Object?> map) {
    return Equipment(
      id: map[EquimentColumns.id.value] as int?,
      name: map[EquimentColumns.name.value] as String,
      pictureUri: map[EquimentColumns.pictureUri.value] as String?,
      createdAt: map[EquimentColumns.createdAt.value] as int,
      updatedAt: map[EquimentColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Equipment.create({
    required String name,
    String? pictureUri,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Equipment(
      name: name,
      pictureUri: pictureUri,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Equipment copyWith({
    int? id,
    String? name,
    String? pictureUri,
    int? createdAt,
    int? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUri: pictureUri ?? this.pictureUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, pictureUri: $pictureUri, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
