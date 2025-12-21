import 'enums.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'muscle_model.dart';
import 'utilities.dart';

const String _table = 'exercise_muscles';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    exercise_id INTEGER NOT NULL,
    muscle_id INTEGER NOT NULL,
    text CATEGORY NOT NULL,
    created_at INTEGER NOT NULL,
    PRIMARY KEY (exercise_id, muscle_id),
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (muscle_id) REFERENCES ${Muscle.table} (id)
      ON DELETE CASCADE
  );
  ''';

class ExerciseMuscle implements JoinModel {
  final int exerciseId;
  final int muscleId;
  final ExerciseMuscleCategory category;
  @override
  final int createdAt;

  const ExerciseMuscle({
    required this.exerciseId,
    required this.muscleId,
    required this.category,
    required this.createdAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;
  static const (String, String) primaryKeys = ('exercise_id', 'muscle_id');

  @override
  Map<String, Object?> toMap() {
    return {
      'exercise_id': exerciseId,
      'muscle_id': muscleId,
      'category': category,
      'created_at': createdAt,
    };
  }

  @override
  factory ExerciseMuscle.fromMap(Map<String, Object?> map) {
    return ExerciseMuscle(
      exerciseId: map['exercise_id'] as int,
      muscleId: map['muscle_id'] as int,
      category: ExerciseMuscleCategory.fromValue(
        map['category'] as String,
      ),
      createdAt: map['created_at'] as int,
    );
  }

  @override
  factory ExerciseMuscle.create(
    int exerciseId,
    int muscleId,
    ExerciseMuscleCategory category,
  ) {
    return ExerciseMuscle(
      exerciseId: exerciseId,
      muscleId: muscleId,
      category: category,
      createdAt: DateUtilities.getNowUtcUnix(),
    );
  }

  @override
  ExerciseMuscle copyWith({
    int? exerciseId,
    int? muscleId,
    ExerciseMuscleCategory? category,
    int? createdAt,
  }) {
    return ExerciseMuscle(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ExerciseMuscle{exerciseId: $exerciseId, muscleId: $muscleId, category: $category, createdAt: $createdAt}';
  }
}
