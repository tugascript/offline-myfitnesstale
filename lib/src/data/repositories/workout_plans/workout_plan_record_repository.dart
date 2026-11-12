// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/workout_plan_day_model.dart';
import '../../models/sqlite/workout_plan_day_record_model.dart';
import '../../models/sqlite/workout_plan_model.dart';
import '../../models/sqlite/workout_plan_record_model.dart';
import '../../models/sqlite/workout_plan_week_model.dart';
import '../../models/sqlite/workout_plan_week_record_model.dart';
import '../../models/sqlite/workout_plan_workout_model.dart';
import '../../models/sqlite/workout_plan_workout_record_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/dao.dart' show Dao;
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/where_builder.dart';
import '../core/dtos/paginated_dto.dart';
import '../core/repository.dart';
import '../core/repository_helpers.dart';
import './dtos/workout_plan_day_record_dto.dart';
import './dtos/workout_plan_dto.dart';
import './dtos/workout_plan_record_dto.dart';
import './dtos/workout_plan_week_record_dto.dart';
import './dtos/workout_plan_workout_record_dto.dart';
import './inputs/workout_plan_day_record_input.dart';
import './inputs/workout_plan_record_input.dart';
import './inputs/workout_plan_workout_record_input.dart';

final class WorkoutPlanRecordRepository implements Repository {
  final Dao<WorkoutPlanRecord> _workoutPlanRecordDao;
  final Dao<WorkoutPlanWeekRecord> _workoutPlanWeekRecordDao;
  final Dao<WorkoutPlanDayRecord> _workoutPlanDayRecordDao;
  final Dao<WorkoutPlanWorkoutRecord> _workoutPlanWorkoutRecordDao;
  final Dao<WorkoutPlan> _workoutPlanDao;
  final Dao<WorkoutPlanWeek> _workoutPlanWeekDao;
  final Dao<WorkoutPlanDay> _workoutPlanDayDao;
  final Dao<WorkoutPlanWorkout> _workoutPlanWorkoutDao;

  final Logger _logger = Logger('Workout Plan Record Repository');

  WorkoutPlanRecordRepository({
    required this._workoutPlanRecordDao,
    required this._workoutPlanWeekRecordDao,
    required this._workoutPlanDayRecordDao,
    required this._workoutPlanWorkoutRecordDao,
    required this._workoutPlanDao,
    required this._workoutPlanWeekDao,
    required this._workoutPlanDayDao,
    required this._workoutPlanWorkoutDao,
  });

