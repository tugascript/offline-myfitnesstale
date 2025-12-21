import 'model.dart';
import 'utilities.dart';

const String _table = 'muscle_groups';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    picture_uri TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
  ''';

class MuscleGroup implements Model {
  @override
  final int? id;
  final String name;
  final String? pictureUri;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MuscleGroup({
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
    };
  }

  @override
  factory MuscleGroup.fromMap(Map<String, Object?> map) {
    return MuscleGroup(
      id: map['id'] as int?,
      name: map['name'] as String,
      pictureUri: map['picture_uri'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory MuscleGroup.create(
    String name,
    String? pictureUri,
  ) {
    final now = DateUtilities.getNowUtcUnix();
    return MuscleGroup(
      name: name,
      pictureUri: pictureUri,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MuscleGroup copyWith({
    int? id,
    String? name,
    String? pictureUri,
    int? createdAt,
    int? updatedAt,
  }) {
    return MuscleGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUri: pictureUri ?? this.pictureUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MuscleGroup{id: $id, name: $name, pictureUri: $pictureUri, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
