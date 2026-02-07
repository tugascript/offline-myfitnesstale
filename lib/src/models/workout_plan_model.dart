import 'package:equatable/equatable.dart';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plans';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    picture TEXT,
    video TEXT,
    total_weeks INTEGER NOT NULL,
    total_days INTEGER NOT NULL,
    total_workouts INTEGER NOT NULL,
    difficulty INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workout_plans_name ON $_table (name);
  ''';

enum WorkoutPlanColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  difficulty("difficulty"),
  totalWeeks("total_weeks"),
  totalDays("total_days"),
  totalWorkouts("total_workouts"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanColumns(this.value);
}

class WorkoutPlan extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final int totalWeeks;
  final int totalDays;
  final int totalWorkouts;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlan({
    this.id,
    required this.name,
    this.description,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalWorkouts,
    this.picture,
    this.video,
    required this.difficulty,
    required this.createdBy,
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
      WorkoutPlanColumns.totalDays.value: totalDays,
      WorkoutPlanColumns.totalWorkouts.value: totalWorkouts,
      WorkoutPlanColumns.picture.value: picture,
      WorkoutPlanColumns.video.value: video,
      WorkoutPlanColumns.difficulty.value: difficulty.value,
      WorkoutPlanColumns.createdBy.value: createdBy.value,
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
      difficulty:
          Difficulty.fromValue(map[WorkoutPlanColumns.difficulty.value] as int),
      createdBy: CreatedBy.fromValue(
        map[WorkoutPlanColumns.createdBy.value] as String,
      ),
      createdAt: map[WorkoutPlanColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanColumns.updatedAt.value] as int,
      totalDays: map[WorkoutPlanColumns.totalDays.value] as int,
      totalWorkouts: map[WorkoutPlanColumns.totalWorkouts.value] as int,
    );
  }

  @override
  factory WorkoutPlan.create({
    required String name,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
    int totalWeeks = 0,
    int totalDays = 0,
    int totalWorkouts = 0,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlan(
      name: name,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      totalWorkouts: totalWorkouts,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
      createdBy: createdBy,
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
    int? totalDays,
    int? totalWorkouts,
    PictureData? picture,
    VideoData? video,
    Difficulty? difficulty,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
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
        totalDays,
        totalWorkouts,
        picture,
        video,
        difficulty,
        createdBy,
        createdAt,
        updatedAt
      ];
}
