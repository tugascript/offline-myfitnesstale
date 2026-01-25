import 'package:equatable/equatable.dart';

import 'common.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plans';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    total_weeks INTEGER NOT NULL,
    picture TEXT,
    video TEXT,
    difficulty INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workout_plans_name ON $_table (name);
  ''';

enum WorkoutPlanColumns {
  id("id"),
  name("name"),
  description("description"),
  totalWeeks("total_weeks"),
  picture("picture"),
  video("video"),
  difficulty("difficulty"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutPlanColumns(this.value);
}

class WorkoutPlan extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final int totalWeeks;
  final PictureData? picture;
  final VideoData? video;
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
    this.picture,
    this.video,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanColumns.id.value: id,
      WorkoutPlanColumns.name.value: name,
      WorkoutPlanColumns.description.value: description,
      WorkoutPlanColumns.totalWeeks.value: totalWeeks,
      WorkoutPlanColumns.picture.value: picture,
      WorkoutPlanColumns.video.value: video,
      WorkoutPlanColumns.difficulty.value: difficulty,
      WorkoutPlanColumns.createdAt.value: createdAt,
      WorkoutPlanColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map[WorkoutPlanColumns.id.value] as int?,
      name: map[WorkoutPlanColumns.name.value] as String,
      description: map[WorkoutPlanColumns.description.value] as String?,
      totalWeeks: map[WorkoutPlanColumns.totalWeeks.value] as int,
      picture: map[WorkoutPlanColumns.picture.value] != null
          ? PictureData.fromJson(
              map[WorkoutPlanColumns.picture.value] as String)
          : null,
      video: map[WorkoutPlanColumns.video.value] != null
          ? VideoData.fromJson(map[WorkoutPlanColumns.video.value] as String)
          : null,
      difficulty: map[WorkoutPlanColumns.difficulty.value] as int,
      createdAt: map[WorkoutPlanColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutPlan.create({
    required String name,
    required int totalWeeks,
    required int difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlan(
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
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
      picture: picture ?? picture,
      video: video ?? video,
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
        picture,
        video,
        difficulty,
        createdAt,
        updatedAt
      ];
}
