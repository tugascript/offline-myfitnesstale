import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart'
    show Repository, kDefaultLimit, kDefaultOffset;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_day_record_model.dart';
import '../models/workout_plan_model.dart';
import '../models/workout_plan_record_model.dart';
import '../models/workout_plan_week_model.dart';
import '../models/workout_plan_week_record_model.dart';
import '../models/workout_plan_workout_model.dart';
import '../models/workout_plan_workout_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_plan_day_record_dto.dart';
import 'dtos/workout_plan_record_dto.dart';
import 'dtos/workout_plan_week_record_dto.dart';
import 'dtos/workout_plan_workout_record_dto.dart';

class WorkoutPlanRecordService {
  WorkoutPlanRecordService._();

  static final WorkoutPlanRecordService instance = WorkoutPlanRecordService._();

  factory WorkoutPlanRecordService() => instance;

  final Logger _logger = Logger('Workout Plan Record Service');

  final _repository = Repository<WorkoutPlanRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanRecord.table,
    fromMap: (map) => WorkoutPlanRecord.fromMap(map),
  );

  final _workoutPlanWeekRecordRepository = Repository<WorkoutPlanWeekRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeekRecord.table,
    fromMap: (map) => WorkoutPlanWeekRecord.fromMap(map),
  );
  final _workoutPlanDayRecordRepository = Repository<WorkoutPlanDayRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDayRecord.table,
    fromMap: (map) => WorkoutPlanDayRecord.fromMap(map),
  );
  final _workoutPlanWorkoutRecordRepository =
      Repository<WorkoutPlanWorkoutRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkoutRecord.table,
    fromMap: (map) => WorkoutPlanWorkoutRecord.fromMap(map),
  );

  final _workoutPlanRepository = Repository<WorkoutPlan>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlan.table,
    fromMap: (map) => WorkoutPlan.fromMap(map),
  );
  final _workoutPlanWeekRepository = Repository<WorkoutPlanWeek>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeek.table,
    fromMap: (map) => WorkoutPlanWeek.fromMap(map),
  );
  final _workoutPlanDayRepository = Repository<WorkoutPlanDay>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDay.table,
    fromMap: (map) => WorkoutPlanDay.fromMap(map),
  );
  final _workoutPlanWorkoutRepository = Repository<WorkoutPlanWorkout>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkout.table,
    fromMap: (map) => WorkoutPlanWorkout.fromMap(map),
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
        orderBy: [WorkoutPlanRecordColumns.createdAt.orderDesc],
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

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      createWorkoutPlanRecord({
    required int workoutPlanId,
    ProgressStatus status = ProgressStatus.inProgress,
    DateTime? startedAt,
  }) async {
    _logger.info('Creating workout plan record');
    try {
      final workoutPlan = await _workoutPlanRepository.selectOne(workoutPlanId);
      if (workoutPlan == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan not found',
        ));
      }

      final weekWhere = WhereBuilder();
      weekWhere.and(WorkoutPlanWeekColumns.workoutPlanId.equal, workoutPlanId);
      weekWhere.and(
          WorkoutPlanWeekColumns.planVersion.equal, workoutPlan.version);
      final List<WorkoutPlanWeek> weeks =
          await _workoutPlanWeekRepository.selectMany(
        where: weekWhere.where,
        whereArgs: weekWhere.args,
        orderBy: [WorkoutPlanWeekColumns.startWeek.orderAsc],
        limit: 1,
      );
      if (weeks.isEmpty) {
        _logger.info('No weeks found for workout plan $workoutPlanId');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No weeks found for workout plan',
        ));
      }

      final WorkoutPlanRecord record = WorkoutPlanRecord.create(
        workoutPlanId,
        workoutPlanVersion: workoutPlan.version,
        status: status,
        startedAt: startedAt != null
            ? DateUtilities.getDateUnix(startedAt)
            : DateUtilities.getNowUtcUnix(),
        currentWeek: 1,
        currentDay: 1,
        currentWorkoutPosition: 1,
      );
      if (status != ProgressStatus.inProgress) {
        final int id = await _repository.insert(record);
        _logger.info('Created workout plan record with id $id');
        return ok(WorkoutPlanRecordDto.fromModel(record.copyWith(id: id)));
      }

      final List<WorkoutPlanRecord> records = await _repository.selectMany(
        where: WorkoutPlanRecordColumns.status.equal,
        whereArgs: [ProgressStatus.inProgress.value],
      );
      if (records.isEmpty) {
        final int id = await _repository.insert(record);
        _logger.info('Created workout plan record with id $id');
        return ok(WorkoutPlanRecordDto.fromModel(record.copyWith(id: id)));
      }

      final int id = await _repository.startTransaction((txn) async {
        await txn.rawUpdate(
          '''
          UPDATE ${WorkoutPlanRecord.table} SET 
          ${WorkoutPlanRecordColumns.status.equal} AND
          ${WorkoutPlanRecordColumns.completedAt.equal}
          WHERE ${WorkoutPlanRecordColumns.status.equal};
          ''',
          [
            ProgressStatus.abandoned.value,
            DateUtilities.getNowUtcUnix(),
            ProgressStatus.inProgress.value,
          ],
        );
        return await _repository.insert(record, txn);
      });
      _logger.info('Created workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
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
        orderBy: [WorkoutPlanRecordColumns.createdAt.orderDesc],
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

  Future<int> getTotalWorkoutsCount(
    int workoutPlanId, {
    int? workoutPlanVersion,
  }) async {
    final db = await DatabaseHelper().db;
    final String whereVersion = workoutPlanVersion != null
        ? ' AND ${WorkoutPlanWorkoutColumns.planVersion.value} = ?'
        : '';
    final List<Object?> args = [
      workoutPlanId,
      if (workoutPlanVersion != null) workoutPlanVersion,
    ];
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${WorkoutPlanWorkout.table}
      WHERE ${WorkoutPlanWorkoutColumns.workoutPlanId.value} = ?$whereVersion
      ''',
      args,
    );

    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future<double> getPlanProgressPercentage(
    int workoutPlanRecordId,
    int workoutPlanId,
    int workoutPlanVersion,
  ) async {
    final int completed = await getCompletedWorkoutsCount(workoutPlanRecordId);
    final int total = await getTotalWorkoutsCount(
      workoutPlanId,
      workoutPlanVersion: workoutPlanVersion,
    );

    if (total == 0) {
      return 0.0;
    }

    return (completed / total) * 100.0;
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      getOrCreateCurrentWorkoutPlanRecord(
    int workoutPlanId,
  ) async {
    _logger.info(
      'Getting or creating current workout plan record for workout plan $workoutPlanId',
    );
    final WhereBuilder query = WhereBuilder();
    query.and(WorkoutPlanRecordColumns.workoutPlanId.equal, workoutPlanId);
    query.and(
      WorkoutPlanRecordColumns.status.equal,
      ProgressStatus.inProgress.value,
    );
    try {
      final List<WorkoutPlanRecord> records = await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutPlanRecordColumns.id.orderDesc],
        limit: 1,
      );
      if (records.isNotEmpty) {
        _logger.info(
          'Found existing workout plan record for workout plan $workoutPlanId',
        );
        return ok(WorkoutPlanRecordDto.fromModel(records.first));
      }

      return await createWorkoutPlanRecord(workoutPlanId: workoutPlanId);
    } catch (e) {
      _logger.severe('Failed to get or create current workout plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get or create current workout plan record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      getLatestActivePlanRecord() async {
    _logger.info('Getting latest active plan record');
    try {
      final List<WorkoutPlanRecord> records = await _repository.selectMany(
        where: WorkoutPlanRecordColumns.status.equal,
        whereArgs: [ProgressStatus.inProgress.value],
        orderBy: [WorkoutPlanRecordColumns.id.orderDesc],
        limit: 1,
      );
      if (records.isEmpty) {
        _logger.info('No active plan record found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No active plan record found',
        ));
      }
      _logger.info('Got latest active plan record');
      return ok(WorkoutPlanRecordDto.fromModel(records.first));
    } catch (e) {
      _logger.severe('Failed to get latest active plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get latest active plan record',
      ));
    }
  }

  Future<Result<List<WorkoutPlanWeekRecordDto>, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanRecordWeeksDaysAndWorkouts(int workoutPlanRecordId) async {
    _logger.info(
        'Getting workout plan record weeks and days for workout plan record $workoutPlanRecordId');
    try {
      final WorkoutPlanRecord? record =
          await _repository.selectOne(workoutPlanRecordId);
      if (record == null) {
        _logger
            .info('Workout plan record with id $workoutPlanRecordId not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }

      return ok(await _loadWeeksTree(workoutPlanRecordId));
    } catch (e) {
      _logger.severe(
          'Failed to get workout plan record weeks and days for workout plan record $workoutPlanRecordId',
          e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan record weeks and days',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      upsertWorkoutPlanDayRecord({
    required int workoutPlanRecordId,
    required ProgressStatus status,
    int? week,
    int? weekDay,
  }) async {
    _logger.info(
      'Getting or creating workout plan day record for workout plan record $workoutPlanRecordId',
    );
    try {
      final WorkoutPlanRecord? record = await _repository.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        _logger.info(
          'Workout plan record with id $workoutPlanRecordId not found',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }

      final currentWeek = week ?? record.currentWeek;
      final currentWeekDay = weekDay ?? record.currentDay;
      final weekWhere = WhereBuilder();
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
        workoutPlanRecordId,
      );
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.week.equal,
        currentWeek,
      );
      final List<WorkoutPlanWeekRecord> weekRecord =
          await _workoutPlanWeekRecordRepository.selectMany(
        where: weekWhere.where,
        whereArgs: weekWhere.args,
        limit: 1,
      );
      if (weekRecord.isEmpty) {
        _logger.info(
          'No workout plan week record found for workout plan record $workoutPlanRecordId',
        );
        final createResult = await _createWorkoutPlanWeekAndDayRecords(
          workoutPlanRecord: record,
          week: currentWeek,
          weekDay: currentWeekDay,
          status: status,
        );
        if (createResult.isErr()) {
          return err(createResult.error);
        }
      } else {
        final WorkoutPlanWeekRecord weekRecordData = weekRecord.first;
        final WhereBuilder dayWhere = WhereBuilder();
        dayWhere.and(
          WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.equal,
          weekRecordData.id!,
        );
        dayWhere.and(
          WorkoutPlanDayRecordColumns.day.equal,
          currentWeekDay,
        );
        final List<WorkoutPlanDayRecord> dayRecords =
            await _workoutPlanDayRecordRepository.selectMany(
          where: dayWhere.where,
          whereArgs: dayWhere.args,
          limit: 1,
        );
        if (dayRecords.isEmpty) {
          _logger.info(
            'No workout plan day record found for workout plan week record ${weekRecordData.id} and day $currentWeekDay',
          );
          final createResult = await _createWorkoutPlanDayRecord(
            workoutPlanRecord: record,
            weekRecord: weekRecordData,
            weekDay: currentWeekDay,
            status: status,
          );
          if (createResult.isErr()) {
            return err(createResult.error);
          }
        } else {
          _logger.info(
            'Found existing workout plan day record for workout plan record $workoutPlanRecordId, week record ${weekRecordData.id} and day $currentWeekDay',
          );
        }
      }

      final updatedRecord = await _repository.selectOne(workoutPlanRecordId);
      if (updatedRecord == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }
      return ok(await _toRecordDtoWithTree(updatedRecord));
    } catch (e) {
      _logger.severe(
        'Failed to get current workout plan day record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get current workout plan day record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      upsertWorkoutPlanWorkoutRecord({
    required int workoutPlanRecordId,
    required ProgressStatus status,
    int? week,
    int? weekDay,
    int? workoutPosition,
  }) async {
    _logger.info(
      'Upserting workout plan workout record for workout plan record $workoutPlanRecordId',
    );
    try {
      final WorkoutPlanRecord? record = await _repository.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        _logger.info(
          'Workout plan record with id $workoutPlanRecordId not found',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }

      final currentWeek = week ?? record.currentWeek;
      final currentWeekDay = weekDay ?? record.currentDay;
      final currentWorkoutPosition =
          workoutPosition ?? record.currentWorkoutPosition;
      final weekWhere = WhereBuilder();
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
        workoutPlanRecordId,
      );
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.week.equal,
        currentWeek,
      );
      final List<WorkoutPlanWeekRecord> weekRecord =
          await _workoutPlanWeekRecordRepository.selectMany(
        where: weekWhere.where,
        whereArgs: weekWhere.args,
        limit: 1,
      );
      if (weekRecord.isEmpty) {
        _logger.info(
          'No workout plan week record found for workout plan record $workoutPlanRecordId and week $currentWeek',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'No workout plan week record found for workout plan record and week',
        ));
      }

      final WorkoutPlanWeekRecord weekRecordData = weekRecord.first;
      final WhereBuilder dayWhere = WhereBuilder();
      dayWhere.and(
        WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.equal,
        weekRecordData.id!,
      );
      dayWhere.and(
        WorkoutPlanDayRecordColumns.day.equal,
        currentWeekDay,
      );
      final List<WorkoutPlanDayRecord> dayRecords =
          await _workoutPlanDayRecordRepository.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayRecords.isEmpty) {
        _logger.info(
          'No workout plan day record found for workout plan record $workoutPlanRecordId and week $currentWeek and day $currentWeekDay',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'No workout plan day record found for workout plan record and week and day',
        ));
      }

      final WorkoutPlanDayRecord dayRecordData = dayRecords.first;
      final WhereBuilder workoutWhere = WhereBuilder();
      workoutWhere.and(
        WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.equal,
        dayRecordData.id!,
      );
      workoutWhere.and(
        WorkoutPlanWorkoutRecordColumns.position.equal,
        currentWorkoutPosition,
      );
      final List<WorkoutPlanWorkoutRecord> workoutRecords =
          await _workoutPlanWorkoutRecordRepository.selectMany(
        where: workoutWhere.where,
        whereArgs: workoutWhere.args,
        limit: 1,
      );
      if (workoutRecords.isEmpty) {
        _logger.info(
          'No workout plan workout record found for workout plan record $workoutPlanRecordId and week $currentWeek and day $currentWeekDay and position $currentWorkoutPosition',
        );
        final createResult = await _createWorkoutPlanWorkoutRecord(
          dayRecord: dayRecordData,
          workoutPosition: currentWorkoutPosition,
        );
        if (createResult.isErr()) {
          return err(createResult.error);
        }
      }

      final updatedRecord = await _repository.selectOne(workoutPlanRecordId);
      if (updatedRecord == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }
      return ok(await _toRecordDtoWithTree(updatedRecord));
    } catch (e) {
      _logger.severe(
        'Failed to upsert workout plan workout record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to upsert workout plan workout record',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto, ServiceError<SingleErrorTypes>>>
      _createWorkoutPlanWeekAndDayRecords({
    required WorkoutPlanRecord workoutPlanRecord,
    required int week,
    required int weekDay,
    required ProgressStatus status,
  }) async {
    final int workoutPlanRecordId = workoutPlanRecord.id!;
    final int workoutPlanId = workoutPlanRecord.workoutPlanId;
    _logger.info(
      'Creating workout plan week and day records for workout plan record $workoutPlanRecordId and workout plan $workoutPlanId for week $week and day $weekDay',
    );

    final WhereBuilder mainWhere = WhereBuilder();
    mainWhere.and(WorkoutPlanWeekColumns.workoutPlanId.equal, workoutPlanId);

    final WhereBuilder onlyStartWeekWhere = WhereBuilder();
    onlyStartWeekWhere.and(WorkoutPlanWeekColumns.startWeek.equal, week);
    onlyStartWeekWhere.and(WorkoutPlanWeekColumns.endWeek.isNull);

    final WhereBuilder betweenWeekWhere = WhereBuilder();
    betweenWeekWhere.and(WorkoutPlanWeekColumns.startWeek.lessThanOrEqual, week);
    betweenWeekWhere.and(WorkoutPlanWeekColumns.endWeek.notNull);
    betweenWeekWhere.and(WorkoutPlanWeekColumns.endWeek.greaterThanOrEqual, week);

    final WhereBuilder weekWhere = WhereBuilder();
    weekWhere.or(onlyStartWeekWhere.where!);
    weekWhere.or(betweenWeekWhere.where!);
    mainWhere.and(weekWhere.where!);

    final List<Object?> args = [
      ...mainWhere.args!,
      ...onlyStartWeekWhere.args!,
      ...betweenWeekWhere.args!,
    ];

    final List<WorkoutPlanWeek> weeks =
        await _workoutPlanWeekRepository.selectMany(
      where: mainWhere.where,
      whereArgs: args,
      orderBy: [WorkoutPlanWeekColumns.startWeek.orderAsc],
      limit: 1,
    );
    if (weeks.isEmpty) {
      _logger.info(
        'No workout plan week found for workout plan $workoutPlanId and week $week',
      );
      return err(const ServiceError(
        type: SingleErrorTypes.notFound,
        description: 'No workout plan week found for workout plan and week',
      ));
    }

    final WorkoutPlanWeekRecord weekRecord = WorkoutPlanWeekRecord.create(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekId: weeks.first.id!,
      week: week,
      status: status,
      currentDay: weekDay,
    );
    final WhereBuilder dayWhere = WhereBuilder();
    dayWhere.and(
      WorkoutPlanDayColumns.workoutPlanWeekId.equal,
      weeks.first.id!,
    );
    dayWhere.and(
      WorkoutPlanDayColumns.day.equal,
      weekDay,
    );

    try {
      final List<WorkoutPlanDay> dayData =
          await _workoutPlanDayRepository.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayData.isEmpty) {
        _logger.info(
          'No workout plan day found for workout plan week ${weeks.first.id} and day $weekDay',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No workout plan day found for workout plan week and day',
        ));
      }
      final int workoutPlanDayId = dayData.first.id!;

      final (int weekRecordId, WorkoutPlanDayRecord dayRecord) =
          await _repository.startTransaction((txn) async {
        final int weekRecordId = await _workoutPlanWeekRecordRepository.insert(
          weekRecord,
          txn,
        );

        final WorkoutPlanDayRecord dayRecord = WorkoutPlanDayRecord.create(
          workoutPlanRecordId: workoutPlanRecordId,
          workoutPlanWeekRecordId: weekRecordId,
          workoutPlanDayId: workoutPlanDayId,
          day: weekDay,
          status: status,
          week: week,
        );
        final int dayRecordId =
            await _workoutPlanDayRecordRepository.insert(dayRecord, txn);

        final WorkoutPlanRecord updatedRecord = workoutPlanRecord.copyWith(
          currentWeek: week,
          currentDay: weekDay,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedRecord, txn);
        return (weekRecordId, dayRecord.copyWith(id: dayRecordId));
      });
      _logger.info(
        'Created workout plan week record with id $weekRecordId and day record with id ${dayRecord.id} for workout plan record $workoutPlanRecordId',
      );
      return ok(WorkoutPlanDayRecordDto.fromModel(dayRecord));
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan week record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create workout plan week record',
      ));
    }
  }

  Future<Result<WorkoutPlanDayRecordDto, ServiceError<SingleErrorTypes>>>
      _createWorkoutPlanDayRecord({
    required WorkoutPlanRecord workoutPlanRecord,
    required WorkoutPlanWeekRecord weekRecord,
    required int weekDay,
    required ProgressStatus status,
  }) async {
    final int workoutPlanRecordId = workoutPlanRecord.id!;
    final int workoutPlanWeekRecordId = weekRecord.id!;
    _logger.info(
      'Creating workout plan day record for workout plan record $workoutPlanRecordId, week record $workoutPlanWeekRecordId and week day $weekDay',
    );

    final WhereBuilder dayWhere = WhereBuilder();
    dayWhere.and(
      WorkoutPlanDayColumns.workoutPlanWeekId.equal,
      weekRecord.workoutPlanWeekId,
    );
    dayWhere.and(
      WorkoutPlanDayColumns.day.equal,
      weekDay,
    );
    try {
      final List<WorkoutPlanDay> dayData =
          await _workoutPlanDayRepository.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayData.isEmpty) {
        _logger.info(
          'No workout plan day found for workout plan week ${weekRecord.workoutPlanWeekId} and day $weekDay',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'No workout plan day found for workout plan week and day',
        ));
      }

      final int workoutPlanDayId = dayData.first.id!;
      final WorkoutPlanDayRecord dayRecord = WorkoutPlanDayRecord.create(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanWeekRecordId: workoutPlanWeekRecordId,
        workoutPlanDayId: workoutPlanDayId,
        day: weekDay,
        status: status,
      );

      final int dayRecordId =
          await _workoutPlanDayRecordRepository.startTransaction(
        (txn) async {
          final int dayRecordId = await _workoutPlanDayRecordRepository.insert(
            dayRecord,
            txn,
          );

          final WorkoutPlanRecord updatedRecord = workoutPlanRecord.copyWith(
            currentWeek: weekRecord.week,
            currentDay: weekDay,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _repository.update(updatedRecord, txn);

          final WorkoutPlanWeekRecord updatedWeekRecord = weekRecord.copyWith(
            currentDay: weekDay,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _workoutPlanWeekRecordRepository.update(updatedWeekRecord, txn);

          return dayRecordId;
        },
      );

      _logger.info(
        'Created workout plan day record with id $dayRecordId for workout plan record $workoutPlanRecordId',
      );
      return ok(
        WorkoutPlanDayRecordDto.fromModel(dayRecord.copyWith(id: dayRecordId)),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan day record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create workout plan day record',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutRecordDto, ServiceError<SingleErrorTypes>>>
      _createWorkoutPlanWorkoutRecord({
    required WorkoutPlanDayRecord dayRecord,
    required int workoutPosition,
  }) async {
    final int workoutPlanRecordId = dayRecord.workoutPlanRecordId;
    final int workoutPlanDayRecordId = dayRecord.id!;
    final int workoutPlanWeekRecordId = dayRecord.workoutPlanWeekRecordId;
    final int workoutPlanDayId = dayRecord.workoutPlanDayId;
    try {
      final WhereBuilder workoutWhere = WhereBuilder();
      workoutWhere.and(
        WorkoutPlanWorkoutColumns.workoutPlanDayId.equal,
        workoutPlanDayId,
      );
      workoutWhere.and(
        WorkoutPlanWorkoutColumns.position.equal,
        workoutPosition,
      );
      final workoutPlansWorkouts =
          await _workoutPlanWorkoutRepository.selectMany(
        where: workoutWhere.where,
        whereArgs: workoutWhere.args,
        limit: 1,
      );
      if (workoutPlansWorkouts.isEmpty) {
        _logger.info(
          'No workout plan workout found for workout plan day $workoutPlanDayId and position $workoutPosition',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan workout not found',
        ));
      }

      final WorkoutPlanWorkout workoutPlanWorkout = workoutPlansWorkouts.first;
      final WorkoutPlanWorkoutRecord workoutPlanWorkoutRecord =
          WorkoutPlanWorkoutRecord.create(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanWeekRecordId: workoutPlanWeekRecordId,
        workoutPlanDayRecordId: workoutPlanDayRecordId,
        workoutPlanWorkoutId: workoutPlanWorkout.id!,
        workoutRecordId: workoutPlanWorkout.workoutId,
        position: workoutPosition,
      );
      final int workoutPlanWorkoutRecordId =
          await _workoutPlanWorkoutRecordRepository.insert(
        workoutPlanWorkoutRecord,
      );
      _logger.info(
        'Created workout plan workout record with id $workoutPlanWorkoutRecordId for workout plan record $workoutPlanRecordId, week record $workoutPlanWeekRecordId, day record $workoutPlanDayRecordId',
      );
      return ok(
        WorkoutPlanWorkoutRecordDto.fromModel(
          workoutPlanWorkoutRecord.copyWith(
            id: workoutPlanWorkoutRecordId,
          ),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan workout record for workout plan record $workoutPlanRecordId, week record $workoutPlanWeekRecordId, day record $workoutPlanDayRecordId, position $workoutPosition',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create workout plan workout record',
      ));
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanWorkoutRecordStatus({
    required int workoutPlanRecordId,
    required int week,
    required int weekDay,
    required int workoutPosition,
    required ProgressStatus status,
  }) async {
    _logger.info('Updating workout plan workout record status to $status');
    try {
      final dayResult = await upsertWorkoutPlanDayRecord(
        workoutPlanRecordId: workoutPlanRecordId,
        status: ProgressStatus.inProgress,
        week: week,
        weekDay: weekDay,
      );
      if (dayResult.isErr()) {
        return err(dayResult.error);
      }

      final upsertResult = await upsertWorkoutPlanWorkoutRecord(
        workoutPlanRecordId: workoutPlanRecordId,
        status: ProgressStatus.inProgress,
        week: week,
        weekDay: weekDay,
        workoutPosition: workoutPosition,
      );
      if (upsertResult.isErr()) {
        return err(upsertResult.error);
      }

      final WorkoutPlanRecord? record = await _repository.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }

      final weekWhere = WhereBuilder();
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
        workoutPlanRecordId,
      );
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.week.equal,
        week,
      );
      final List<WorkoutPlanWeekRecord> weekRecords =
          await _workoutPlanWeekRecordRepository.selectMany(
        where: weekWhere.where,
        whereArgs: weekWhere.args,
        limit: 1,
      );
      if (weekRecords.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Week record not found',
        ));
      }
      final weekRecord = weekRecords.first;

      final dayWhere = WhereBuilder();
      dayWhere.and(
        WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.equal,
        weekRecord.id!,
      );
      dayWhere.and(
        WorkoutPlanDayRecordColumns.day.equal,
        weekDay,
      );
      final List<WorkoutPlanDayRecord> dayRecords =
          await _workoutPlanDayRecordRepository.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayRecords.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Day record not found',
        ));
      }
      final dayRecord = dayRecords.first;

      final workoutWhere = WhereBuilder();
      workoutWhere.and(
        WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.equal,
        dayRecord.id!,
      );
      workoutWhere.and(
        WorkoutPlanWorkoutRecordColumns.position.equal,
        workoutPosition,
      );
      final List<WorkoutPlanWorkoutRecord> workoutRecords =
          await _workoutPlanWorkoutRecordRepository.selectMany(
        where: workoutWhere.where,
        whereArgs: workoutWhere.args,
        limit: 1,
      );
      if (workoutRecords.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout record not found',
        ));
      }
      final workoutRecord = workoutRecords.first;

      final now = DateUtilities.getNowUtcUnix();

      await _repository.startTransaction((txn) async {
        final updatedWorkoutRecord = workoutRecord.copyWith(
          status: status,
          completedAt: status == ProgressStatus.completed ? now : null,
          updatedAt: now,
        );
        await _workoutPlanWorkoutRecordRepository.update(
          updatedWorkoutRecord,
          txn,
        );

        final siblingWorkouts =
            await _workoutPlanWorkoutRecordRepository.selectMany(
          where:
              '${WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value} = ?',
          whereArgs: [dayRecord.id!],
          trx: txn,
        );
        final allWorkouts = siblingWorkouts
            .map((w) => w.id == updatedWorkoutRecord.id ? updatedWorkoutRecord : w)
            .toList();
        final bool allCompletedOrSkipped = allWorkouts.every(
          (w) =>
              w.status == ProgressStatus.completed ||
              w.status == ProgressStatus.skipped,
        );

        if (allCompletedOrSkipped) {
          final updatedDayRecord = dayRecord.copyWith(
            status: ProgressStatus.completed,
            completedAt: now,
            updatedAt: now,
          );
          await _workoutPlanDayRecordRepository.update(
            updatedDayRecord,
            txn,
          );

          final siblingDays = await _workoutPlanDayRecordRepository.selectMany(
            where:
                '${WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.value} = ?',
            whereArgs: [weekRecord.id!],
            trx: txn,
          );
          final allDays = siblingDays
              .map((d) => d.id == updatedDayRecord.id ? updatedDayRecord : d)
              .toList();
          final bool allDaysCompleted = allDays.every(
            (d) =>
                d.status == ProgressStatus.completed ||
                d.status == ProgressStatus.skipped,
          );

          if (allDaysCompleted) {
            final updatedWeekRecord = weekRecord.copyWith(
              status: ProgressStatus.completed,
              updatedAt: now,
            );
            await _workoutPlanWeekRecordRepository.update(
              updatedWeekRecord,
              txn,
            );

            final plan =
                await _workoutPlanRepository.selectOne(record.workoutPlanId, txn);
            if (plan != null) {
              final siblingWeeks =
                  await _workoutPlanWeekRecordRepository.selectMany(
                where:
                    '${WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value} = ?',
                whereArgs: [workoutPlanRecordId],
                trx: txn,
              );
              final allWeeks = siblingWeeks
                  .map((w) =>
                      w.id == updatedWeekRecord.id ? updatedWeekRecord : w)
                  .toList();
              final bool allWeeksCompleted = allWeeks.length ==
                      plan.totalWeeks &&
                  allWeeks.every((w) => w.status == ProgressStatus.completed);

              if (allWeeksCompleted) {
                final updatedRecord = record.copyWith(
                  status: ProgressStatus.completed,
                  completedAt: now,
                  updatedAt: now,
                );
                await _repository.update(updatedRecord, txn);
              }
            }
          }
        }
      });

      final updatedRecord = await _repository.selectOne(workoutPlanRecordId);
      if (updatedRecord == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan record not found',
        ));
      }
      return ok(await _toRecordDtoWithTree(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to complete workout plan workout record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to complete workout plan workout record',
      ));
    }
  }

  Future<List<WorkoutPlanWeekRecordDto>> _loadWeeksTree(
    int workoutPlanRecordId,
  ) async {
    final List<WorkoutPlanWeekRecord> weeks =
        await _workoutPlanWeekRecordRepository.selectMany(
      where: WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
      whereArgs: [workoutPlanRecordId],
      orderBy: [WorkoutPlanWeekRecordColumns.week.orderAsc],
    );
    final List<WorkoutPlanDayRecord> days =
        await _workoutPlanDayRecordRepository.selectMany(
      where: WorkoutPlanDayRecordColumns.workoutPlanRecordId.equal,
      whereArgs: [workoutPlanRecordId],
      orderBy: [
        WorkoutPlanWeekRecordColumns.week.orderAsc,
        WorkoutPlanDayRecordColumns.day.orderAsc,
      ],
    );
    final List<WorkoutPlanWorkoutRecord> workouts =
        await _workoutPlanWorkoutRecordRepository.selectMany(
      where: WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.equal,
      whereArgs: [workoutPlanRecordId],
      orderBy: [WorkoutPlanWorkoutRecordColumns.position.orderAsc],
    );
    final Map<int, List<WorkoutPlanWorkoutRecordDto>> workoutsMap =
        workouts.fold(
      {},
      (map, workout) {
        map.update(
          workout.workoutPlanDayRecordId,
          (list) => list..add(WorkoutPlanWorkoutRecordDto.fromModel(workout)),
          ifAbsent: () => [WorkoutPlanWorkoutRecordDto.fromModel(workout)],
        );
        return map;
      },
    );

    final Map<int, List<WorkoutPlanDayRecordDto>> daysMap = days.fold(
      {},
      (map, day) {
        map.update(
          day.workoutPlanWeekRecordId,
          (list) => list
            ..add(
              WorkoutPlanDayRecordDto.fromModel(
                day,
                workouts: workoutsMap[day.id],
              ),
            ),
          ifAbsent: () => [
            WorkoutPlanDayRecordDto.fromModel(
              day,
              workouts: workoutsMap[day.id],
            ),
          ],
        );
        return map;
      },
    );

    return weeks
        .map((week) => WorkoutPlanWeekRecordDto.fromModel(
              week,
              days: daysMap[week.id],
            ))
        .toList();
  }

  Future<WorkoutPlanRecordDto> _toRecordDtoWithTree(
    WorkoutPlanRecord record,
  ) async {
    final weeks = await _loadWeeksTree(record.id!);
    return WorkoutPlanRecordDto.fromModel(record, weeks: weeks);
  }
}
