import 'package:equatable/equatable.dart';
import 'package:myfitnesstale/src/models/enums.dart';

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
  final int totalWeeks;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;

  // Related data
  final List<WorkoutPlanWeekDto>? weeks;

  const WorkoutPlanDto({
    required this.id,
    required this.name,
    this.description,
    required this.totalWeeks,
    this.picture,
    this.video,
    required this.difficulty,
    this.weeks,
  });

  @override
  factory WorkoutPlanDto.fromModel(
    WorkoutPlan model, {
    List<WorkoutPlanWeekDto>? weeks,
  }) {
    return WorkoutPlanDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      totalWeeks: model.totalWeeks,
      picture:
          model.picture != null ? PictureDto.fromModel(model.picture!) : null,
      video: model.video != null ? VideoDto.fromModel(model.video!) : null,
      difficulty: model.difficulty,
      weeks: weeks,
    );
  }

  @override
  WorkoutPlanDto copyWith({
    int? id,
    String? name,
    String? description,
    int? totalWeeks,
    PictureDto? picture,
    VideoDto? video,
    Difficulty? difficulty,
    List<WorkoutPlanWeekDto>? weeks,
  }) {
    return WorkoutPlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      weeks: weeks ?? this.weeks,
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
        weeks,
      ];
}
