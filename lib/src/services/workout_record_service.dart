import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_record_model.dart';

class WorkoutRecordService {
  WorkoutRecordService._();

  static final WorkoutRecordService instance = WorkoutRecordService._();

  factory WorkoutRecordService() => instance;

  final Repository<WorkoutRecord> _repository = Repository<WorkoutRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutRecord.table,
    fromMap: (map) => WorkoutRecord.fromMap(map),
  );

  Future<List<WorkoutRecord>> getWorkoutRecords({
    int? workoutId,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutId != null) {
      query.add('workout_id = ?', workoutId);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
      orderBy: 'started_at DESC',
    );
  }

  Future<WorkoutRecord?> getWorkoutRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutRecord> createWorkoutRecord({
    required int workoutId,
    required int totalSets,
    required int totalReps,
    required int totalRestSecs,
    required int startedAt,
    required double weight,
    required int reps,
  }) async {
    final WorkoutRecord record = WorkoutRecord.create(
      workoutId,
      totalSets,
      totalReps,
      totalRestSecs,
      startedAt,
      weight,
      reps,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutRecord?> updateWorkoutRecord(
    int id, {
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? completedAt,
    double? weight,
    int? reps,
  }) async {
    final WorkoutRecord? record = await getWorkoutRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutRecord updatedRecord = record.copyWith(
      totalSets: totalSets,
      totalReps: totalReps,
      totalRestSecs: totalRestSecs,
      completedAt: completedAt,
      weight: weight,
      reps: reps,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WorkoutRecord?> completeWorkoutRecord(int id) async {
    final int completedAt = DateUtilities.getNowUtcUnix();
    return await updateWorkoutRecord(id, completedAt: completedAt);
  }
}
