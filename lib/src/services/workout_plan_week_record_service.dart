import 'package:logging/logging.dart';

import '../models/db.dart';
import '../models/repository.dart' show Repository;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_plan_week_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/workout_plan_week_record_dto.dart';

class WorkoutPlanWeekRecordService {
  WorkoutPlanWeekRecordService._();

  static final WorkoutPlanWeekRecordService instance =
      WorkoutPlanWeekRecordService._();

  factory WorkoutPlanWeekRecordService() => instance;

  final Logger _logger = Logger('Workout Plan Week Record Service');

  final Repository<WorkoutPlanWeekRecord> _repository =
      Repository<WorkoutPlanWeekRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeekRecord.table,
    fromMap: (map) => WorkoutPlanWeekRecord.fromMap(map),
  );

  Future<
      Result<List<WorkoutPlanWeekRecordDto>,
          ServiceError<OperationErrorTypes>>> getWorkoutPlanWeekRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
  }) async {
    _logger.info('Getting workout plan week records');
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanRecordId != null) {
      query.and('workout_plan_record_id = ?', workoutPlanRecordId);
    }

    if (workoutPlanWeekId != null) {
      query.and('workout_plan_week_id = ?', workoutPlanWeekId);
    }

    try {
      final List<WorkoutPlanWeekRecord> records = await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'week ASC',
      );
      _logger.info('Got ${records.length} workout plan week records');
      return ok(
          records.map((r) => WorkoutPlanWeekRecordDto.fromModel(r)).toList());
    } catch (e) {
      _logger.severe('Failed to get workout plan week records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workout plan week records',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekRecordDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanWeekRecord(int id) async {
    _logger.info('Getting workout plan week record with id $id');
    try {
      final WorkoutPlanWeekRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week record not found',
        ));
      }
      _logger.info('Got workout plan week record with id $id');
      return ok(WorkoutPlanWeekRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe('Failed to get workout plan week record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan week record',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekRecordDto, ServiceError<OperationErrorTypes>>>
      createWorkoutPlanWeekRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekId,
    required int week,
  }) async {
    _logger.info('Creating workout plan week record');
    try {
      final WorkoutPlanWeekRecord record = WorkoutPlanWeekRecord.create(
        workoutPlanRecordId,
        workoutPlanWeekId,
        week,
      );
      final int id = await _repository.insert(record);
      _logger.info('Created workout plan week record with id $id');
      return ok(WorkoutPlanWeekRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan week record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout plan week record',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanWeekRecord(
    int id, {
    int? completedAt,
  }) async {
    _logger.info('Updating workout plan week record with id $id');
    try {
      final WorkoutPlanWeekRecord? record = await _repository.selectOne(id);
      if (record == null) {
        _logger.info('Workout plan week record with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week record not found',
        ));
      }

      final WorkoutPlanWeekRecord updatedRecord = record.copyWith(
        completedAt: completedAt ?? record.completedAt,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedRecord);
      _logger.info('Updated workout plan week record with id $id');
      return ok(WorkoutPlanWeekRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe(
          'Failed to update workout plan week record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan week record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutPlanWeekRecord(int id) async {
    _logger.info('Deleting workout plan week record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week record not found',
        ));
      }
      _logger.info('Deleted workout plan week record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe(
          'Failed to delete workout plan week record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan week record',
      ));
    }
  }

  Future<Result<int, ServiceError<OperationErrorTypes>>> getCompletedWeeksCount(
      int workoutPlanRecordId) async {
    _logger.info('Getting completed weeks count');
    try {
      final recordsResult = await getWorkoutPlanWeekRecords(
          workoutPlanRecordId: workoutPlanRecordId);
      if (recordsResult.isErr()) {
        return err(const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get workout plan week records',
        ));
      }
      final records = (recordsResult as Ok).value;
      final count = records.where((r) => r.completedAt != null).length;
      return ok(count);
    } catch (e) {
      _logger.severe('Failed to get completed weeks count', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get completed weeks count',
      ));
    }
  }

  Future<Result<double, ServiceError<OperationErrorTypes>>>
      getWeekProgressPercentage(
    int workoutPlanRecordId,
    int totalWeeks,
  ) async {
    _logger.info('Getting week progress percentage');
    try {
      if (totalWeeks == 0) {
        return ok(0.0);
      }

      final completedResult = await getCompletedWeeksCount(workoutPlanRecordId);
      if (completedResult.isErr()) {
        return err(const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get completed weeks count',
        ));
      }
      final completed = (completedResult as Ok).value;
      final percentage = (completed / totalWeeks) * 100.0;
      return ok(percentage);
    } catch (e) {
      _logger.severe('Failed to get week progress percentage', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get week progress percentage',
      ));
    }
  }
}
