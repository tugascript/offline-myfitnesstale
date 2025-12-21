import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workouts';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    picture_uri TEXT,
    video_uri TEXT,
    video_platform TEXT,
    difficulty INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workouts_name ON $_table (name);
  ''';

class Workout implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final String? pictureUri;
  final String? videoUri;
  final String? videoPlatform;
  final Difficulty difficulty;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Workout({
    this.id,
    required this.name,
    this.description,
    this.pictureUri,
    this.videoUri,
    this.videoPlatform,
    required this.difficulty,
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
      'description': description,
      'picture_uri': pictureUri,
      'video_uri': videoUri,
      'video_platform': videoPlatform,
      'difficulty': difficulty.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory Workout.fromMap(Map<String, Object?> map) {
    return Workout(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      pictureUri: map['picture_uri'] as String?,
      videoUri: map['video_uri'] as String?,
      videoPlatform: map['video_platform'] as String?,
      difficulty: Difficulty.fromValue(map['difficulty'] as int),
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory Workout.create(
    String name,
    Difficulty difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return Workout(
      name: name,
      description: description,
      pictureUri: pictureUri,
      videoUri: videoData?.$2,
      videoPlatform: videoData?.$1.value,
      difficulty: difficulty,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Workout copyWith({
    int? id,
    String? name,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
    Difficulty? difficulty,
    int? createdAt,
    int? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pictureUri: pictureUri ?? this.pictureUri,
      videoUri: videoData?.$2 ?? videoUri,
      videoPlatform: videoData?.$1.value ?? videoPlatform,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Workout{id: $id, name: $name, description: $description, pictureUri: $pictureUri, videoUri: $videoUri, videoPlatform: $videoPlatform, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
