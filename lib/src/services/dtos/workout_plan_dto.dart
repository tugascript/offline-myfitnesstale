import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_model.dart';
import 'dto.dart';
import 'picture_dto.dart';
import 'video_dto.dart';
import 'workout_plan_week_dto.dart';

class WorkoutPlanDto extends Equatable implements Dto<WorkoutPlan> {
  @override
  final int id;
  final String name;
  final String? description;
  final int currentVersion;
  final int totalWeeks;
  final int totalDays;
  final int totalWorkouts;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;
  final bool isFavorite;
  final CreatedBy createdBy;

  // Related data
  final List<WorkoutPlanWeekDto>? weeks;

  const WorkoutPlanDto({
    required this.id,
    required this.name,
    this.description,
    required this.currentVersion,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalWorkouts,
    this.picture,
    this.video,
    required this.difficulty,
    required this.isFavorite,
    required this.createdBy,
    this.weeks,
  });

  factory WorkoutPlanDto.fromModel(
    WorkoutPlan model, {
    List<WorkoutPlanWeekDto>? weeks,
  }) {
    return WorkoutPlanDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      currentVersion: model.version,
      totalWeeks: model.totalWeeks,
      totalDays: model.totalDays,
      totalWorkouts: model.totalWorkouts,
      picture:
          model.picture != null ? PictureDto.fromModel(model.picture!) : null,
      video: model.video != null ? VideoDto.fromModel(model.video!) : null,
      difficulty: model.difficulty,
      isFavorite: model.isFavorite,
      createdBy: model.createdBy,
      weeks: weeks,
    );
  }

  @override
  WorkoutPlanDto copyWith({
    int? id,
    String? name,
    String? description,
    int? currentVersion,
    int? totalWeeks,
    int? totalDays,
    int? totalWorkouts,
    PictureDto? picture,
    VideoDto? video,
    Difficulty? difficulty,
    CreatedBy? createdBy,
    bool? isFavorite,
    List<WorkoutPlanWeekDto>? weeks,
  }) {
    return WorkoutPlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currentVersion: currentVersion ?? this.currentVersion,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      isFavorite: isFavorite ?? this.isFavorite,
      weeks: weeks ?? this.weeks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        currentVersion,
        totalWeeks,
        totalDays,
        totalWorkouts,
        picture,
        video,
        difficulty,
        isFavorite,
        createdBy,
        weeks,
      ];
}
