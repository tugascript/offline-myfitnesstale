import 'package:equatable/equatable.dart';

import 'common.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'exercise_records';
const String _tableCreate = """
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    exercise_id INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    max_strength INTEGER NOT NULL,
    picture TEXT,
    video TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_records_exercise_id ON $_table (exercise_id);
  """;

enum ExerciseRecordColumns {
  id("id"),
  exerciseId("exercise_id"),
  weight("weight"),
  reps("reps"),
  maxStrength("max_strength"),
  picture("picture"),
  video("video"),
  createdAt("created_at"),
  updatedAt("updated_at");

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
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      ExerciseRecordColumns.id.value: id,
      ExerciseRecordColumns.exerciseId.value: exerciseId,
      ExerciseRecordColumns.weight.value: weight,
      ExerciseRecordColumns.reps.value: reps,
      ExerciseRecordColumns.maxStrength.value: maxStrength,
      ExerciseRecordColumns.picture.value: picture,
      ExerciseRecordColumns.video.value: video,
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
      createdAt: map[ExerciseRecordColumns.createdAt.value] as int,
      updatedAt: map[ExerciseRecordColumns.updatedAt.value] as int,
    );
  }

  factory ExerciseRecord.create({
    required int exerciseId,
    required int weight,
    required int reps,
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
        createdAt,
        updatedAt,
      ];
}