  factory WorkoutPlanRecordRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return WorkoutPlanRecordRepository(
      workoutPlanRecordDao: Dao<WorkoutPlanRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanRecord.table,
        fromMap: (map) => WorkoutPlanRecord.fromMap(map),
      ),
      workoutPlanWeekRecordDao: Dao<WorkoutPlanWeekRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanWeekRecord.table,
        fromMap: (map) => WorkoutPlanWeekRecord.fromMap(map),
      ),
      workoutPlanDayRecordDao: Dao<WorkoutPlanDayRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanDayRecord.table,
        fromMap: (map) => WorkoutPlanDayRecord.fromMap(map),
      ),
      workoutPlanWorkoutRecordDao: Dao<WorkoutPlanWorkoutRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanWorkoutRecord.table,
        fromMap: (map) => WorkoutPlanWorkoutRecord.fromMap(map),
      ),
      workoutPlanDao: Dao<WorkoutPlan>(
        databaseHelper: helper,
        tableName: WorkoutPlan.table,
        fromMap: (map) => WorkoutPlan.fromMap(map),
      ),
      workoutPlanWeekDao: Dao<WorkoutPlanWeek>(
        databaseHelper: helper,
        tableName: WorkoutPlanWeek.table,
        fromMap: (map) => WorkoutPlanWeek.fromMap(map),
      ),
      workoutPlanDayDao: Dao<WorkoutPlanDay>(
        databaseHelper: helper,
        tableName: WorkoutPlanDay.table,
        fromMap: (map) => WorkoutPlanDay.fromMap(map),
      ),
      workoutPlanWorkoutDao: Dao<WorkoutPlanWorkout>(
        databaseHelper: helper,
        tableName: WorkoutPlanWorkout.table,
        fromMap: (map) => WorkoutPlanWorkout.fromMap(map),
      ),
    );
  }

  Future<
    Result<
      PaginatedDto<WorkoutPlanRecordDto, WorkoutPlanRecord>,
      ServiceError<OperationErrorTypes>
    >
  >
  getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? status,
    (DateTime start, DateTime end)? dateRange,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout plan records');
    final WhereBuilder query = WhereBuilder();

    if (workoutPlanId != null) {
      query.and(WorkoutPlanRecordColumns.workoutPlanId.equal, workoutPlanId);
    }

    if (status != null) {
      query.and(WorkoutPlanRecordColumns.status.equal, status.value);
    }

    if (dateRange != null) {
      final startOfDay = DateTime(
        dateRange.$1.year,
        dateRange.$1.month,
        dateRange.$1.day,
        0,
        0,
        0,
      );
      query.and(
        WorkoutPlanRecordColumns.startedAt.greaterThanOrEqual,
        DateUtilities.getDateUnix(startOfDay),
      );

      final endOfDay = DateTime(
        dateRange.$2.year,
        dateRange.$2.month,
        dateRange.$2.day,
        23,
        59,
        59,
      );
      query.and(
        WorkoutPlanRecordColumns.startedAt.lessThanOrEqual,
        DateUtilities.getDateUnix(endOfDay),
      );
    }

    try {
      final pageResult = await fetchPaginatedWithTotal(
        failureType: OperationErrorTypes.operationFailure,
        dao: _workoutPlanRecordDao,
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutPlanRecordColumns.createdAt.orderDesc],
      );
      if (pageResult.isErr()) return err(pageResult.error);
      final (List<WorkoutPlanRecord> records, int total) = pageResult.value;
      _logger.info('Got ${records.length} workout plan records');
      if (workoutPlanId != null || records.isEmpty) {
        return ok(
          PaginatedDto<WorkoutPlanRecordDto, WorkoutPlanRecord>.mapData(
            data: records,
            mapper: (record) => WorkoutPlanRecordDto.fromModel(record),
            total: total,
            limit: limit,
            offset: offset,
          ),
        );
      }

      final Set<int> planIds = records.map((r) => r.workoutPlanId).toSet();
      final plansResult = await selectManyInChunks(
        failureType: OperationErrorTypes.operationFailure,
        dao: _workoutPlanDao,
        column: WorkoutPlanColumns.id,
        values: planIds,
      );
      if (plansResult.isErr()) return err(plansResult.error);
      final List<WorkoutPlan> plans = plansResult.value;
      final Map<int, WorkoutPlanDto> planMap = {
        for (final plan in plans) plan.id!: WorkoutPlanDto.fromModel(plan),
      };

      return ok(
        PaginatedDto<WorkoutPlanRecordDto, WorkoutPlanRecord>.mapData(
          data: records,
          mapper: (record) => WorkoutPlanRecordDto.fromModel(
            record,
            workoutPlan: planMap[record.workoutPlanId],
          ),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get workout plan records', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get workout plan records',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  getWorkoutPlanRecord(int id) async {
    _logger.info('Getting workout plan record with id $id');
    try {
      final WorkoutPlanRecord? record = await _workoutPlanRecordDao.selectOne(
        id,
      );
      if (record == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }
      _logger.info('Got workout plan record with id $id');
      return await _toRecordDtoWithTree(record);
    } catch (e) {
      _logger.severe('Failed to get workout plan record with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get workout plan record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  createWorkoutPlanRecord(WorkoutPlanRecordInput input) async {
    _logger.info('Creating workout plan record');
    try {
      return await _workoutPlanRecordDao.startTransaction<
        Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final workoutPlan = await _workoutPlanDao.selectOne(
          input.workoutPlanId,
          txn,
        );
        if (workoutPlan == null) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Workout plan not found',
            ),
          );
        }

        final weekWhere = WhereBuilder();
        weekWhere.and(
          WorkoutPlanWeekColumns.workoutPlanId.equal,
          input.workoutPlanId,
        );
        weekWhere.and(
          WorkoutPlanWeekColumns.planVersion.equal,
          workoutPlan.version,
        );
        final List<WorkoutPlanWeek> weeks = await _workoutPlanWeekDao
            .selectMany(
              where: weekWhere.where,
              whereArgs: weekWhere.args,
              orderBy: [WorkoutPlanWeekColumns.startWeek.orderAsc],
              limit: 1,
              trx: txn,
            );
        if (weeks.isEmpty) {
          _logger.info(
            'No weeks found for workout plan ${input.workoutPlanId}',
          );
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'No weeks found for workout plan',
            ),
          );
        }

        final WorkoutPlanRecord record = WorkoutPlanRecord.create(
          input.workoutPlanId,
          workoutPlanVersion: workoutPlan.version,
          status: input.status,
          startedAt: input.startedAt != null
              ? DateUtilities.getDateUnix(input.startedAt!)
              : DateUtilities.getNowUtcUnix(),
          completedAt: input.completedAt.value != null
              ? DateUtilities.getDateUnix(input.completedAt.value!)
              : null,
          currentWeek: 1,
          currentDay: 1,
          currentWorkoutPosition: 1,
        );
        if (input.status == ProgressStatus.inProgress) {
          final abandoned = await _abandonOtherActiveRecords(
            txn,
            DateUtilities.getNowUtcUnix(),
          );
          if (abandoned.isErr()) throw abandoned.error;
        }
        final id = await _workoutPlanRecordDao.insert(record, txn);
        _logger.info('Created workout plan record with id $id');
        return ok(
          WorkoutPlanRecordDto.fromModel(record.copyWith(id: Nullable(id))),
        );
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to create workout plan record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create workout plan record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  updateWorkoutPlanRecord(int id, WorkoutPlanRecordInput input) async {
    _logger.info('Updating workout plan record with id $id');
    try {
      final WorkoutPlanRecord? record = await _workoutPlanRecordDao.selectOne(
        id,
      );
      if (record == null) {
        _logger.info('Workout plan record with id $id not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }
      if (input.workoutPlanId != record.workoutPlanId) {
        _logger.info(
          'Workout plan record $id belongs to workout plan ${record.workoutPlanId}, not ${input.workoutPlanId}',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description:
                'Workout plan record cannot be moved to another workout plan',
          ),
        );
      }

      final WorkoutPlanRecord updatedRecord = record.copyWith(
        status: input.status,
        startedAt: input.startedAt != null
            ? DateUtilities.getDateUnix(input.startedAt!)
            : record.startedAt,
        completedAt: Nullable(
          input.completedAt.value != null
              ? DateUtilities.getDateUnix(input.completedAt.value!)
              : null,
        ),
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      if (updatedRecord.status == ProgressStatus.inProgress) {
        await _workoutPlanRecordDao.startTransaction((txn) async {
          await _workoutPlanRecordDao.update(updatedRecord, txn);
          final abandoned = await _abandonOtherActiveRecords(
            txn,
            updatedRecord.updatedAt,
            exceptId: id,
          );
          if (abandoned.isErr()) throw abandoned.error;
        });
      } else {
        await _workoutPlanRecordDao.update(updatedRecord);
      }
      _logger.info('Updated workout plan record with id $id');
      return ok(WorkoutPlanRecordDto.fromModel(updatedRecord));
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to update workout plan record with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update workout plan record',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
  _abandonOtherActiveRecords(Transaction txn, int now, {int? exceptId}) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to abandon active workout plan records',
    );
    try {
      final where = WhereBuilder()
        ..and(
          WorkoutPlanRecordColumns.status.equal,
          ProgressStatus.inProgress.value,
        );
      if (exceptId != null) {
        where.and(WorkoutPlanRecordColumns.id.notEqual, exceptId);
      }
      await txn.update(
        WorkoutPlanRecord.table,
        {
          WorkoutPlanRecordColumns.status.value: ProgressStatus.abandoned.value,
          WorkoutPlanRecordColumns.completedAt.value: now,
          WorkoutPlanRecordColumns.updatedAt.value: now,
        },
        where: where.where!,
        whereArgs: where.args!,
      );
      return ok(null);
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutPlanRecord(
    int id,
  ) async {
    _logger.info('Deleting workout plan record with id $id');
    try {
      final bool deleted = await _workoutPlanRecordDao.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }
      _logger.info('Deleted workout plan record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout plan record with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete workout plan record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto?, ServiceError<SingleErrorTypes>>>
  getActivePlanRecord(int workoutPlanId) async {
    _logger.info('Getting active plan record for workout plan $workoutPlanId');
    try {
      final where = WhereBuilder()
        ..and(WorkoutPlanRecordColumns.workoutPlanId.equal, workoutPlanId)
        ..and(
          WorkoutPlanRecordColumns.status.equal,
          ProgressStatus.inProgress.value,
        );
      final List<WorkoutPlanRecord> records = await _workoutPlanRecordDao
          .selectMany(
            where: where.where!,
            whereArgs: where.args!,
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
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get active plan record',
        ),
      );
    }
  }

  Future<Result<int, ServiceError<OperationErrorTypes>>>
  getCompletedWorkoutsCount(int workoutPlanRecordId) async {
    try {
      final where = WhereBuilder()
        ..and(
          WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.equal,
          workoutPlanRecordId,
        )
        ..and(WorkoutPlanWorkoutRecordColumns.completedAt.notNull);
      final count = await _workoutPlanWorkoutRecordDao.count(
        where: where.where,
        whereArgs: where.args,
      );
      return ok(count);
    } catch (e) {
      _logger.severe('Failed to get completed workouts count', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get completed workouts count',
        ),
      );
    }
  }

  Future<Result<int, ServiceError<OperationErrorTypes>>> getTotalWorkoutsCount(
    int workoutPlanId, {
    int? workoutPlanVersion,
  }) async {
    return _countScheduledWorkouts(
      workoutPlanId,
      workoutPlanVersion,
      OperationErrorTypes.operationFailure,
    );
  }

  Future<Result<int, ServiceError<E>>>
  _countScheduledWorkouts<E extends ErrorTypes>(
    int workoutPlanId,
    int? workoutPlanVersion,
    E failureType, [
    Transaction? txn,
  ]) async {
    final failure = ServiceError(
      type: failureType,
      description: 'Failed to get total workouts count',
    );
    try {
      final where = WhereBuilder()
        ..and(WorkoutPlanWeekColumns.workoutPlanId.equal, workoutPlanId);
      if (workoutPlanVersion != null) {
        where.and(WorkoutPlanWeekColumns.planVersion.equal, workoutPlanVersion);
      }
      final count = await _workoutPlanWeekDao.rawCount(
        '''
        SELECT COALESCE(SUM(
          ${WorkoutPlanWeekColumns.totalWorkouts.value} *
          (${WorkoutPlanWeekColumns.endWeek.value} -
            ${WorkoutPlanWeekColumns.startWeek.value} + 1)
        ), 0) as count
        FROM ${WorkoutPlanWeek.table}
        WHERE ${where.where}
        ''',
        where.args,
        txn,
      );
      return ok(count);
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<double, ServiceError<OperationErrorTypes>>>
  getPlanProgressPercentage(
    int workoutPlanRecordId,
    int workoutPlanId,
    int workoutPlanVersion,
  ) async {
    final results = await Future.wait([
      getCompletedWorkoutsCount(workoutPlanRecordId),
      getTotalWorkoutsCount(
        workoutPlanId,
        workoutPlanVersion: workoutPlanVersion,
      ),
    ]);
    final completedResult = results[0];
    if (completedResult.isErr()) {
      return err(completedResult.error);
    }
    final totalResult = results[1];
    if (totalResult.isErr()) {
      return err(totalResult.error);
    }

    final int total = totalResult.value;
    if (total == 0) {
      return ok(0.0);
    }

    return ok((completedResult.value / total) * 100.0);
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  getOrCreateCurrentWorkoutPlanRecord(int workoutPlanId) async {
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
      final List<WorkoutPlanRecord> records = await _workoutPlanRecordDao
          .selectMany(
            where: query.where,
            whereArgs: query.args,
            orderBy: [WorkoutPlanRecordColumns.id.orderDesc],
            limit: 1,
          );
      if (records.isNotEmpty) {
        _logger.info(
          'Found existing workout plan record for workout plan $workoutPlanId',
        );
        return await _toRecordDtoWithTree(records.first);
      }

      return await createWorkoutPlanRecord(
        WorkoutPlanRecordInput(workoutPlanId: workoutPlanId),
      );
    } catch (e) {
      _logger.severe('Failed to get or create current workout plan record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get or create current workout plan record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  getLatestActivePlanRecord() async {
    _logger.info('Getting latest active plan record');
    try {
      final List<WorkoutPlanRecord> records = await _workoutPlanRecordDao
          .selectMany(
            where: WorkoutPlanRecordColumns.status.equal,
            whereArgs: [ProgressStatus.inProgress.value],
            orderBy: [WorkoutPlanRecordColumns.id.orderDesc],
            limit: 1,
          );
      if (records.isEmpty) {
        _logger.info('No active plan record found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No active plan record found',
          ),
        );
      }
      _logger.info('Got latest active plan record');
      return await _toRecordDtoWithTree(records.first);
    } catch (e) {
      _logger.severe('Failed to get latest active plan record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get latest active plan record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  getLatestWorkoutPlanRecord([int? workoutPlanId]) async {
    _logger.info('Getting latest workout plan record for plan $workoutPlanId');
    try {
      final List<WorkoutPlanRecord> records = await _workoutPlanRecordDao
          .selectMany(
            where: workoutPlanId != null
                ? WorkoutPlanRecordColumns.workoutPlanId.equal
                : null,
            whereArgs: workoutPlanId != null ? [workoutPlanId] : null,
            orderBy: [WorkoutPlanRecordColumns.startedAt.orderDesc],
            limit: 1,
          );
      if (records.isEmpty) {
        _logger.info('No latest workout plan record found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Latest workout plan record not found',
          ),
        );
      }

      final record = records.first;
      WorkoutPlanDto? workoutPlanDto;
      if (workoutPlanId == null) {
        final WorkoutPlan? plan = await _workoutPlanDao.selectOne(
          record.workoutPlanId,
        );
        if (plan != null) {
          workoutPlanDto = WorkoutPlanDto.fromModel(plan);
        }
      }

      final weeks = await _loadWeeksTree(record.id!);
      if (weeks.isErr()) return err(weeks.error);
      return ok(
        WorkoutPlanRecordDto.fromModel(
          record,
          workoutPlan: workoutPlanDto,
          weeks: weeks.value,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get latest workout plan record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get latest workout plan record',
        ),
      );
    }
  }

  Future<Result<List<WorkoutPlanWeekRecordDto>, ServiceError<SingleErrorTypes>>>
  getWorkoutPlanRecordWeeksDaysAndWorkouts(int workoutPlanRecordId) async {
    _logger.info(
      'Getting workout plan record weeks and days for workout plan record $workoutPlanRecordId',
    );
    try {
      final WorkoutPlanRecord? record = await _workoutPlanRecordDao.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        _logger.info(
          'Workout plan record with id $workoutPlanRecordId not found',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }

      return await _loadWeeksTree(workoutPlanRecordId);
    } catch (e) {
      _logger.severe(
        'Failed to get workout plan record weeks and days for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get workout plan record weeks and days',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  upsertWorkoutPlanDayRecord(WorkoutPlanDayRecordInput input) async {
    final workoutPlanRecordId = input.workoutPlanRecordId;
    _logger.info(
      'Getting or creating workout plan day record for workout plan record $workoutPlanRecordId',
    );
    try {
      final WorkoutPlanRecord? record = await _workoutPlanRecordDao.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        _logger.info(
          'Workout plan record with id $workoutPlanRecordId not found',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }

      final currentWeek = input.week ?? record.currentWeek;
      final currentWeekDay = input.weekDay ?? record.currentDay;
      final weekWhere = WhereBuilder();
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
        workoutPlanRecordId,
      );
      weekWhere.and(WorkoutPlanWeekRecordColumns.week.equal, currentWeek);
      final List<WorkoutPlanWeekRecord> weekRecord =
          await _workoutPlanWeekRecordDao.selectMany(
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
          status: input.status,
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
        dayWhere.and(WorkoutPlanDayRecordColumns.day.equal, currentWeekDay);
        final List<WorkoutPlanDayRecord> dayRecords =
            await _workoutPlanDayRecordDao.selectMany(
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
            status: input.status,
          );
          if (createResult.isErr()) {
            return err(createResult.error);
          }
        } else {
          _logger.info(
            'Found existing workout plan day record for workout plan record $workoutPlanRecordId, week record ${weekRecordData.id} and day $currentWeekDay',
          );
          final existingDayRecord = dayRecords.first;
          if (input.status == ProgressStatus.completed &&
              existingDayRecord.status != ProgressStatus.completed) {
            final now = DateUtilities.getNowUtcUnix();
            final updatedDayRecord = existingDayRecord.copyWith(
              status: ProgressStatus.completed,
              completedAt: Nullable(now),
              updatedAt: now,
            );
            await _workoutPlanDayRecordDao.update(updatedDayRecord);
          }
        }
      }

      final updatedRecord = await _workoutPlanRecordDao.selectOne(
        workoutPlanRecordId,
      );
      if (updatedRecord == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }
      return await _toRecordDtoWithTree(updatedRecord);
    } catch (e) {
      _logger.severe(
        'Failed to get current workout plan day record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get current workout plan day record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  upsertWorkoutPlanWorkoutRecord(WorkoutPlanWorkoutRecordInput input) async {
    return updateWorkoutPlanWorkoutRecordStatus(input);
  }

  Future<Result<WorkoutPlanWeek?, ServiceError<SingleErrorTypes>>>
  _findTemplateWeek(
    int workoutPlanId,
    int week, {
    required int planVersion,
  }) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to load workout plan template week',
    );
    try {
      final WhereBuilder mainWhere = WhereBuilder();
      mainWhere.and(WorkoutPlanWeekColumns.workoutPlanId.equal, workoutPlanId);
      mainWhere.and(WorkoutPlanWeekColumns.planVersion.equal, planVersion);

      final WhereBuilder onlyStartWeekWhere = WhereBuilder();
      onlyStartWeekWhere.and(WorkoutPlanWeekColumns.startWeek.equal, week);
      onlyStartWeekWhere.and(WorkoutPlanWeekColumns.endWeek.isNull);

      final WhereBuilder betweenWeekWhere = WhereBuilder();
      betweenWeekWhere.and(
        WorkoutPlanWeekColumns.startWeek.lessThanOrEqual,
        week,
      );
      betweenWeekWhere.and(WorkoutPlanWeekColumns.endWeek.notNull);
      betweenWeekWhere.and(
        WorkoutPlanWeekColumns.endWeek.greaterThanOrEqual,
        week,
      );

      final WhereBuilder weekWhere = WhereBuilder();
      weekWhere.or(onlyStartWeekWhere.where!);
      weekWhere.or(betweenWeekWhere.where!);
      mainWhere.and(weekWhere.where!);

      final List<Object?> args = [
        ...mainWhere.args!,
        ...onlyStartWeekWhere.args!,
        ...betweenWeekWhere.args!,
      ];

      final List<WorkoutPlanWeek> weeks = await _workoutPlanWeekDao.selectMany(
        where: mainWhere.where,
        whereArgs: args,
        orderBy: [WorkoutPlanWeekColumns.startWeek.orderAsc],
        limit: 1,
      );
      return ok(weeks.firstOrNull);
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
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

    try {
      final weekResult = await _findTemplateWeek(
        workoutPlanId,
        week,
        planVersion: workoutPlanRecord.workoutPlanVersion,
      );
      if (weekResult.isErr()) return err(weekResult.error);
      final templateWeek = weekResult.value;
      if (templateWeek == null) {
        _logger.info(
          'No workout plan week found for workout plan $workoutPlanId and week $week',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No workout plan week found for workout plan and week',
          ),
        );
      }

      final WorkoutPlanWeekRecord weekRecord = WorkoutPlanWeekRecord.create(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanWeekId: templateWeek.id!,
        week: week,
        status: status,
        currentDay: weekDay,
      );
      final WhereBuilder dayWhere = WhereBuilder();
      dayWhere.and(
        WorkoutPlanDayColumns.workoutPlanWeekId.equal,
        templateWeek.id!,
      );
      dayWhere.and(WorkoutPlanDayColumns.day.equal, weekDay);

      final List<WorkoutPlanDay> dayData = await _workoutPlanDayDao.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayData.isEmpty) {
        _logger.info(
          'No workout plan day found for workout plan week ${templateWeek.id} and day $weekDay',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'No workout plan day found for workout plan week and day',
          ),
        );
      }
      final int workoutPlanDayId = dayData.first.id!;

      final (
        int weekRecordId,
        WorkoutPlanDayRecord dayRecord,
      ) = await _workoutPlanRecordDao.startTransaction((txn) async {
        final int weekRecordId = await _workoutPlanWeekRecordDao.insert(
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
        final int dayRecordId = await _workoutPlanDayRecordDao.insert(
          dayRecord,
          txn,
        );

        final WorkoutPlanRecord updatedRecord = workoutPlanRecord.copyWith(
          currentWeek: week,
          currentDay: weekDay,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutPlanRecordDao.update(updatedRecord, txn);
        return (weekRecordId, dayRecord.copyWith(id: Nullable(dayRecordId)));
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
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create workout plan week record',
        ),
      );
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
    dayWhere.and(WorkoutPlanDayColumns.day.equal, weekDay);
    try {
      final List<WorkoutPlanDay> dayData = await _workoutPlanDayDao.selectMany(
        where: dayWhere.where,
        whereArgs: dayWhere.args,
        limit: 1,
      );
      if (dayData.isEmpty) {
        _logger.info(
          'No workout plan day found for workout plan week ${weekRecord.workoutPlanWeekId} and day $weekDay',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'No workout plan day found for workout plan week and day',
          ),
        );
      }

      final int workoutPlanDayId = dayData.first.id!;
      final WorkoutPlanDayRecord dayRecord = WorkoutPlanDayRecord.create(
        workoutPlanRecordId: workoutPlanRecordId,
        workoutPlanWeekRecordId: workoutPlanWeekRecordId,
        workoutPlanDayId: workoutPlanDayId,
        day: weekDay,
        status: status,
      );

      final int dayRecordId = await _workoutPlanDayRecordDao.startTransaction((
        txn,
      ) async {
        final int dayRecordId = await _workoutPlanDayRecordDao.insert(
          dayRecord,
          txn,
        );

        final WorkoutPlanRecord updatedRecord = workoutPlanRecord.copyWith(
          currentWeek: weekRecord.week,
          currentDay: weekDay,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutPlanRecordDao.update(updatedRecord, txn);

        final WorkoutPlanWeekRecord updatedWeekRecord = weekRecord.copyWith(
          currentDay: weekDay,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutPlanWeekRecordDao.update(updatedWeekRecord, txn);

        return dayRecordId;
      });

      _logger.info(
        'Created workout plan day record with id $dayRecordId for workout plan record $workoutPlanRecordId',
      );
      return ok(
        WorkoutPlanDayRecordDto.fromModel(
          dayRecord.copyWith(id: Nullable(dayRecordId)),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan day record for workout plan record $workoutPlanRecordId',
        e,
      );
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create workout plan day record',
        ),
      );
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  updateWorkoutPlanWorkoutRecordStatus(
    WorkoutPlanWorkoutRecordInput input,
  ) async {
    final workoutPlanRecordId = input.workoutPlanRecordId;
    final status = input.status;
    _logger.info('Updating workout plan workout record status to $status');
    try {
      final WorkoutPlanRecord? record = await _workoutPlanRecordDao.selectOne(
        workoutPlanRecordId,
      );
      if (record == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan record not found',
          ),
        );
      }

      final week = input.week ?? record.currentWeek;
      final weekDay = input.weekDay ?? record.currentDay;
      final workoutPosition =
          input.workoutPosition ?? record.currentWorkoutPosition;

      final weekWhere = WhereBuilder();
      weekWhere.and(
        WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
        workoutPlanRecordId,
      );
      weekWhere.and(WorkoutPlanWeekRecordColumns.week.equal, week);
      final List<WorkoutPlanWeekRecord> weekRecords =
          await _workoutPlanWeekRecordDao.selectMany(
            where: weekWhere.where,
            whereArgs: weekWhere.args,
            limit: 1,
          );
      final WorkoutPlanWeekRecord? existingWeekRecord = weekRecords.isNotEmpty
          ? weekRecords.first
          : null;

      WorkoutPlanWeek? templateWeek;
      if (existingWeekRecord == null) {
        final weekResult = await _findTemplateWeek(
          record.workoutPlanId,
          week,
          planVersion: record.workoutPlanVersion,
        );
        if (weekResult.isErr()) return err(weekResult.error);
        templateWeek = weekResult.value;
        if (templateWeek == null) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description:
                  'No workout plan week found for workout plan and week',
            ),
          );
        }
      }
      final int workoutPlanWeekId =
          existingWeekRecord?.workoutPlanWeekId ?? templateWeek!.id!;

      WorkoutPlanDayRecord? existingDayRecord;
      if (existingWeekRecord != null) {
        final dayWhere = WhereBuilder();
        dayWhere.and(
          WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.equal,
          existingWeekRecord.id!,
        );
        dayWhere.and(WorkoutPlanDayRecordColumns.day.equal, weekDay);
        final List<WorkoutPlanDayRecord> dayRecords =
            await _workoutPlanDayRecordDao.selectMany(
              where: dayWhere.where,
              whereArgs: dayWhere.args,
              limit: 1,
            );
        if (dayRecords.isNotEmpty) {
          existingDayRecord = dayRecords.first;
        }
      }

      WorkoutPlanDay? templateDay;
      if (existingDayRecord == null) {
        final dayTemplateWhere = WhereBuilder();
        dayTemplateWhere.and(
          WorkoutPlanDayColumns.workoutPlanWeekId.equal,
          workoutPlanWeekId,
        );
        dayTemplateWhere.and(WorkoutPlanDayColumns.day.equal, weekDay);
        final List<WorkoutPlanDay> dayData = await _workoutPlanDayDao
            .selectMany(
              where: dayTemplateWhere.where,
              whereArgs: dayTemplateWhere.args,
              limit: 1,
            );
        if (dayData.isEmpty) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description:
                  'No workout plan day found for workout plan week and day',
            ),
          );
        }
        templateDay = dayData.first;
      }
      final int workoutPlanDayId =
          existingDayRecord?.workoutPlanDayId ?? templateDay!.id!;

      WorkoutPlanWorkoutRecord? existingWorkoutRecord;
      if (existingDayRecord != null) {
        final workoutWhere = WhereBuilder();
        workoutWhere.and(
          WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.equal,
          existingDayRecord.id!,
        );
        workoutWhere.and(
          WorkoutPlanWorkoutRecordColumns.position.equal,
          workoutPosition,
        );
        final List<WorkoutPlanWorkoutRecord> workoutRecords =
            await _workoutPlanWorkoutRecordDao.selectMany(
              where: workoutWhere.where,
              whereArgs: workoutWhere.args,
              limit: 1,
            );
        if (workoutRecords.isNotEmpty) {
          existingWorkoutRecord = workoutRecords.first;
        }
      }

      WorkoutPlanWorkout? templateWorkout;
      if (existingWorkoutRecord == null) {
        final workoutTemplateWhere = WhereBuilder();
        workoutTemplateWhere.and(
          WorkoutPlanWorkoutColumns.workoutPlanDayId.equal,
          workoutPlanDayId,
        );
        workoutTemplateWhere.and(
          WorkoutPlanWorkoutColumns.position.equal,
          workoutPosition,
        );
        final workoutPlansWorkouts = await _workoutPlanWorkoutDao.selectMany(
          where: workoutTemplateWhere.where,
          whereArgs: workoutTemplateWhere.args,
          limit: 1,
        );
        if (workoutPlansWorkouts.isEmpty) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Workout plan workout not found',
            ),
          );
        }
        templateWorkout = workoutPlansWorkouts.first;
      }

      final now = DateUtilities.getNowUtcUnix();

      final updatedRecord = await _workoutPlanRecordDao.startTransaction((
        txn,
      ) async {
        WorkoutPlanRecord currentRecord = record;
        late WorkoutPlanWeekRecord weekRecord;
        if (existingWeekRecord == null) {
          final newWeekRecord = WorkoutPlanWeekRecord.create(
            workoutPlanRecordId: workoutPlanRecordId,
            workoutPlanWeekId: workoutPlanWeekId,
            week: week,
            status: ProgressStatus.inProgress,
            currentDay: weekDay,
          );
          final weekRecordId = await _workoutPlanWeekRecordDao.insert(
            newWeekRecord,
            txn,
          );
          weekRecord = newWeekRecord.copyWith(id: Nullable(weekRecordId));
        } else {
          weekRecord = existingWeekRecord;
          if (existingDayRecord == null) {
            weekRecord = weekRecord.copyWith(
              currentDay: weekDay,
              updatedAt: now,
            );
            await _workoutPlanWeekRecordDao.update(weekRecord, txn);
          }
        }

        late WorkoutPlanDayRecord dayRecord;
        if (existingDayRecord == null) {
          final newDayRecord = WorkoutPlanDayRecord.create(
            workoutPlanRecordId: workoutPlanRecordId,
            workoutPlanWeekRecordId: weekRecord.id!,
            workoutPlanDayId: workoutPlanDayId,
            day: weekDay,
            week: week,
            status: ProgressStatus.inProgress,
          );
          final dayRecordId = await _workoutPlanDayRecordDao.insert(
            newDayRecord,
            txn,
          );
          dayRecord = newDayRecord.copyWith(id: Nullable(dayRecordId));

          currentRecord = currentRecord.copyWith(
            currentWeek: week,
            currentDay: weekDay,
            updatedAt: now,
          );
          await _workoutPlanRecordDao.update(currentRecord, txn);
        } else {
          dayRecord = existingDayRecord;
        }

        late WorkoutPlanWorkoutRecord updatedWorkoutRecord;
        if (existingWorkoutRecord == null) {
          final newWorkoutRecord =
              WorkoutPlanWorkoutRecord.create(
                workoutPlanRecordId: workoutPlanRecordId,
                workoutPlanWeekRecordId: weekRecord.id!,
                workoutPlanDayRecordId: dayRecord.id!,
                workoutPlanWorkoutId: templateWorkout!.id!,
                workoutRecordId: input.workoutRecordId,
                position: workoutPosition,
                startedAt: input.startedAt != null
                    ? DateUtilities.getDateUnix(input.startedAt!)
                    : null,
                status: status,
              ).copyWith(
                completedAt: Nullable(
                  status == ProgressStatus.completed ? now : null,
                ),
                updatedAt: now,
              );
          final workoutRecordId = await _workoutPlanWorkoutRecordDao.insert(
            newWorkoutRecord,
            txn,
          );
          updatedWorkoutRecord = newWorkoutRecord.copyWith(
            id: Nullable(workoutRecordId),
          );
        } else {
          updatedWorkoutRecord = existingWorkoutRecord.copyWith(
            workoutRecordId: input.workoutRecordId,
            startedAt: input.startedAt != null
                ? DateUtilities.getDateUnix(input.startedAt!)
                : existingWorkoutRecord.startedAt,
            status: status,
            completedAt: Nullable(
              status == ProgressStatus.completed ? now : null,
            ),
            updatedAt: now,
          );
          await _workoutPlanWorkoutRecordDao.update(updatedWorkoutRecord, txn);
        }

        final planWorkouts = await _workoutPlanWorkoutRecordDao.selectMany(
          where: WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.equal,
          whereArgs: [workoutPlanRecordId],
          trx: txn,
        );
        final allWorkouts = planWorkouts
            .where((w) => w.workoutPlanDayRecordId == dayRecord.id!)
            .toList();
        final scheduledDay = await _workoutPlanDayDao.selectOne(
          dayRecord.workoutPlanDayId,
          txn,
        );
        final int scheduledDayWorkouts = scheduledDay?.totalWorkouts ?? 0;
        final bool allCompletedOrSkipped =
            scheduledDayWorkouts > 0 &&
            allWorkouts.length >= scheduledDayWorkouts &&
            allWorkouts.every(
              (w) =>
                  w.status == ProgressStatus.completed ||
                  w.status == ProgressStatus.skipped,
            );

        if (allCompletedOrSkipped) {
          final updatedDayRecord = dayRecord.copyWith(
            status: ProgressStatus.completed,
            completedAt: Nullable(now),
            updatedAt: now,
          );
          await _workoutPlanDayRecordDao.update(updatedDayRecord, txn);

          final weekWorkouts = planWorkouts
              .where((w) => w.workoutPlanWeekRecordId == weekRecord.id!)
              .toList();
          final scheduledWeek = await _workoutPlanWeekDao.selectOne(
            weekRecord.workoutPlanWeekId,
            txn,
          );
          final int scheduledWeekWorkouts = scheduledWeek?.totalWorkouts ?? 0;
          final bool allWeekWorkoutsCompleted =
              scheduledWeekWorkouts > 0 &&
              weekWorkouts.length >= scheduledWeekWorkouts &&
              weekWorkouts.every(
                (workout) =>
                    workout.status == ProgressStatus.completed ||
                    workout.status == ProgressStatus.skipped,
              );

          if (allWeekWorkoutsCompleted) {
            final updatedWeekRecord = weekRecord.copyWith(
              status: ProgressStatus.completed,
              completedAt: Nullable(now),
              updatedAt: now,
            );
            await _workoutPlanWeekRecordDao.update(updatedWeekRecord, txn);

            final scheduledResult = await _countScheduledWorkouts(
              currentRecord.workoutPlanId,
              currentRecord.workoutPlanVersion,
              SingleErrorTypes.operationFailure,
              txn,
            );
            // The workout, day, and week writes must roll back if counting fails.
            if (scheduledResult.isErr()) throw scheduledResult.error;
            final scheduledWorkouts = scheduledResult.value;
            final allPlanWorkoutsCompleted =
                scheduledWorkouts > 0 &&
                planWorkouts.length >= scheduledWorkouts &&
                planWorkouts.every(
                  (workout) =>
                      workout.status == ProgressStatus.completed ||
                      workout.status == ProgressStatus.skipped,
                );

            if (allPlanWorkoutsCompleted) {
              currentRecord = currentRecord.copyWith(
                status: ProgressStatus.completed,
                completedAt: Nullable(now),
                updatedAt: now,
              );
              await _workoutPlanRecordDao.update(currentRecord, txn);
            } else if (currentRecord.status == ProgressStatus.completed ||
                currentRecord.completedAt != null) {
              currentRecord = currentRecord.copyWith(
                status: ProgressStatus.inProgress,
                completedAt: const Nullable(null),
                updatedAt: now,
              );
              await _workoutPlanRecordDao.update(currentRecord, txn);
            }
          } else {
            if (weekRecord.status == ProgressStatus.completed ||
                weekRecord.completedAt != null) {
              weekRecord = weekRecord.copyWith(
                status: ProgressStatus.inProgress,
                completedAt: const Nullable(null),
                updatedAt: now,
              );
              await _workoutPlanWeekRecordDao.update(weekRecord, txn);
            }
            if (currentRecord.status == ProgressStatus.completed ||
                currentRecord.completedAt != null) {
              currentRecord = currentRecord.copyWith(
                status: ProgressStatus.inProgress,
                completedAt: const Nullable(null),
                updatedAt: now,
              );
              await _workoutPlanRecordDao.update(currentRecord, txn);
            }
          }
        } else {
          if (dayRecord.status != ProgressStatus.inProgress ||
              dayRecord.completedAt != null) {
            final updatedDayRecord = dayRecord.copyWith(
              status: ProgressStatus.inProgress,
              completedAt: const Nullable(null),
              updatedAt: now,
            );
            await _workoutPlanDayRecordDao.update(updatedDayRecord, txn);
          }
          if (weekRecord.status == ProgressStatus.completed ||
              weekRecord.completedAt != null) {
            weekRecord = weekRecord.copyWith(
              status: ProgressStatus.inProgress,
              completedAt: const Nullable(null),
              updatedAt: now,
            );
            await _workoutPlanWeekRecordDao.update(weekRecord, txn);
          }
          if (currentRecord.status == ProgressStatus.completed ||
              currentRecord.completedAt != null) {
            currentRecord = currentRecord.copyWith(
              status: ProgressStatus.inProgress,
              completedAt: const Nullable(null),
              updatedAt: now,
            );
            await _workoutPlanRecordDao.update(currentRecord, txn);
          }
        }
        if (currentRecord.status == ProgressStatus.inProgress) {
          final abandoned = await _abandonOtherActiveRecords(
            txn,
            now,
            exceptId: workoutPlanRecordId,
          );
          if (abandoned.isErr()) throw abandoned.error;
        }
        return currentRecord;
      });

      return await _toRecordDtoWithTree(updatedRecord);
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to complete workout plan workout record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to complete workout plan workout record',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
  removeWorkoutPlanWorkoutRecord({
    required int workoutPlanRecordId,
    required int workoutRecordId,
  }) async {
    try {
      final where = WhereBuilder()
        ..and(
          WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.equal,
          workoutPlanRecordId,
        )
        ..and(
          WorkoutPlanWorkoutRecordColumns.workoutRecordId.equal,
          workoutRecordId,
        );
      await _workoutPlanWorkoutRecordDao.deleteMany(
        where: where.where!,
        whereArgs: where.args!,
      );
      return ok(null);
    } catch (error) {
      _logger.severe(
        'Failed to remove workout from workout plan record',
        error,
      );
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to remove workout from workout plan',
        ),
      );
    }
  }

  Future<Result<List<WorkoutPlanWeekRecordDto>, ServiceError<SingleErrorTypes>>>
  _loadWeeksTree(int workoutPlanRecordId) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to load workout plan record schedule',
    );
    try {
      final results = await Future.wait([
        _workoutPlanWeekRecordDao.selectMany(
          where: WorkoutPlanWeekRecordColumns.workoutPlanRecordId.equal,
          whereArgs: [workoutPlanRecordId],
          orderBy: [WorkoutPlanWeekRecordColumns.week.orderAsc],
        ),
        _workoutPlanDayRecordDao.selectMany(
          where: WorkoutPlanDayRecordColumns.workoutPlanRecordId.equal,
          whereArgs: [workoutPlanRecordId],
          orderBy: [
            WorkoutPlanDayRecordColumns.week.orderAsc,
            WorkoutPlanDayRecordColumns.day.orderAsc,
          ],
        ),
        _workoutPlanWorkoutRecordDao.selectMany(
          where: WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.equal,
          whereArgs: [workoutPlanRecordId],
          orderBy: [WorkoutPlanWorkoutRecordColumns.position.orderAsc],
        ),
      ]);
      final List<WorkoutPlanWeekRecord> weeks =
          results[0] as List<WorkoutPlanWeekRecord>;
      final List<WorkoutPlanDayRecord> days =
          results[1] as List<WorkoutPlanDayRecord>;
      final List<WorkoutPlanWorkoutRecord> workouts =
          results[2] as List<WorkoutPlanWorkoutRecord>;
      final Map<int, List<WorkoutPlanWorkoutRecordDto>> workoutsMap = workouts
          .fold({}, (map, workout) {
            map.update(
              workout.workoutPlanDayRecordId,
              (list) =>
                  list..add(WorkoutPlanWorkoutRecordDto.fromModel(workout)),
              ifAbsent: () => [WorkoutPlanWorkoutRecordDto.fromModel(workout)],
            );
            return map;
          });

      final Map<int, List<WorkoutPlanDayRecordDto>> daysMap = days.fold({}, (
        map,
        day,
      ) {
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
      });

      return ok(
        weeks
            .map(
              (week) => WorkoutPlanWeekRecordDto.fromModel(
                week,
                days: daysMap[week.id],
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<WorkoutPlanRecordDto, ServiceError<SingleErrorTypes>>>
  _toRecordDtoWithTree(WorkoutPlanRecord record) async {
    final weeks = await _loadWeeksTree(record.id!);
    if (weeks.isErr()) return err(weeks.error);
    return ok(WorkoutPlanRecordDto.fromModel(record, weeks: weeks.value));
  }
}
