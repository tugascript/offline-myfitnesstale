import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_set_exercise_record_model.dart';

class WorkoutSetExerciseRecordService {
  WorkoutSetExerciseRecordService._();

  static final WorkoutSetExerciseRecordService instance =
      WorkoutSetExerciseRecordService._();

  factory WorkoutSetExerciseRecordService() => instance;

  final Repository<WorkoutSetExerciseRecord> _repository =
      Repository<WorkoutSetExerciseRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExerciseRecord.table,
    fromMap: (map) => WorkoutSetExerciseRecord.fromMap(map),
  );

  Future<List<WorkoutSetExerciseRecord>> getWorkoutSetExerciseRecords({
    int? workoutSetExerciseId,
    int? workoutSetProgressId,
    int? exerciseId,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutSetExerciseId != null) {
      query.add('workout_set_exercise_id = ?', workoutSetExerciseId);
    }

    if (workoutSetProgressId != null) {
      query.add('workout_set_progress_id = ?', workoutSetProgressId);
    }

    if (exerciseId != null) {
      query.add('exercise_id = ?', exerciseId);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
    );
  }

  Future<WorkoutSetExerciseRecord?> getWorkoutSetExerciseRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutSetExerciseRecord> createWorkoutSetExerciseRecord({
    required int workoutSetExerciseId,
    required int workoutSetProgressId,
    required int exerciseId,
    required int reps,
    required int weightGrams,
    int? difficulty,
    String? difficultyType,
  }) async {
    final WorkoutSetExerciseRecord record = WorkoutSetExerciseRecord.create(
      workoutSetExerciseId,
      workoutSetProgressId,
      exerciseId,
      reps,
      weightGrams,
      difficulty,
      difficultyType,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutSetExerciseRecord?> updateWorkoutSetExerciseRecord(
    int id, {
    int? reps,
    int? weightGrams,
    int? difficulty,
    String? difficultyType,
  }) async {
    final WorkoutSetExerciseRecord? record =
        await getWorkoutSetExerciseRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutSetExerciseRecord updatedRecord = record.copyWith(
      reps: reps,
      weightGrams: weightGrams,
      difficulty: difficulty,
      difficultyType: difficultyType,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutSetExerciseRecord(int id) async {
    return await _repository.deleteOne(id);
  }
}
