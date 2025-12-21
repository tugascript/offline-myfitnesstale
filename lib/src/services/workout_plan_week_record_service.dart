import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_plan_week_record_model.dart';

class WorkoutPlanWeekRecordService {
  WorkoutPlanWeekRecordService._();

  static final WorkoutPlanWeekRecordService instance =
      WorkoutPlanWeekRecordService._();

  factory WorkoutPlanWeekRecordService() => instance;

  final Repository<WorkoutPlanWeekRecord> _repository =
      Repository<WorkoutPlanWeekRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeekRecord.table,
    fromMap: (map) => WorkoutPlanWeekRecord.fromMap(map),
  );

  Future<List<WorkoutPlanWeekRecord>> getWorkoutPlanWeekRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanRecordId != null) {
      query.add('workout_plan_record_id = ?', workoutPlanRecordId);
    }

    if (workoutPlanWeekId != null) {
      query.add('workout_plan_week_id = ?', workoutPlanWeekId);
    }

    return await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'week ASC',
    );
  }

  Future<WorkoutPlanWeekRecord?> getWorkoutPlanWeekRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutPlanWeekRecord> createWorkoutPlanWeekRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekId,
    required int week,
  }) async {
    final WorkoutPlanWeekRecord record = WorkoutPlanWeekRecord.create(
      workoutPlanRecordId,
      workoutPlanWeekId,
      week,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutPlanWeekRecord?> updateWorkoutPlanWeekRecord(
    int id, {
    int? completedAt,
  }) async {
    final WorkoutPlanWeekRecord? record = await getWorkoutPlanWeekRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutPlanWeekRecord updatedRecord = record.copyWith(
      completedAt: completedAt ?? record.completedAt,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutPlanWeekRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<int> getCompletedWeeksCount(int workoutPlanRecordId) async {
    final List<WorkoutPlanWeekRecord> records = await getWorkoutPlanWeekRecords(
        workoutPlanRecordId: workoutPlanRecordId);
    return records.where((r) => r.completedAt != null).length;
  }

  Future<double> getWeekProgressPercentage(
    int workoutPlanRecordId,
    int totalWeeks,
  ) async {
    if (totalWeeks == 0) {
      return 0.0;
    }

    final int completed = await getCompletedWeeksCount(workoutPlanRecordId);
    return (completed / totalWeeks) * 100.0;
  }
}
