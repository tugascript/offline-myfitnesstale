import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plans';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    total_weeks INTEGER NOT NULL,
    picture_uri TEXT,
    video_uri TEXT,
    video_platform TEXT,
    difficulty INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workout_plans_name ON $_table (name);
  ''';

class WorkoutPlan extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final int totalWeeks;
  final String? pictureUri;
  final String? videoUri;
  final String? videoPlatform;
  final int difficulty;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlan({
    this.id,
    required this.name,
    this.description,
    required this.totalWeeks,
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
      'total_weeks': totalWeeks,
      'picture_uri': pictureUri,
      'video_uri': videoUri,
      'video_platform': videoPlatform,
      'difficulty': difficulty,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      totalWeeks: map['total_weeks'] as int,
      pictureUri: map['picture_uri'] as String?,
      videoUri: map['video_uri'] as String?,
      videoPlatform: map['video_platform'] as String?,
      difficulty: map['difficulty'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutPlan.create(
    String name,
    int totalWeeks,
    int difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlan(
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty,
      description: description,
      pictureUri: pictureUri,
      videoUri: videoData?.$2,
      videoPlatform: videoData?.$1.value,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlan copyWith({
    int? id,
    String? name,
    String? description,
    int? totalWeeks,
    String? pictureUri,
    String? videoUri,
    String? videoPlatform,
    int? difficulty,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      pictureUri: pictureUri ?? this.pictureUri,
      videoUri: videoUri ?? this.videoUri,
      videoPlatform: videoPlatform ?? this.videoPlatform,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        totalWeeks,
        pictureUri,
        videoUri,
        videoPlatform,
        difficulty,
        createdAt,
        updatedAt
      ];
}
