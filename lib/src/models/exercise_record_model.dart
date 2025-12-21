import 'package:equatable/equatable.dart';

import 'enums.dart';
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
    picture_uri TEXT,
    video_uri TEXT,
    video_platform TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_records_exercise_id ON $_table (exercise_id);
  """;

class ExerciseRecord extends Equatable implements Model {
  @override
  final int? id;
  final int exerciseId;
  final int weight;
  final int reps;
  final int maxStrength;
  final String? pictureUri;
  final String? videoUri;
  final VideoPlatform? videoPlatform;
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
    this.pictureUri,
    this.videoUri,
    this.videoPlatform,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'max_strength': maxStrength,
      'picture_uri': pictureUri,
      'video_uri': videoUri,
      'video_platform': videoPlatform?.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory ExerciseRecord.fromMap(Map<String, Object?> map) {
    return ExerciseRecord(
      id: map['id'] as int?,
      exerciseId: map['exercise_id'] as int,
      weight: map['weight'] as int,
      reps: map['reps'] as int,
      maxStrength: map['max_strength'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  factory ExerciseRecord.create({
    required int exerciseId,
    required int weight,
    required int reps,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return ExerciseRecord(
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      maxStrength: MaxStrengthCalculator.calculateMaxStrength(reps, weight),
      pictureUri: pictureUri,
      videoUri: videoData?.$2,
      videoPlatform: videoData?.$1,
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
    String? pictureUri,
    String? videoUri,
    VideoPlatform? videoPlatform,
    int? createdAt,
    int? updatedAt,
  }) {
    return ExerciseRecord(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      maxStrength: maxStrength ?? this.maxStrength,
      pictureUri: pictureUri ?? this.pictureUri,
      videoUri: videoUri ?? this.videoUri,
      videoPlatform: videoPlatform ?? this.videoPlatform,
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
        pictureUri,
        videoUri,
        videoPlatform,
        createdAt,
        updatedAt,
      ];
}
