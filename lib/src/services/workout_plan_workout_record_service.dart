import 'package:logging/logging.dart';

import '../models/db.dart';
import '../models/repository.dart' show Repository;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_plan_workout_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/workout_plan_workout_record_dto.dart';

class WorkoutPlanWorkoutRecordService {
  WorkoutPlanWorkoutRecordService._();

  static final WorkoutPlanWorkoutRecordService instance =
      WorkoutPlanWorkoutRecordService._();

  factory WorkoutPlanWorkoutRecordService() => instance;

  final Logger _logger = Logger('Workout Plan Workout Record Service');

  final Repository<WorkoutPlanWorkoutRecord> _repository =
      Repository<WorkoutPlanWorkoutRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkoutRecord.table,
    fromMap: (map) => WorkoutPlanWorkoutRecord.fromMap(map),
  );

  Future<
      Result<List<WorkoutPlanWorkoutRecordDto>,
          ServiceError<OperationErrorTypes>>> getWorkoutPlanWorkoutRecords({
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayRecordId,
    int? workoutPlanWorkoutId,
  }) async {
    _logger.info('Getting workout plan workout records');
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

    try {
      final List<WorkoutPlanWorkoutRecord> records =
          await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'created_at ASC',
      );
      _logger.info('Got ${records.length} workout plan workout records');
      return ok(records
          .map((r) => WorkoutPlanWorkoutRecordDto.fromModel(r))
          .toList());
    } catch (e) {
      _logger.severe('Failed to get workout plan workout records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workout plan workout records',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutRecordDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanWorkoutRecord(int id) async {
    _logger.info('Getting workout plan workout record with id $id');
    try {
      final WorkoutPlanWorkoutRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan workout record not found',
        ));
      }
      _logger.info('Got workout plan workout record with id $id');
      return ok(WorkoutPlanWorkoutRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe(
          'Failed to get workout plan workout record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan workout record',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutRecordDto, ServiceError<OperationErrorTypes>>>
      createWorkoutPlanWorkoutRecord({
    required int workoutPlanRecordId,
    required int workoutPlanWeekRecordId,
    required int workoutPlanDayRecordId,
    required int workoutPlanWorkoutId,
    required int workoutRecordId,
  }) async {
    _logger.info('Creating workout plan workout record');
    try {
      final WorkoutPlanWorkoutRecord record = WorkoutPlanWorkoutRecord.create(
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayRecordId,
        workoutPlanWorkoutId,
        workoutRecordId,
      );
      final int id = await _repository.insert(record);
      _logger.info('Created workout plan workout record with id $id');
      return ok(WorkoutPlanWorkoutRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan workout record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout plan workout record',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanWorkoutRecord(
    int id, {
    int? completedAt,
  }) async {
    _logger.info('Updating workout plan workout record with id $id');
    try {
      final WorkoutPlanWorkoutRecord? record = await _repository.selectOne(id);
      if (record == null) {
        _logger.info('Workout plan workout record with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan workout record not found',
        ));
      }

      final WorkoutPlanWorkoutRecord updatedRecord = record.copyWith(
        completedAt: completedAt ?? record.completedAt,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedRecord);
      _logger.info('Updated workout plan workout record with id $id');
      return ok(WorkoutPlanWorkoutRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe(
          'Failed to update workout plan workout record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan workout record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutPlanWorkoutRecord(int id) async {
    _logger.info('Deleting workout plan workout record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan workout record not found',
        ));
      }
      _logger.info('Deleted workout plan workout record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe(
          'Failed to delete workout plan workout record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan workout record',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutRecordDto?, ServiceError<SingleErrorTypes>>>
      getWorkoutRecordForPlanWorkout(
    int workoutPlanRecordId,
    int workoutPlanWorkoutId,
  ) async {
    _logger.info('Getting workout record for plan workout');
    try {
      final recordsResult = await getWorkoutPlanWorkoutRecords(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanWorkoutId: workoutPlanWorkoutId,
      );
      if (recordsResult.isErr()) {
        return err((recordsResult as Err).error);
      }
      final records = (recordsResult as Ok).value;

      if (records.isEmpty) {
        return ok(null);
      }

      // Return the most recent one
      final dto = WorkoutPlanWorkoutRecordDto.fromModel(records.last);
      _logger.info('Got workout record for plan workout');
      return ok(dto);
    } catch (e) {
      _logger.severe('Failed to get workout record for plan workout', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout record for plan workout',
      ));
    }
  }
}
