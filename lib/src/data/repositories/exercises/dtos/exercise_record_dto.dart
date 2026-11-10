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
import '../../../models/sqlite/exercise_record_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';
import '../../core/dtos/picture_dto.dart';
import '../../core/dtos/video_dto.dart';
import './exercise_dto.dart';

class ExerciseRecordDto extends Equatable implements ModelDto<ExerciseRecord> {
  @override
  final int id;
  final int exerciseId;
  final int weight;
  final int reps;
  final int maxStrength;
  final DateTime recordDate;
  final PictureDto? picture;
  final VideoDto? video;

  // Related data
  final ExerciseDto? exercise;

  const ExerciseRecordDto({
    required this.id,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.maxStrength,
    required this.recordDate,
    this.picture,
    this.video,
    this.exercise,
  });

  factory ExerciseRecordDto.fromModel(
    ExerciseRecord model, {
    ExerciseDto? exercise,
  }) {
    return ExerciseRecordDto(
      id: model.id!,
      exerciseId: model.exerciseId,
      weight: model.weight,
      reps: model.reps,
      maxStrength: model.maxStrength,
      recordDate: DateUtilities.getDateFromUnix(model.recordDate),
      picture: model.picture != null
          ? PictureDto.fromModel(model.picture!)
          : null,
      video: model.video != null ? VideoDto.fromModel(model.video!) : null,
      exercise: exercise,
    );
  }

  factory ExerciseRecordDto.empty() {
    return ExerciseRecordDto(
      id: 0,
      exerciseId: 0,
      weight: 0,
      reps: 0,
      maxStrength: 0,
      recordDate: DateTime.now(),
    );
  }

  @override
  ExerciseRecordDto copyWith({
    int? id,
    int? exerciseId,
    int? weight,
    int? reps,
    int? maxStrength,
    Nullable<PictureDto>? picture,
    Nullable<VideoDto>? video,
    Nullable<ExerciseDto>? exercise,
    DateTime? recordDate,
  }) {
    return ExerciseRecordDto(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      maxStrength: maxStrength ?? this.maxStrength,
      picture: picture != null ? picture.value : this.picture,
      video: video != null ? video.value : this.video,
      exercise: exercise != null ? exercise.value : this.exercise,
      recordDate: recordDate ?? this.recordDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    weight,
    reps,
    maxStrength,
    picture,
    video,
    exercise,
    recordDate,
  ];
}
