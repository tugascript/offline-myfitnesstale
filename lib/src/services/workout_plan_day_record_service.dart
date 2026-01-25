import 'package:logging/logging.dart';

import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_day_record_model.dart';
import '../models/workout_plan_workout_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/workout_plan_day_record_dto.dart';

class WorkoutPlanDayRecordService {
  WorkoutPlanDayRecordService._();

  static final WorkoutPlanDayRecordService instance =
      WorkoutPlanDayRecordService._();

  factory WorkoutPlanDayRecordService() => instance;

  final Logger _logger = Logger('Workout Plan Day Record Service');

  final Repository<WorkoutPlanDayRecord> _repository =
      Repository<WorkoutPlanDayRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDayRecord.table,
    fromMap: (map) => WorkoutPlanDayRecord.fromMap(map),
  );

  Future<
      Result<List<WorkoutPlanDayRecordDto>,
          ServiceError<OperationErrorTypes>>> getWorkoutPlanDayRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayId,
  }) async {
    _logger.info('Getting workout plan day records');
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

    try {
      final List<WorkoutPlanDayRecord> records = await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'created_at ASC',
      );
      _logger.info('Got ${records.length} workout plan day records');
      return ok(
          records.map((r) => WorkoutPlanDayRecordDto.fromModel(r)).toList());
    } catch (e) {
      _logger.severe('Failed to get workout plan day records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workout plan day records',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanDayRecord(int id) async {
    _logger.info('Getting workout plan day record with id $id');
    try {
      final WorkoutPlanDayRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan day record not found',
        ));
      }
      _logger.info('Got workout plan day record with id $id');
      return ok(WorkoutPlanDayRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe('Failed to get workout plan day record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan day record',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto, ServiceError<OperationErrorTypes>>>
      createWorkoutPlanDayRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekRecordId,
    required int workoutPlanDayId,
  }) async {
    _logger.info('Creating workout plan day record');
    try {
      final WorkoutPlanDayRecord record = WorkoutPlanDayRecord.create(
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayId,
      );
      final int id = await _repository.insert(record);
      _logger.info('Created workout plan day record with id $id');
      return ok(WorkoutPlanDayRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan day record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout plan day record',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanDayRecord(
    int id, {
    int? completedAt,
  }) async {
    _logger.info('Updating workout plan day record with id $id');
    try {
      final WorkoutPlanDayRecord? record = await _repository.selectOne(id);
      if (record == null) {
        _logger.info('Workout plan day record with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan day record not found',
        ));
      }

      final WorkoutPlanDayRecord updatedRecord = record.copyWith(
        completedAt: completedAt ?? record.completedAt,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedRecord);
      _logger.info('Updated workout plan day record with id $id');
      return ok(WorkoutPlanDayRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to update workout plan day record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan day record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutPlanDayRecord(int id) async {
    _logger.info('Deleting workout plan day record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan day record not found',
        ));
      }
      _logger.info('Deleted workout plan day record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout plan day record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan day record',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto?, ServiceError<SingleErrorTypes>>>
      getTodaysWorkoutPlanDayRecord(
    int workoutPlanRecordId,
  ) async {
    _logger.info('Getting today\'s workout plan day record');
    try {
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
        return ok(null);
      }

      final record = WorkoutPlanDayRecord.fromMap(maps.first);
      _logger.info('Got today\'s workout plan day record');
      return ok(WorkoutPlanDayRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe('Failed to get today\'s workout plan day record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get today\'s workout plan day record',
      ));
    }
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
