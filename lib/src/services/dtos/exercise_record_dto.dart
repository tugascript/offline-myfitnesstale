import 'package:equatable/equatable.dart';

import '../../models/exercise_record_model.dart';
import '../../models/utilities.dart';
import 'dto.dart';
import 'exercise_dto.dart';
import 'picture_dto.dart';
import 'video_dto.dart';

class ExerciseRecordDto extends Equatable implements Dto<ExerciseRecord> {
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

  @override
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
      picture:
          model.picture != null ? PictureDto.fromModel(model.picture!) : null,
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
    PictureDto? picture,
    VideoDto? video,
    ExerciseDto? exercise,
    DateTime? recordDate,
  }) {
    return ExerciseRecordDto(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      maxStrength: maxStrength ?? this.maxStrength,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      exercise: exercise ?? this.exercise,
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
        recordDate,
      ];
}
