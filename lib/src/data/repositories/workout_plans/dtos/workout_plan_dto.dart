// Copyright (C) 2026 afonsobarracha
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
import '../../../utils/enums.dart';
import '../../../models/workout_plan_model.dart';
import '../../core/dtos/dto.dart';
import '../../core/dtos/picture_dto.dart';
import '../../core/dtos/video_dto.dart';
import './workout_plan_week_dto.dart';

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
      picture: model.picture != null
          ? PictureDto.fromModel(model.picture!)
          : null,
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
    Nullable<String>? description,
    int? currentVersion,
    int? totalWeeks,
    int? totalDays,
    int? totalWorkouts,
    Nullable<PictureDto>? picture,
    Nullable<VideoDto>? video,
    Difficulty? difficulty,
    CreatedBy? createdBy,
    bool? isFavorite,
    Nullable<List<WorkoutPlanWeekDto>>? weeks,
  }) {
    return WorkoutPlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description.value : this.description,
      currentVersion: currentVersion ?? this.currentVersion,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      picture: picture != null ? picture.value : this.picture,
      video: video != null ? video.value : this.video,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      isFavorite: isFavorite ?? this.isFavorite,
      weeks: weeks != null ? weeks.value : this.weeks,
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
