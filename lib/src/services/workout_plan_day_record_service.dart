import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_day_record_model.dart';
import '../models/workout_plan_workout_model.dart';

class WorkoutPlanDayRecordService {
  WorkoutPlanDayRecordService._();

  static final WorkoutPlanDayRecordService instance =
      WorkoutPlanDayRecordService._();

  factory WorkoutPlanDayRecordService() => instance;

  final Repository<WorkoutPlanDayRecord> _repository =
      Repository<WorkoutPlanDayRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDayRecord.table,
    fromMap: (map) => WorkoutPlanDayRecord.fromMap(map),
  );

  Future<List<WorkoutPlanDayRecord>> getWorkoutPlanDayRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayId,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanRecordId != null) {
      query.add('workout_plan_record_id = ?', workoutPlanRecordId);
    }

    if (workoutPlanWeekRecordId != null) {
      query.add('workout_plan_week_record_id = ?', workoutPlanWeekRecordId);
    }

    if (workoutPlanDayId != null) {
      query.add('workout_plan_day_id = ?', workoutPlanDayId);
    }

    return await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'created_at ASC',
    );
  }

  Future<WorkoutPlanDayRecord?> getWorkoutPlanDayRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutPlanDayRecord> createWorkoutPlanDayRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekRecordId,
    required int workoutPlanDayId,
  }) async {
    final WorkoutPlanDayRecord record = WorkoutPlanDayRecord.create(
      workoutPlanRecordId,
      workoutPlanWeekRecordId,
      workoutPlanDayId,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutPlanDayRecord?> updateWorkoutPlanDayRecord(
    int id, {
    int? completedAt,
  }) async {
    final WorkoutPlanDayRecord? record = await getWorkoutPlanDayRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutPlanDayRecord updatedRecord = record.copyWith(
      completedAt: completedAt ?? record.completedAt,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutPlanDayRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WorkoutPlanDayRecord?> getTodaysWorkoutPlanDayRecord(
    int workoutPlanRecordId,
  ) async {
    final db = await DatabaseHelper().db;

    // Get today's date (day of week, 1-7)
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1 = Monday, 7 = Sunday

    // Query to find today's workout plan day
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT dr.*
      FROM ${WorkoutPlanDayRecord.table} dr
      INNER JOIN ${WorkoutPlanDay.table} d ON d.id = dr.workout_plan_day_id
      WHERE dr.workout_plan_record_id = ? AND d.day = ?
      ORDER BY dr.created_at DESC
      LIMIT 1
      ''',
      [workoutPlanRecordId, dayOfWeek],
    );

    if (maps.isEmpty) {
      return null;
    }

    return WorkoutPlanDayRecord.fromMap(maps.first);
  }

  Future<List<Workout>> getTodaysWorkouts(int workoutPlanRecordId) async {
    final db = await DatabaseHelper().db;

    // Get today's date (day of week, 1-7)
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1 = Monday, 7 = Sunday

    // Query to find today's workouts
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT w.*
      FROM ${WorkoutPlanWorkout.table} wpw
      INNER JOIN ${WorkoutPlanDay.table} d ON d.id = wpw.workout_plan_day_id
      INNER JOIN ${Workout.table} w ON w.id = wpw.workout_id
      INNER JOIN ${WorkoutPlanDayRecord.table} dr ON dr.workout_plan_day_id = d.id
      WHERE dr.workout_plan_record_id = ? AND d.day = ?
      ORDER BY wpw.position ASC
      ''',
      [workoutPlanRecordId, dayOfWeek],
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }
}
