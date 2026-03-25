import 'package:equatable/equatable.dart';

import '../../models/common.dart';
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
  final TargetMuscles muscles;
  final String? description;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;
  final bool isFavorite;
  final int totalSets;
  final int totalReps;
  final EditorType editorType;
  final CreatedBy createdBy;

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
    required this.isFavorite,
    required this.totalSets,
    required this.totalReps,
    required this.editorType,
    required this.createdBy,
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
      isFavorite: model.isFavorite,
      totalSets: model.totalSets,
      totalReps: model.totalReps,
      editorType: model.editorType,
      createdBy: model.createdBy,
      sets: sets,
    );
  }

  @override
  WorkoutDto copyWith({
    int? id,
    String? name,
    Set<MuscleGroup>? muscleGroups,
    TargetMuscles? muscles,
    String? description,
    PictureDto? picture,
    VideoDto? video,
    Difficulty? difficulty,
    bool? isFavorite,
    List<WorkoutSetDto>? sets,
    int? totalSets,
    int? totalReps,
    EditorType? editorType,
    CreatedBy? createdBy,
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
      isFavorite: isFavorite ?? this.isFavorite,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      editorType: editorType ?? this.editorType,
      createdBy: createdBy ?? this.createdBy,
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
        isFavorite,
        totalSets,
        totalReps,
        editorType,
        createdBy,
        sets,
      ];
}
