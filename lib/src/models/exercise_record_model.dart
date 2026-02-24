import 'package:equatable/equatable.dart';

import 'common.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'exercise_records';

enum ExerciseRecordColumns with Columns {
  id("id"),
  exerciseId("exercise_id"),
  weight("weight"),
  reps("reps"),
  maxStrength("max_strength"),
  picture("picture"),
  video("video"),
  recordDate("record_date"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const ExerciseRecordColumns(this.value);
}

class ExerciseRecord extends Equatable implements Model {
  @override
  final int? id;
  final int exerciseId;
  final int weight;
  final int reps;
  final int maxStrength;
  final PictureData? picture;
  final VideoData? video;
  final int recordDate;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const ExerciseRecord({
    this.id,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.maxStrength,
    this.picture,
    this.video,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = """
  CREATE TABLE IF NOT EXISTS $_table (
    ${ExerciseRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${ExerciseRecordColumns.exerciseId.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.weight.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.reps.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.maxStrength.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.picture.value} TEXT,
    ${ExerciseRecordColumns.video.value} TEXT,
    ${ExerciseRecordColumns.recordDate.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${ExerciseRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${ExerciseRecordColumns.exerciseId.value}) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_records_exercise_id ON $_table (${ExerciseRecordColumns.exerciseId.value});
  """;

  @override
  Map<String, Object?> toMap() {
    return {
      ExerciseRecordColumns.id.value: id,
      ExerciseRecordColumns.exerciseId.value: exerciseId,
      ExerciseRecordColumns.weight.value: weight,
      ExerciseRecordColumns.reps.value: reps,
      ExerciseRecordColumns.maxStrength.value: maxStrength,
      ExerciseRecordColumns.picture.value: picture?.toJson(),
      ExerciseRecordColumns.video.value: video?.toJson(),
      ExerciseRecordColumns.recordDate.value: recordDate,
      ExerciseRecordColumns.createdAt.value: createdAt,
      ExerciseRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory ExerciseRecord.fromMap(Map<String, Object?> map) {
    return ExerciseRecord(
      id: map[ExerciseRecordColumns.id.value] as int?,
      exerciseId: map[ExerciseRecordColumns.exerciseId.value] as int,
      weight: map[ExerciseRecordColumns.weight.value] as int,
      reps: map[ExerciseRecordColumns.reps.value] as int,
      maxStrength: map[ExerciseRecordColumns.maxStrength.value] as int,
      picture: map[ExerciseRecordColumns.picture.value] != null
          ? PictureData.fromJson(
              map[ExerciseRecordColumns.picture.value] as String)
          : null,
      video: map[ExerciseRecordColumns.video.value] != null
          ? VideoData.fromJson(map[ExerciseRecordColumns.video.value] as String)
          : null,
      recordDate: map[ExerciseRecordColumns.recordDate.value] as int,
      createdAt: map[ExerciseRecordColumns.createdAt.value] as int,
      updatedAt: map[ExerciseRecordColumns.updatedAt.value] as int,
    );
  }

  factory ExerciseRecord.create({
    required int exerciseId,
    required int weight,
    required int reps,
    required int recordDate,
    PictureData? picture,
    VideoData? video,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return ExerciseRecord(
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      maxStrength: MaxStrengthCalculator.calculateMaxStrength(reps, weight),
      picture: picture,
      video: video,
      recordDate: recordDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  ExerciseRecord copyWith({
    int? id,
    int? exerciseId,
    int? weight,
    int? reps,
    int? maxStrength,
    PictureData? picture,
    VideoData? video,
    int? recordDate,
    int? createdAt,
    int? updatedAt,
  }) {
    return ExerciseRecord(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      maxStrength: maxStrength ?? this.maxStrength,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExerciseRecord{id: $id, exerciseId: $exerciseId, weight: $weight, reps: $reps, maxStrength: $maxStrength, createdAt: $createdAt, updatedAt: $updatedAt}';
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
        createdAt,
        updatedAt,
      ];
}
