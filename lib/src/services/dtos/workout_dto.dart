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
  final String? description;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;

  // related data
  final List<WorkoutSetDto>? sets;

  const WorkoutDto({
    required this.id,
    required this.name,
    required this.muscleGroups,
    this.description,
    this.picture,
    this.video,
    required this.difficulty,
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
      difficulty: model.difficulty,
      sets: sets,
    );
  }

  @override
  WorkoutDto copyWith({
    int? id,
    String? name,
    Set<MuscleGroup>? muscleGroups,
    String? description,
    PictureDto? picture,
    VideoDto? video,
    Difficulty? difficulty,
    List<WorkoutSetDto>? sets,
  }) {
    return WorkoutDto(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        muscleGroups,
        description,
        picture,
        video,
        difficulty,
        sets,
      ];
}
