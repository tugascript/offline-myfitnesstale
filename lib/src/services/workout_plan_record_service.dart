import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_plan_record.dart';
import '../models/workout_plan_workout_model.dart';
import '../models/workout_plan_workout_record_model.dart';

class WorkoutPlanRecordService {
  WorkoutPlanRecordService._();

  static final WorkoutPlanRecordService instance = WorkoutPlanRecordService._();

  factory WorkoutPlanRecordService() => instance;

  final _repository = Repository<WorkoutPlanRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanRecord.table,
    fromMap: (map) => WorkoutPlanRecord.fromMap(map),
  );

  Future<List<WorkoutPlanRecord>> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? status,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanId != null) {
      query.add('workout_plan_id = ?', workoutPlanId);
    }

    if (status != null) {
      query.add('status = ?', status.value);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
      orderBy: 'created_at DESC',
    );
  }

  Future<WorkoutPlanRecord?> getWorkoutPlanRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutPlanRecord> createWorkoutPlanRecord({
    required int workoutPlanId,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    final WorkoutPlanRecord record = WorkoutPlanRecord.create(
      workoutPlanId,
      status: status,
    );
    final int id = await _repository.insert(record);
    return record.copyWith(id: id);
  }

  Future<WorkoutPlanRecord?> updateWorkoutPlanRecord(
    int id, {
    ProgressStatus? status,
    int? completedAt,
  }) async {
    final WorkoutPlanRecord? record = await getWorkoutPlanRecord(id);
    if (record == null) {
      return null;
    }

    final WorkoutPlanRecord updatedRecord = record.copyWith(
      status: status,
      completedAt: completedAt,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedRecord);

    return updatedRecord;
  }

  Future<bool> deleteWorkoutPlanRecord(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WorkoutPlanRecord?> getActivePlanRecord(int workoutPlanId) async {
    final List<WorkoutPlanRecord> records = await _repository.selectMany(
      where: 'workout_plan_id = ? AND status = ?',
      whereArgs: [workoutPlanId, ProgressStatus.inProgress.value],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (records.isEmpty) {
      return null;
    }

    return records.first;
  }

  Future<int> getCompletedWorkoutsCount(int workoutPlanRecordId) async {
    final db = await DatabaseHelper().db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${WorkoutPlanWorkoutRecord.table}
      WHERE workout_plan_record_id = ? AND completed_at IS NOT NULL
      ''',
      [workoutPlanRecordId],
    );

    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future<int> getTotalWorkoutsCount(int workoutPlanId) async {
    final db = await DatabaseHelper().db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${WorkoutPlanWorkout.table}
      WHERE workout_plan_id = ?
      ''',
      [workoutPlanId],
    );

    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future<double> getPlanProgressPercentage(
    int workoutPlanRecordId,
    int workoutPlanId,
  ) async {
    final int completed = await getCompletedWorkoutsCount(workoutPlanRecordId);
    final int total = await getTotalWorkoutsCount(workoutPlanId);

    if (total == 0) {
      return 0.0;
    }

    return (completed / total) * 100.0;
  }
}
