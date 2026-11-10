// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../models/sqlite/workout_model.dart';
import '../../../utils/enums.dart';
import '../../../utils/json_data.dart';
import '../../core/dtos/dto.dart';
import '../../core/dtos/picture_dto.dart';
import '../../core/dtos/video_dto.dart';
import './workout_set_dto.dart';

final class WorkoutDto extends Equatable implements ModelDto<Workout> {
  @override
  final int id;
  final String name;
  final Set<MuscleGroup> muscleGroups;
  final TargetMuscles muscles;
  final String? description;
  final PictureDto? picture;
  final VideoDto? video;
  final Difficulty difficulty;
  final WorkoutPhase? phase;
  final int version;
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
    this.phase,
    required this.version,
    required this.isFavorite,
    required this.totalSets,
    required this.totalReps,
    required this.editorType,
    required this.createdBy,
    this.sets,
  });

  factory WorkoutDto.fromModel(Workout model, {List<WorkoutSetDto>? sets}) {
    return WorkoutDto(
      id: model.id!,
      name: model.name,
      description: model.description,
      picture: model.picture != null
          ? PictureDto.fromModel(model.picture!)
          : null,
      video: model.video != null ? VideoDto.fromModel(model.video!) : null,
      muscleGroups: model.muscleGroups,
      muscles: model.muscles,
      difficulty: model.difficulty,
      phase: model.phase,
      isFavorite: model.isFavorite,
      version: model.version,
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
    Nullable<String>? description,
    Nullable<PictureDto>? picture,
    Nullable<VideoDto>? video,
    Difficulty? difficulty,
    Nullable<WorkoutPhase>? phase,
    bool? isFavorite,
    int? version,
    Nullable<List<WorkoutSetDto>>? sets,
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
      description: description != null ? description.value : this.description,
      picture: picture != null ? picture.value : this.picture,
      video: video != null ? video.value : this.video,
      difficulty: difficulty ?? this.difficulty,
      phase: phase != null ? phase.value : this.phase,
      isFavorite: isFavorite ?? this.isFavorite,
      version: version ?? this.version,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      editorType: editorType ?? this.editorType,
      createdBy: createdBy ?? this.createdBy,
      sets: sets != null ? sets.value : this.sets,
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
    phase,
    isFavorite,
    version,
    totalSets,
    totalReps,
    editorType,
    createdBy,
    sets,
  ];
}
