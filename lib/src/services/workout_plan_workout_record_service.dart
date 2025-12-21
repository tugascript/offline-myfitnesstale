import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_plan_workout_record_model.dart';

class WorkoutPlanWorkoutRecordService {
  WorkoutPlanWorkoutRecordService._();

  static final WorkoutPlanWorkoutRecordService instance =
      WorkoutPlanWorkoutRecordService._();

  factory WorkoutPlanWorkoutRecordService() => instance;

  final Repository<WorkoutPlanWorkoutRecord> _repository =
      Repository<WorkoutPlanWorkoutRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkoutRecord.table,
    fromMap: (map) => WorkoutPlanWorkoutRecord.fromMap(map),
  );

  Future<List<WorkoutPlanWorkoutRecord>> getWorkoutPlanWorkoutRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayRecordId,
    int? workoutPlanWorkoutId,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanRecordId != null) {
      query.add('workout_plan_record_id = ?', workoutPlanRecordId);
    }

    if (workoutPlanWeekRecordId != null) {
      query.add('workout_plan_week_record_id = ?', workoutPlanWeekRecordId);
    }

    if (workoutPlanDayRecordId != null) {
      query.add('workout_plan_day_record_id = ?', workoutPlanDayRecordId);
    }

    if (workoutPlanWorkoutId != null) {
      query.add('workout_plan_workout_id = ?', workoutPlanWorkoutId);
    }

    return await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'created_at ASC',
    );
  }

  Future<WorkoutPlanWorkoutRecord?> getWorkoutPlanWorkoutRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutPlanWorkoutRecord> createWorkoutPlanWorkoutRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekRecordId,
    required int workoutPlanDayRecordId,
    required int workoutPlanWorkoutId,
    required int workoutRecordId,
  }) async {
    final WorkoutPlanWorkoutRecord record = WorkoutPlanWorkoutRecord.create(
      workoutPlanRecordId,
      workoutPlanWeekRecordId,
      workoutPlanDayRecordId,
      workoutPlanWorkoutId,
      workoutRecordId,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutPlanWorkoutRecord?> updateWorkoutPlanWorkoutRecord(
    int id, {
    int? completedAt,
  }) async {
    final WorkoutPlanWorkoutRecord? record =
        await getWorkoutPlanWorkoutRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutPlanWorkoutRecord updatedRecord = record.copyWith(
      completedAt: completedAt ?? record.completedAt,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutPlanWorkoutRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WorkoutPlanWorkoutRecord?> getWorkoutRecordForPlanWorkout(
    int workoutPlanRecordId,
    int workoutPlanWorkoutId,
  ) async {
    final List<WorkoutPlanWorkoutRecord> records =
        await getWorkoutPlanWorkoutRecords(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId,
    );

    if (records.isEmpty) {
      return null;
    }

    // Return the most recent one
    return records.last;
  }
}
