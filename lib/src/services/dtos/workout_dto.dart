import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_model.dart';
import 'dto.dart';
import 'picture_dto.dart';
import 'video_dto.dart';
import 'workout_set_dto.dart';

class WorkoutDto extends Equatable implements Dto<Workout> {
  @override
  final int id;
  final String name;
  final Set<MuscleGroup> muscleGroups;
  final Set<Muscle> muscles;
  final String? description;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;
  final int totalSets;
  final int totalReps;

  // related data
  final List<WorkoutSetDto>? sets;

  const WorkoutDto({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.muscles,
    this.description,
    this.picture,
    this.video,
    required this.difficulty,
    required this.totalSets,
    required this.totalReps,
    this.sets,
  });

  @override
  factory WorkoutDto.fromModel(Workout model, {List<WorkoutSetDto>? sets}) {
    return WorkoutDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      picture:
          model.picture != null ? PictureDto.fromModel(model.picture!) : null,
      video: model.video != null ? VideoDto.fromModel(model.video!) : null,
      muscleGroups: model.muscleGroups,
      muscles: model.muscles,
      difficulty: model.difficulty,
      totalSets: model.totalSets,
      totalReps: model.totalReps,
      sets: sets,
    );
  }

  @override
  WorkoutDto copyWith({
    int? id,
    String? name,
    Set<MuscleGroup>? muscleGroups,
    Set<Muscle>? muscles,
    String? description,
    PictureDto? picture,
    VideoDto? video,
    Difficulty? difficulty,
    List<WorkoutSetDto>? sets,
    int? totalSets,
    int? totalReps,
  }) {
    return WorkoutDto(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      muscles: muscles ?? this.muscles,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        muscleGroups,
        muscles,
        description,
        picture,
        video,
        difficulty,
        totalSets,
        totalReps,
        sets,
      ];
}
