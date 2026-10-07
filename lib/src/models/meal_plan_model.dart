import 'package:equatable/equatable.dart';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plans';

enum MealPlanColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  version("version"),
  totalWeeks("total_weeks"),
  totalDays("total_days"),
  totalMeals("total_meals"),
  isFavorite("is_favorite"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanColumns(this.value);
}

class MealPlan extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final PictureData? picture;
  final VideoData? video;
  final int version;
  final int totalWeeks;
  final int totalDays;
  final int totalMeals;
  final bool isFavorite;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlan({
    this.id,
    required this.name,
    this.description,
    this.picture,
    this.video,
    this.version = 1,
    this.totalWeeks = 1,
    this.totalDays = 7,
    this.totalMeals = 0,
    this.isFavorite = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanColumns.name.value} TEXT NOT NULL,
    ${MealPlanColumns.description.value} TEXT,
    ${MealPlanColumns.picture.value} TEXT,
    ${MealPlanColumns.video.value} TEXT,
    ${MealPlanColumns.version.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanColumns.totalWeeks.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanColumns.totalDays.value} INTEGER NOT NULL DEFAULT 7,
    ${MealPlanColumns.totalMeals.value} INTEGER NOT NULL DEFAULT 0,
    ${MealPlanColumns.isFavorite.value} INTEGER NOT NULL DEFAULT 0,
    ${MealPlanColumns.createdBy.value} TEXT NOT NULL,
    ${MealPlanColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plans_name ON $_table (${MealPlanColumns.name.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plans_is_favorite ON $_table (${MealPlanColumns.isFavorite.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanColumns.id.value: id,
      MealPlanColumns.name.value: name,
      MealPlanColumns.description.value: description,
      MealPlanColumns.picture.value: picture?.toJson(),
      MealPlanColumns.video.value: video?.toJson(),
      MealPlanColumns.version.value: version,
      MealPlanColumns.totalWeeks.value: totalWeeks,
      MealPlanColumns.totalDays.value: totalDays,
      MealPlanColumns.totalMeals.value: totalMeals,
      MealPlanColumns.isFavorite.value: isFavorite ? 1 : 0,
      MealPlanColumns.createdBy.value: createdBy.value,
      MealPlanColumns.createdAt.value: createdAt,
      MealPlanColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlan.fromMap(Map<String, Object?> map) {
    return MealPlan(
      id: map[MealPlanColumns.id.value] as int?,
      name: map[MealPlanColumns.name.value] as String,
      description: map[MealPlanColumns.description.value] as String?,
      picture: map[MealPlanColumns.picture.value] != null
          ? PictureData.fromJson(map[MealPlanColumns.picture.value] as String)
          : null,
      video: map[MealPlanColumns.video.value] != null
          ? VideoData.fromJson(map[MealPlanColumns.video.value] as String)
          : null,
      version: map[MealPlanColumns.version.value] as int? ?? 1,
      totalWeeks: map[MealPlanColumns.totalWeeks.value] as int? ?? 1,
      totalDays: map[MealPlanColumns.totalDays.value] as int? ?? 7,
      totalMeals: map[MealPlanColumns.totalMeals.value] as int? ?? 0,
      isFavorite: (map[MealPlanColumns.isFavorite.value] as int? ?? 0) == 1,
      createdBy:
          CreatedBy.fromValue(map[MealPlanColumns.createdBy.value] as String),
      createdAt: map[MealPlanColumns.createdAt.value] as int,
      updatedAt: map[MealPlanColumns.updatedAt.value] as int,
    );
  }

  factory MealPlan.create({
    required String name,
    String? description,
    PictureData? picture,
    VideoData? video,
    int version = 1,
    int totalWeeks = 1,
    int totalDays = 7,
    int totalMeals = 0,
    bool isFavorite = false,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlan(
      name: name,
      description: description,
      picture: picture,
      video: video,
      version: version,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      totalMeals: totalMeals,
      isFavorite: isFavorite,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlan copyWith({
    int? id,
    String? name,
    String? description,
    PictureData? picture,
    VideoData? video,
    int? version,
    int? totalWeeks,
    int? totalDays,
    int? totalMeals,
    bool? isFavorite,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      version: version ?? this.version,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalMeals: totalMeals ?? this.totalMeals,
      isFavorite: isFavorite ?? this.isFavorite,
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
        picture,
        video,
        version,
        totalWeeks,
        totalDays,
        totalMeals,
        isFavorite,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
