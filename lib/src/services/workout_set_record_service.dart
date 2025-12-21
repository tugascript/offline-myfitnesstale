import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_set_record_model.dart';

class WorkoutSetRecordService {
  WorkoutSetRecordService._();

  static final WorkoutSetRecordService instance = WorkoutSetRecordService._();

  factory WorkoutSetRecordService() => instance;

  final Repository<WorkoutSetRecord> _repository = Repository<WorkoutSetRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetRecord.table,
    fromMap: (map) => WorkoutSetRecord.fromMap(map),
  );

  Future<List<WorkoutSetRecord>> getWorkoutSetRecords({
    int? workoutSetId,
    int? workoutProgressId,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutSetId != null) {
      query.add('workout_set_id = ?', workoutSetId);
    }

    if (workoutProgressId != null) {
      query.add('workout_progress_id = ?', workoutProgressId);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
      orderBy: 'set_number ASC',
    );
  }

  Future<WorkoutSetRecord?> getWorkoutSetRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutSetRecord> createWorkoutSetRecord({
    required int workoutSetId,
    required int workoutProgressId,
    required int setNumber,
    required int totalRestSecs,
    required int startedAt,
  }) async {
    final WorkoutSetRecord record = WorkoutSetRecord.create(
      workoutSetId,
      workoutProgressId,
      setNumber,
      totalRestSecs,
      startedAt,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutSetRecord?> updateWorkoutSetRecord(
    int id, {
    int? totalRestSecs,
    int? completedAt,
  }) async {
    final WorkoutSetRecord? record = await getWorkoutSetRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutSetRecord updatedRecord = record.copyWith(
      totalRestSecs: totalRestSecs,
      completedAt: completedAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutSetRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WorkoutSetRecord?> completeWorkoutSetRecord(int id) async {
    final int completedAt = DateUtilities.getNowUtcUnix();
    return await updateWorkoutSetRecord(id, completedAt: completedAt);
  }
}
