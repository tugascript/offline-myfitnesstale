import 'model.dart';
import 'muscle_group_model.dart';
import 'utilities.dart';

const String _table = 'muscles';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    picture_uri TEXT,
    muscle_group_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (muscle_group_id) REFERENCES ${MuscleGroup.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_muscles_muscle_group_id ON $_table (muscle_group_id);
  CREATE UNIQUE INDEX IF NOT EXISTS idx_muscles_name_id ON $_table (name);
  ''';

class Muscle implements Model {
  @override
  final int? id;
  final String name;
  final String? pictureUri;
  final int muscleGroupId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Muscle({
    this.id,
    required this.name,
    this.pictureUri,
    required this.muscleGroupId,
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
      'muscle_group_id': muscleGroupId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory Muscle.fromMap(Map<String, Object?> map) {
    return Muscle(
      id: map['id'] as int?,
      name: map['name'] as String,
      pictureUri: map['picture_uri'] as String?,
      muscleGroupId: map['muscle_group_id'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory Muscle.create(
    String name,
    int muscleGroupId,
    String? pictureUri,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return Muscle(
      name: name,
      pictureUri: pictureUri,
      muscleGroupId: muscleGroupId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Muscle copyWith({
    int? id,
    String? name,
    String? pictureUri,
    int? muscleGroupId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Muscle(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUri: pictureUri ?? this.pictureUri,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Muscle{id: $id, name: $name, pictureUri: $pictureUri, muscleGroupId: $muscleGroupId, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
