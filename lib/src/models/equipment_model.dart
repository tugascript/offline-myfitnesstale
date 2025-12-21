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
      'id': id,
      'name': name,
      'picture_uri': pictureUri,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory Equipment.fromMap(Map<String, Object?> map) {
    return Equipment(
      id: map['id'] as int?,
      name: map['name'] as String,
      pictureUri: map['picture_uri'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory Equipment.create(
    String name,
    String? pictureUri,
  ) {
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

