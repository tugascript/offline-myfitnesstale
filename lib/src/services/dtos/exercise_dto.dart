import 'package:equatable/equatable.dart';

import '../../models/common.dart';
import '../../models/enums.dart';
import '../../models/exercise_model.dart';
import 'dto.dart';
import 'equipment_dto.dart';
import 'picture_dto.dart';
import 'video_dto.dart';

class ExerciseDto extends Equatable implements Dto<Exercise> {
  @override
  final int id;
  final String name;
  final String description;
  final PictureDto? picture;
  final VideoDto? video;
  final MuscleGroup muscleGroup;
  final TargetMuscles muscles;
  final bool isFavorite;
  final Difficulty? difficulty;
  final CreatedBy createdBy;

  // Related data
  final List<EquipmentDto>? equipments;

  const ExerciseDto({
    required this.id,
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.muscleGroup,
    required this.muscles,
    this.equipments,
    this.isFavorite = false,
    this.difficulty,
    required this.createdBy,
  });

  factory ExerciseDto.fromModel(
    Exercise exercise, {
    List<EquipmentDto>? equipments,
  }) {
    return ExerciseDto(
      id: exercise.id!,
      name: exercise.name,
      description: exercise.description ?? '',
      picture: exercise.picture != null
          ? PictureDto.fromModel(exercise.picture!)
          : null,
      video:
          exercise.video != null ? VideoDto.fromModel(exercise.video!) : null,
      muscleGroup: exercise.muscleGroup,
      muscles: exercise.muscles,
      isFavorite: exercise.isFavorite,
      difficulty: exercise.difficulty,
      equipments: equipments,
      createdBy: exercise.createdBy,
    );
  }

  @override
  ExerciseDto copyWith({
    int? id,
    String? name,
    String? description,
    PictureDto? picture,
    VideoDto? video,
    MuscleGroup? muscleGroup,
    TargetMuscles? muscles,
    List<EquipmentDto>? equipments,
    bool? isFavorite,
    Difficulty? difficulty,
    CreatedBy? createdBy,
  }) {
    return ExerciseDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      muscles: muscles ?? this.muscles,
      equipments: equipments ?? this.equipments,
      isFavorite: isFavorite ?? this.isFavorite,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        picture,
        video,
        muscleGroup,
        muscles,
        equipments,
        isFavorite,
        difficulty,
        createdBy,
      ];
}
