import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/current_workout_plan_record_model.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart'
    show Repository, kDefaultLimit, kDefaultOffset;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_plan_record_model.dart';
import '../models/workout_plan_workout_model.dart';
import '../models/workout_plan_workout_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_plan_record_dto.dart';

class WorkoutPlanRecordService {
  WorkoutPlanRecordService._();

  static final WorkoutPlanRecordService instance = WorkoutPlanRecordService._();

  factory WorkoutPlanRecordService() => instance;

  final Logger _logger = Logger('Workout Plan Record Service');

  final Repository<WorkoutPlanRecord> _repository =
      Repository<WorkoutPlanRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanRecord.table,
    fromMap: (map) => WorkoutPlanRecord.fromMap(map),
  );

  final Repository<CurrentWorkoutPlanRecord> _currentRepository =
      Repository<CurrentWorkoutPlanRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: CurrentWorkoutPlanRecord.table,
    fromMap: (map) => CurrentWorkoutPlanRecord.fromMap(map),
  );

  Future<
      Result<PaginatedDto<WorkoutPlanRecordDto, WorkoutPlanRecord>,
          ServiceError<OperationErrorTypes>>> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? status,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout plan records');
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanId != null) {
      query.and('workout_plan_id = ?', workoutPlanId);
    }

    if (status != null) {
      query.and('status = ?', status.value);
    }

    try {
      final List<WorkoutPlanRecord> records = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: 'created_at DESC',
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${records.length} workout plan records');
      return ok(PaginatedDto<WorkoutPlanRecordDto, WorkoutPlanRecord>.mapData(
        data: records,
        mapper: (record) => WorkoutPlanRecordDto.fromModel(record),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get workout plan records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workout plan records',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanRecord(int id) async {
    _logger.info('Getting workout plan record with id $id');
    try {
      final WorkoutPlanRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }
      _logger.info('Got workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe('Failed to get workout plan record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<OperationErrorTypes>>>
      createWorkoutPlanRecord({
    required int workoutPlanId,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    _logger.info('Creating workout plan record');
    try {
      final WorkoutPlanRecord record = WorkoutPlanRecord.create(
        workoutPlanId,
        status: status,
      );
      final int id = await _repository.insert(record);
      _logger.info('Created workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout plan record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanRecord(
    int id, {
    ProgressStatus? status,
    int? completedAt,
  }) async {
    _logger.info('Updating workout plan record with id $id');
    try {
      final WorkoutPlanRecord? record = await _repository.selectOne(id);
      if (record == null) {
        _logger.info('Workout plan record with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }

      final WorkoutPlanRecord updatedRecord = record.copyWith(
        status: status,
        completedAt: completedAt,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedRecord);
      _logger.info('Updated workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to update workout plan record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutPlanRecord(
    int id,
  ) async {
    _logger.info('Deleting workout plan record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }
      _logger.info('Deleted workout plan record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout plan record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto?, ServiceError<SingleErrorTypes>>>
      getActivePlanRecord(int workoutPlanId) async {
    _logger.info('Getting active plan record for workout plan $workoutPlanId');
    try {
      final List<WorkoutPlanRecord> records = await _repository.selectMany(
        where: 'workout_plan_id = ? AND status = ?',
        whereArgs: [workoutPlanId, ProgressStatus.inProgress.value],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      final WorkoutPlanRecordDto? dto = records.isNotEmpty
          ? WorkoutPlanRecordDto.fromModel(records.first)
          : null;
      _logger.info('Got active plan record');
      return ok(dto);
    } catch (e) {
      _logger.severe('Failed to get active plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get active plan record',
      ));
    }
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

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      getCurrentWorkoutPlanRecord() async {
    _logger.info('Getting current workout plan record');
    try {
      final CurrentWorkoutPlanRecord? current =
          await _currentRepository.selectLatest();
      if (current == null) {
        _logger.info('No current workout plan record found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No current workout plan record found',
        ));
      }

      final WorkoutPlanRecord? record = await _repository.selectOne(
        current.workoutPlanRecordId,
      );

      if (record == null) {
        _logger.info(
          'No workout plan record found with id: ${current.workoutPlanRecordId}',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No workout plan record found',
        ));
      }

      _logger.info('Current workout plan record found with id ${current.id}');
      return ok(WorkoutPlanRecordDto.fromModel(record));
    } catch (e) {
      _logger.severe('Failed to get current workout plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get current workout plan record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      clearCurrentWorkoutPlanRecord() async {
    _logger.info('Clearing current workout plan record');
    try {
      final CurrentWorkoutPlanRecord? current =
          await _currentRepository.selectLatest();
      if (current == null) {
        _logger.info('No current workout plan record found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No current workout plan record found',
        ));
      }

      final bool deleted = await _currentRepository.deleteOne(current.id!);
      if (!deleted) {
        _logger.info('Failed to delete current workout plan record');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete current workout plan record',
        ));
      }

      _logger.info('Cleared current workout plan record with id ${current.id}');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to clear current workout plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to clear current workout plan record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      setCurrentWorkoutPlan(
    int workoutPlanRecordId,
  ) async {
    _logger.info(
        'Setting current workout plan record with id $workoutPlanRecordId');
    try {
      final WorkoutPlanRecord? existing =
          await _repository.selectOne(workoutPlanRecordId);
      if (existing == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout plan record with id $workoutPlanRecordId not found',
        ));
      }

      final CurrentWorkoutPlanRecord? current =
          await _currentRepository.selectLatest();
      if (current != null) {
        final CurrentWorkoutPlanRecord updated = current.copyWith(
          workoutPlanRecordId: workoutPlanRecordId,
          workoutPlanId: existing.workoutPlanId,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _currentRepository.update(updated);
        _logger.info('Updated current workout plan record');
        return ok(WorkoutPlanRecordDto.fromModel(existing));
      }

      final CurrentWorkoutPlanRecord created = CurrentWorkoutPlanRecord.create(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanId: existing.workoutPlanId,
      );
      final int id = await _currentRepository.insert(created);
      _logger.info('Created current workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(existing));
    } catch (e) {
      _logger.severe('Failed to set current workout plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to set current workout plan record',
      ));
    }
  }
}
