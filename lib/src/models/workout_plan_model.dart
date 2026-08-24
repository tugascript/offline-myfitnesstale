import 'package:equatable/equatable.dart';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plans';

enum WorkoutPlanColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  difficulty("difficulty"),
  version("version"),
  totalWeeks("total_weeks"),
  totalDays("total_days"),
  totalWorkouts("total_workouts"),
  isFavorite("is_favorite"),
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
  final int version;
  final int totalWeeks;
  final int totalDays;
  final int totalWorkouts;
  final bool isFavorite;
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
    required this.version,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalWorkouts,
    required this.isFavorite,
    this.picture,
    this.video,
    required this.difficulty,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutPlanColumns.name.value} TEXT NOT NULL,
    ${WorkoutPlanColumns.description.value} TEXT,
    ${WorkoutPlanColumns.picture.value} TEXT,
    ${WorkoutPlanColumns.video.value} TEXT,
    ${WorkoutPlanColumns.version.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.totalWeeks.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.totalDays.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.totalWorkouts.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.isFavorite.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.difficulty.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutPlanColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanColumns.updatedAt.value} INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workout_plans_name ON $_table (${WorkoutPlanColumns.name.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanColumns.id.value: id,
      WorkoutPlanColumns.name.value: name,
      WorkoutPlanColumns.description.value: description,
      WorkoutPlanColumns.version.value: version,
      WorkoutPlanColumns.totalWeeks.value: totalWeeks,
      WorkoutPlanColumns.totalDays.value: totalDays,
      WorkoutPlanColumns.totalWorkouts.value: totalWorkouts,
      WorkoutPlanColumns.isFavorite.value: isFavorite ? 1 : 0,
      WorkoutPlanColumns.picture.value: picture,
      WorkoutPlanColumns.video.value: video,
      WorkoutPlanColumns.difficulty.value: difficulty.value,
      WorkoutPlanColumns.createdBy.value: createdBy.value,
      WorkoutPlanColumns.createdAt.value: createdAt,
      WorkoutPlanColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map[WorkoutPlanColumns.id.value] as int?,
      name: map[WorkoutPlanColumns.name.value] as String,
      description: map[WorkoutPlanColumns.description.value] as String?,
      version: map[WorkoutPlanColumns.version.value] as int? ?? 1,
      totalWeeks: map[WorkoutPlanColumns.totalWeeks.value] as int,
      totalDays: map[WorkoutPlanColumns.totalDays.value] as int,
      totalWorkouts: map[WorkoutPlanColumns.totalWorkouts.value] as int,
      isFavorite: map[WorkoutPlanColumns.isFavorite.value] as int == 1,
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
    );
  }

  factory WorkoutPlan.create({
    required String name,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
    int version = 1,
    int totalWeeks = 0,
    int totalDays = 0,
    int totalWorkouts = 0,
    CreatedBy createdBy = CreatedBy.user,
    bool isFavorite = false,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlan(
      name: name,
      version: version,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      totalWorkouts: totalWorkouts,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
      createdBy: createdBy,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlan copyWith({
    int? id,
    String? name,
    String? description,
    int? version,
    int? totalWeeks,
    int? totalDays,
    int? totalWorkouts,
    PictureData? picture,
    VideoData? video,
    Difficulty? difficulty,
    CreatedBy? createdBy,
    bool? isFavorite,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        version,
        totalWeeks,
        totalDays,
        totalWorkouts,
        picture,
        video,
        difficulty,
        createdBy,
        isFavorite,
        createdAt,
        updatedAt
      ];
}
