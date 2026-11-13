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
import '../../models/sqlite/exercise_model.dart';
import '../../models/sqlite/workout_model.dart';
import '../../models/sqlite/workout_record_model.dart';
import '../../models/sqlite/workout_set_exercise_record_model.dart';
import '../../models/sqlite/workout_set_record_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/dao.dart' show Dao;
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/json_data.dart';
import '../../utils/where_builder.dart';
import '../core/dtos/paginated_dto.dart';
import '../core/repository.dart';
import '../core/repository_helpers.dart';
import '../exercises/dtos/exercise_dto.dart';
import './dtos/workout_dto.dart';
import './dtos/workout_record_dto.dart';
import './dtos/workout_set_exercise_record_dto.dart';
import './dtos/workout_set_record_dto.dart';
import './inputs/workout_record_batch_input.dart';
import './inputs/workout_record_input.dart';
import './inputs/workout_set_exercise_record_input.dart';
import './inputs/workout_set_record_batch_input.dart';
import './inputs/workout_set_record_input.dart';

final class WorkoutRecordRepository implements Repository {
  final Dao<WorkoutRecord> _workoutRecordDao;
  final Dao<WorkoutSetRecord> _setRecordDao;
  final Dao<WorkoutSetExerciseRecord> _setExerciseRecordDao;
  final Dao<Workout> _workoutDao;
  final Dao<Exercise> _exerciseDao;

  final Logger _logger = Logger('Workout Record Repository');

  WorkoutRecordRepository({
    required this._workoutRecordDao,
    required this._setRecordDao,
    required this._setExerciseRecordDao,
    required this._workoutDao,
    required this._exerciseDao,
  });

  factory WorkoutRecordRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return WorkoutRecordRepository(
      workoutRecordDao: Dao<WorkoutRecord>(
        databaseHelper: helper,
        tableName: WorkoutRecord.table,
        fromMap: WorkoutRecord.fromMap,
      ),
      setRecordDao: Dao<WorkoutSetRecord>(
        databaseHelper: helper,
        tableName: WorkoutSetRecord.table,
        fromMap: WorkoutSetRecord.fromMap,
      ),
      setExerciseRecordDao: Dao<WorkoutSetExerciseRecord>(
        databaseHelper: helper,
        tableName: WorkoutSetExerciseRecord.table,
        fromMap: WorkoutSetExerciseRecord.fromMap,
      ),
      workoutDao: Dao<Workout>(
        databaseHelper: helper,
        tableName: Workout.table,
        fromMap: Workout.fromMap,
      ),
      exerciseDao: Dao<Exercise>(
        databaseHelper: helper,
        tableName: Exercise.table,
        fromMap: Exercise.fromMap,
      ),
    );
  }

  Future<
    Result<
      PaginatedDto<WorkoutRecordDto, WorkoutRecord>,
      ServiceError<SingleErrorTypes>
    >
  >
  getWorkoutRecords({
    int? workoutId,
    (DateTime start, DateTime end)? dateRange,
    bool skipSkipped = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout records');
    final WhereBuilder query = WhereBuilder();

    if (skipSkipped) {
      query.and(
        WorkoutRecordColumns.status.notEqual,
        ProgressStatus.skipped.value,
      );
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
        WorkoutRecordColumns.startedAt.greaterThanOrEqual,
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
        WorkoutRecordColumns.startedAt.lessThanOrEqual,
        DateUtilities.getDateUnix(endOfDay),
      );
    }

    try {
      if (workoutId != null) {
        final Workout? workout = await _workoutDao.selectOne(workoutId);
        if (workout == null) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Workout with id: $workoutId not found',
            ),
          );
        }

        query.and(WorkoutRecordColumns.workoutId.equal, workoutId);
      }

      final pageResult = await fetchPaginatedWithTotal(
        failureType: SingleErrorTypes.operationFailure,
        dao: _workoutRecordDao,
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutRecordColumns.startedAt.orderDesc],
      );
      if (pageResult.isErr()) return err(pageResult.error);
      final (records, total) = pageResult.value;
      _logger.info('Got ${records.length} workout records');
      if (workoutId != null || records.isEmpty) {
        return ok(
          PaginatedDto<WorkoutRecordDto, WorkoutRecord>.mapData(
            data: records,
            mapper: WorkoutRecordDto.fromModel,
            total: total,
            limit: limit,
            offset: offset,
          ),
        );
      }

      final workoutsResult = await selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _workoutDao,
        column: WorkoutColumns.id,
        values: records.map((r) => r.workoutId),
      );
      if (workoutsResult.isErr()) return err(workoutsResult.error);
      final List<Workout> workouts = workoutsResult.value;
      final Map<int, WorkoutDto> workoutMap = {
        for (final workout in workouts)
          workout.id!: WorkoutDto.fromModel(workout),
      };

      return ok(
        PaginatedDto<WorkoutRecordDto, WorkoutRecord>.mapData(
          data: records,
          mapper: (record) => WorkoutRecordDto.fromModel(
            record,
            workout: workoutMap[record.workoutId],
          ),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get workout records', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get workout records error: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
  getWorkoutRecord(int id) async {
    _logger.info('Getting workout record with id $id');
    try {
      final WorkoutRecord? record = await _workoutRecordDao.selectOne(id);
      if (record == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout record not found',
          ),
        );
      }

      final childResults = await Future.wait([
        _setRecordDao.selectMany(
          where: WorkoutSetRecordColumns.workoutRecordId.equal,
          whereArgs: [id],
          orderBy: [
            WorkoutSetRecordColumns.workoutRecordId.orderAsc,
            WorkoutSetRecordColumns.setNumber.orderAsc,
            WorkoutSetRecordColumns.id.orderAsc,
          ],
        ),
        _setExerciseRecordDao.selectMany(
          where: WorkoutSetExerciseRecordColumns.workoutRecordId.equal,
          whereArgs: [id],
          orderBy: [
            WorkoutSetExerciseRecordColumns.workoutSetRecordId.orderAsc,
            WorkoutSetExerciseRecordColumns.position.orderAsc,
            WorkoutSetExerciseRecordColumns.id.orderAsc,
          ],
        ),
      ]);
      final setRecords = childResults[0] as List<WorkoutSetRecord>;
      if (setRecords.isEmpty) {
        _logger.info('Got workout record with id $id');
        return ok(WorkoutRecordDto.fromModel(record));
      }

      final setExerciseRecords =
          childResults[1] as List<WorkoutSetExerciseRecord>;
      if (setExerciseRecords.isEmpty) {
        _logger.info('Got workout record with id $id');
        return ok(
          WorkoutRecordDto.fromModel(
            record,
            setRecords: setRecords
                .map((sr) => WorkoutSetRecordDto.fromModel(sr))
                .toList(),
          ),
        );
      }

      final exercisesResult = await selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _exerciseDao,
        column: ExerciseColumns.id,
        values: setExerciseRecords.map((s) => s.exerciseId),
      );
      if (exercisesResult.isErr()) return err(exercisesResult.error);
      final exercises = exercisesResult.value;

      final exercisesMap = exercises.fold<Map<int, ExerciseDto>>(
        {},
        (map, exercise) =>
            map..[exercise.id!] = ExerciseDto.fromModel(exercise),
      );
      final setExerciseRecordsMap = setExerciseRecords
          .fold<Map<int, List<WorkoutSetExerciseRecordDto>>>({}, (
            map,
            setExerciseRecord,
          ) {
            map.update(
              setExerciseRecord.workoutSetRecordId,
              (list) => list
                ..add(
                  WorkoutSetExerciseRecordDto.fromModel(
                    setExerciseRecord,
                    exercise: exercisesMap[setExerciseRecord.exerciseId],
                  ),
                ),
              ifAbsent: () => [
                WorkoutSetExerciseRecordDto.fromModel(
                  setExerciseRecord,
                  exercise: exercisesMap[setExerciseRecord.exerciseId],
                ),
              ],
            );
            return map;
          });

      _logger.info('Got workout record with id $id');
      return ok(
        WorkoutRecordDto.fromModel(
          record,
          setRecords: setRecords
              .map(
                (sr) => WorkoutSetRecordDto.fromModel(
                  sr,
                  setExerciseRecords: setExerciseRecordsMap[sr.id!],
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get workout record with id $id', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get workout record error: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
  getLatestWorkoutRecord({
    int? workoutId,
    bool skipSkipped = false,
  }) async {
    _logger.info('Getting latest workout record for workout $workoutId');
    try {
      final WhereBuilder query = WhereBuilder();
      if (workoutId != null) {
        query.and(WorkoutRecordColumns.workoutId.equal, workoutId);
      }
      if (skipSkipped) {
        query.and(
          WorkoutRecordColumns.status.notEqual,
          ProgressStatus.skipped.value,
        );
      }

      final List<WorkoutRecord> records = await _workoutRecordDao.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutRecordColumns.startedAt.orderDesc],
        limit: 1,
      );
      if (records.isEmpty) {
        _logger.info('No latest workout record found for workout $workoutId');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Latest workout record not found',
          ),
        );
      }

      final record = records.first;
      WorkoutDto? workoutDto;
      if (workoutId == null) {
        final Workout? workout = await _workoutDao.selectOne(record.workoutId);
        if (workout != null) {
          workoutDto = WorkoutDto.fromModel(workout);
        }
      }

      _logger.info('Got latest workout record for workout $workoutId');
      return ok(WorkoutRecordDto.fromModel(record, workout: workoutDto));
    } catch (e) {
      _logger.severe(
        'Failed to get latest workout record for workout $workoutId',
        e,
      );
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Failed to get latest workout record error: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
  getOrCreateWorkoutRecord(WorkoutRecordInput input) async {
    _logger.info('Creating workout record');
    try {
      final Workout? workout = await _workoutDao.selectOne(input.workoutId);
      if (workout == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Workout with id: ${input.workoutId} not found',
          ),
        );
      }

      final where = WhereBuilder();
      where.and(WorkoutRecordColumns.workoutId.equal, input.workoutId);
      where.and(
        WorkoutRecordColumns.status.equal,
        ProgressStatus.inProgress.value,
      );
      final List<WorkoutRecord> records = await _workoutRecordDao.selectMany(
        where: where.where,
        whereArgs: where.args,
        limit: 1,
      );
      if (records.isNotEmpty) {
        _logger.info(
          'Found existing workout record for workout ${input.workoutId}',
        );
        return ok(WorkoutRecordDto.fromModel(records.first));
      }

      final ProgressStatus status = input.completedAt.value != null
          ? ProgressStatus.completed
          : input.droppedAt.value != null
          ? ProgressStatus.abandoned
          : ProgressStatus.inProgress;

      final WorkoutRecord record = WorkoutRecord.create(
        version: workout.version,
        workoutId: input.workoutId,
        startedAt: DateUtilities.getDateUnix(input.startedAt),
        completedAt: input.completedAt.value != null
            ? DateUtilities.getDateUnix(input.completedAt.value!)
            : null,
        droppedAt: input.droppedAt.value != null
            ? DateUtilities.getDateUnix(input.droppedAt.value!)
            : null,
        status: status,
      );
      final int id = await _workoutRecordDao.insert(record);
      _logger.info('Created workout record with id $id');
      return ok(WorkoutRecordDto.fromModel(record.copyWith(id: Nullable(id))));
    } catch (e) {
      _logger.severe('Failed to create workout record', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create workout record',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
  createWorkoutRecordWithStatus({
    required int workoutId,
    required ProgressStatus status,
  }) async {
    _logger.info('Creating workout record with status $status');
    try {
      final Workout? workout = await _workoutDao.selectOne(workoutId);
      if (workout == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Workout with id: $workoutId not found',
          ),
        );
      }

      final now = DateUtilities.getNowUtcUnix();
      final isTerminal =
          status == ProgressStatus.skipped ||
          status == ProgressStatus.abandoned ||
          status == ProgressStatus.completed;
      final WorkoutRecord record = WorkoutRecord.create(
        version: workout.version,
        workoutId: workoutId,
        startedAt: now,
        completedAt: status == ProgressStatus.completed ? now : null,
        droppedAt:
            status == ProgressStatus.skipped ||
                status == ProgressStatus.abandoned
            ? now
            : null,
        status: isTerminal ? status : ProgressStatus.inProgress,
      );
      final int id = await _workoutRecordDao.insert(record);
      _logger.info('Created workout record with id $id and status $status');
      return ok(WorkoutRecordDto.fromModel(record.copyWith(id: Nullable(id))));
    } catch (e) {
      _logger.severe('Failed to create workout record with status', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create workout record',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
  updateWorkoutRecordStatus({
    required int id,
    required ProgressStatus status,
  }) async {
    _logger.info('Updating workout record $id status to $status');
    try {
      final WorkoutRecord? record = await _workoutRecordDao.selectOne(id);
      if (record == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout record with id: $id not found',
          ),
        );
      }

      final now = DateUtilities.getNowUtcUnix();
      final updatedRecord = record.copyWith(
        status: status,
        completedAt: Nullable(
          status == ProgressStatus.completed ? now : record.completedAt,
        ),
        droppedAt: Nullable(
          status == ProgressStatus.skipped || status == ProgressStatus.abandoned
              ? (record.droppedAt ?? now)
              : record.droppedAt,
        ),
        updatedAt: now,
      );
      await _workoutRecordDao.update(updatedRecord);
      return ok(WorkoutRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to update workout record status', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update workout record status',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
  updateWorkoutRecord(int id, WorkoutRecordInput input) async {
    _logger.info('Updating workout record with id $id');
    try {
      final WorkoutRecord? record = await _workoutRecordDao.selectOne(id);
      if (record == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout record with id: $id not found',
          ),
        );
      }

      final WorkoutRecord updatedRecord = record.copyWith(
        workoutId: input.workoutId,
        startedAt: DateUtilities.getDateUnix(input.startedAt),
        completedAt: Nullable(
          input.completedAt.value != null
              ? DateUtilities.getDateUnix(input.completedAt.value!)
              : null,
        ),
        droppedAt: Nullable(
          input.droppedAt.value != null
              ? DateUtilities.getDateUnix(input.droppedAt.value!)
              : null,
        ),
        status: input.completedAt.value != null
            ? ProgressStatus.completed
            : input.droppedAt.value != null
            ? ProgressStatus.abandoned
            : ProgressStatus.inProgress,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _workoutRecordDao.update(updatedRecord);
      _logger.info('Updated workout record with id $id');
      return ok(WorkoutRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to update workout record with id $id', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update workout record error: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutRecord(
    int id,
  ) async {
    _logger.info('Deleting workout record with id $id');
    try {
      final bool deleted = await _workoutRecordDao.deleteOne(id);
      if (!deleted) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout record with id: $id not found',
          ),
        );
      }
      _logger.info('Deleted workout record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout record with id $id', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete workout record error: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetRecordDto, ServiceError<OperationErrorTypes>>>
  upsertWorkoutSetRecord(WorkoutSetRecordInput input) async {
    _logger.info('Creating workout set record');
    final whereBuild = WhereBuilder();
    whereBuild.and(
      WorkoutSetRecordColumns.workoutSetId.equal,
      input.workoutSetId,
    );
    whereBuild.and(
      WorkoutSetRecordColumns.workoutRecordId.equal,
      input.workoutRecordId,
    );
    whereBuild.and(WorkoutSetRecordColumns.setNumber.equal, input.setNumber);

    try {
      final WorkoutRecord? workoutRecord = await _workoutRecordDao.selectOne(
        input.workoutRecordId,
      );
      if (workoutRecord == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description:
                'Workout record with id: ${input.workoutRecordId} not found',
          ),
        );
      }

      final List<WorkoutSetRecord> records = await _setRecordDao.selectMany(
        where: whereBuild.where,
        whereArgs: whereBuild.args,
        limit: 1,
      );

      if (records.isNotEmpty) {
        final WorkoutSetRecord record = records.first;
        final int? oldRest = record.totalRestSecs;
        final WorkoutSetRecord updatedRecord = record.copyWith(
          startedAt: DateUtilities.getDateUnix(input.startedAt),
          totalRestSecs: input.totalRestSecs,
          completedAt: Nullable(
            input.completedAt.value != null
                ? DateUtilities.getDateUnix(input.completedAt.value!)
                : null,
          ),
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutRecordDao.startTransaction((trx) async {
          await _setRecordDao.update(updatedRecord, trx);
          final updatedWorkoutRecord = workoutRecord.copyWith(
            totalRestSecs:
                workoutRecord.totalRestSecs +
                (updatedRecord.totalRestSecs ?? 0) -
                (oldRest ?? 0),
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _workoutRecordDao.update(updatedWorkoutRecord, trx);
        });

        _logger.info('Updated workout set record with id ${record.id}');
        return ok(WorkoutSetRecordDto.fromModel(updatedRecord));
      }

      final WorkoutSetRecord record = WorkoutSetRecord.create(
        workoutSetId: input.workoutSetId,
        workoutRecordId: input.workoutRecordId,
        setNumber: input.setNumber,
        startedAt: DateUtilities.getDateUnix(input.startedAt),
        totalRestSecs: input.totalRestSecs.value,
        completedAt: input.completedAt.value != null
            ? DateUtilities.getDateUnix(input.completedAt.value!)
            : null,
      );
      final int id = await _workoutRecordDao.startTransaction((trx) async {
        final int id = await _setRecordDao.insert(record, trx);

        final updatedWorkoutRecord = workoutRecord.copyWith(
          totalSets: workoutRecord.totalSets + 1,
          totalRestSecs:
              workoutRecord.totalRestSecs + (record.totalRestSecs ?? 0),
          currentSetPosition: workoutRecord.currentSetPosition + 1,
          currentSetNumber: workoutRecord.currentSetNumber + 1,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutRecordDao.update(updatedWorkoutRecord, trx);

        return id;
      });
      _logger.info('Created workout set record with id $id');
      return ok(
        WorkoutSetRecordDto.fromModel(record.copyWith(id: Nullable(id))),
      );
    } catch (e) {
      _logger.severe('Failed to create workout set record', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create workout set record',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseRecordDto, ServiceError<OperationErrorTypes>>>
  upsertWorkoutSetExerciseRecord(WorkoutSetExerciseRecordInput input) async {
    _logger.info('Creating workout set exercise record');
    try {
      final whereBuild = WhereBuilder()
        ..and(
          WorkoutSetExerciseRecordColumns.workoutSetExerciseId.equal,
          input.workoutSetExerciseId,
        )
        ..and(
          WorkoutSetExerciseRecordColumns.workoutRecordId.equal,
          input.workoutRecordId,
        )
        ..and(
          WorkoutSetExerciseRecordColumns.workoutSetRecordId.equal,
          input.workoutSetRecordId,
        )
        ..and(WorkoutSetExerciseRecordColumns.position.equal, input.position);
      final preloads = await Future.wait([
        _workoutRecordDao.selectOne(input.workoutRecordId),
        _setRecordDao.selectOne(input.workoutSetRecordId),
        _exerciseDao.selectOne(input.exerciseId),
        _setExerciseRecordDao.selectMany(
          where: whereBuild.where,
          whereArgs: whereBuild.args,
          limit: 1,
        ),
      ]);
      final WorkoutRecord? workoutRecord = preloads[0] as WorkoutRecord?;
      if (workoutRecord == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description:
                'Workout record with id: ${input.workoutRecordId} not found',
          ),
        );
      }

      final WorkoutSetRecord? workoutSetRecord =
          preloads[1] as WorkoutSetRecord?;
      if (workoutSetRecord == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description:
                'Workout set record with id: ${input.workoutSetRecordId} not found',
          ),
        );
      }

      final Exercise? exercise = preloads[2] as Exercise?;
      if (exercise == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Exercise with id: ${input.exerciseId} not found',
          ),
        );
      }

      final List<WorkoutSetExerciseRecord> records =
          preloads[3] as List<WorkoutSetExerciseRecord>;
      if (records.isNotEmpty) {
        final WorkoutSetExerciseRecord record = records.first;
        final int previousReps = record.reps;
        final int previousVolume = record.reps * record.weightGrams;
        final WorkoutSetExerciseRecord updatedRecord = record.copyWith(
          reps: input.reps,
          weightGrams: input.weight,
          difficulty: input.difficulty,
          exerciseId: input.exerciseId,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutRecordDao.startTransaction((trx) async {
          await _setExerciseRecordDao.update(updatedRecord, trx);
          final updatedWorkoutRecord = workoutRecord.copyWith(
            totalReps: workoutRecord.totalReps + (input.reps - previousReps),
            totalVolume:
                workoutRecord.totalVolume +
                (input.reps * input.weight - previousVolume),
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _workoutRecordDao.update(updatedWorkoutRecord, trx);
        });

        return ok(WorkoutSetExerciseRecordDto.fromModel(updatedRecord));
      }

      final WorkoutSetExerciseRecord record = WorkoutSetExerciseRecord.create(
        workoutSetExerciseId: input.workoutSetExerciseId,
        workoutRecordId: input.workoutRecordId,
        workoutSetRecordId: input.workoutSetRecordId,
        exerciseId: input.exerciseId,
        position: input.position,
        reps: input.reps,
        weightGrams: input.weight,
        difficulty: input.difficulty,
      );
      final int id = await _workoutRecordDao.startTransaction((trx) async {
        final int id = await _setExerciseRecordDao.insert(record, trx);
        final updatedWorkoutRecord = workoutRecord.copyWith(
          totalReps: workoutRecord.totalReps + input.reps,
          totalVolume: workoutRecord.totalVolume + (input.reps * input.weight),
          muscleGroups: {...workoutRecord.muscleGroups, exercise.muscleGroup},
          muscles: workoutRecord.muscles.addOther(exercise.muscles),
          currentExercisePosition: workoutRecord.currentExercisePosition + 1,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _workoutRecordDao.update(updatedWorkoutRecord, trx);
        return id;
      });
      _logger.info('Created workout set exercise record with id $id');

      return ok(
        WorkoutSetExerciseRecordDto.fromModel(
          record.copyWith(id: Nullable(id)),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to create workout set exercise record', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create workout set exercise record',
        ),
      );
    }
  }

  Future<
    Result<
      ({
        int totalRestSecs,
        int totalReps,
        int totalVolume,
        Set<MuscleGroup> muscleGroups,
        TargetMuscles muscles,
        Map<int, ExerciseDto> exerciseMap,
      }),
      ServiceError<OperationErrorTypes>
    >
  >
  _prepareBatchRecordData(WorkoutRecordBatchInput input) async {
    int totalRestSecs = 0;
    int totalReps = 0;
    int totalVolume = 0;
    final Set<int> allExerciseIds = {};

    for (final set in input.sets) {
      totalRestSecs += set.totalRestSecs;
      for (final ex in set.exercises) {
        totalReps += ex.reps;
        totalVolume += ex.reps * ex.weight;
        allExerciseIds.add(ex.exerciseId);
      }
    }

    final fetchedExercisesResult = await selectManyInChunks(
      failureType: OperationErrorTypes.operationFailure,
      dao: _exerciseDao,
      column: ExerciseColumns.id,
      values: allExerciseIds,
    );
    if (fetchedExercisesResult.isErr()) {
      return err(fetchedExercisesResult.error);
    }
    final fetchedExercises = fetchedExercisesResult.value;
    final Set<MuscleGroup> muscleGroups = {};
    TargetMuscles muscles = const TargetMuscles(
      primary: <Muscle>{},
      secondary: <Muscle>{},
    );
    final exerciseMap = <int, ExerciseDto>{};
    for (final exercise in fetchedExercises) {
      muscleGroups.add(exercise.muscleGroup);
      muscles = muscles.addOther(exercise.muscles);
      if (exercise.id != null) {
        exerciseMap[exercise.id!] = ExerciseDto.fromModel(exercise);
      }
    }

    return ok((
      totalRestSecs: totalRestSecs,
      totalReps: totalReps,
      totalVolume: totalVolume,
      muscleGroups: muscleGroups,
      muscles: muscles,
      exerciseMap: exerciseMap,
    ));
  }

  Future<Result<List<WorkoutSetRecordDto>, ServiceError<OperationErrorTypes>>>
  _insertBatchSetsAndExercises({
    required Transaction trx,
    required int workoutRecordId,
    required List<WorkoutSetRecordBatchInput> sets,
    required Map<int, ExerciseDto> exerciseMap,
  }) async {
    const failure = ServiceError(
      type: OperationErrorTypes.operationFailure,
      description: 'Failed to save workout record sets',
    );
    try {
      final List<WorkoutSetRecordDto> setRecordDtos = [];
      for (final setDto in sets) {
        final WorkoutSetRecord setRecord = WorkoutSetRecord.create(
          workoutSetId: setDto.workoutSetId,
          workoutRecordId: workoutRecordId,
          setNumber: setDto.setNumber,
          startedAt: DateUtilities.getDateUnix(setDto.startedAt),
          completedAt: setDto.completedAt != null
              ? DateUtilities.getDateUnix(setDto.completedAt!)
              : null,
          totalRestSecs: setDto.totalRestSecs,
        );
        final int setRecordId = await _setRecordDao.insert(setRecord, trx);
        if (setRecordId <= 0) return err(failure);

        final exercises = <(int, WorkoutSetExerciseRecordDto)>[];
        for (final exDto in setDto.exercises) {
          final WorkoutSetExerciseRecord exRecord =
              WorkoutSetExerciseRecord.create(
                workoutSetExerciseId: exDto.workoutSetExerciseId,
                workoutRecordId: workoutRecordId,
                workoutSetRecordId: setRecordId,
                exerciseId: exDto.exerciseId,
                position: exDto.position,
                reps: exDto.reps,
                weightGrams: exDto.weight,
                difficulty: exDto.difficulty,
              );
          final int exRecordId = await _setExerciseRecordDao.insert(
            exRecord,
            trx,
          );
          if (exRecordId <= 0) return err(failure);
          exercises.add((
            exDto.position,
            WorkoutSetExerciseRecordDto.fromModel(
              exRecord.copyWith(id: Nullable(exRecordId)),
              exercise: exerciseMap[exDto.exerciseId],
            ),
          ));
        }

        exercises.sort((a, b) {
          final byPosition = a.$1.compareTo(b.$1);
          return byPosition == 0 ? a.$2.id.compareTo(b.$2.id) : byPosition;
        });
        setRecordDtos.add(
          WorkoutSetRecordDto.fromModel(
            setRecord.copyWith(id: Nullable(setRecordId)),
            setExerciseRecords: exercises.isEmpty
                ? null
                : exercises.map((exercise) => exercise.$2).toList(),
          ),
        );
      }
      setRecordDtos.sort((a, b) {
        final bySetNumber = a.setNumber.compareTo(b.setNumber);
        return bySetNumber == 0 ? a.id.compareTo(b.id) : bySetNumber;
      });
      return ok(setRecordDtos);
    } catch (error, stackTrace) {
      _logger.severe('Failed to save workout record sets', error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
  batchCreateWorkoutRecord(WorkoutRecordBatchInput input) async {
    _logger.info('Batch creating workout record');
    try {
      final Workout? workout = await _workoutDao.selectOne(input.workoutId);
      if (workout == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Workout with id: ${input.workoutId} not found',
          ),
        );
      }

      final preparedResult = await _prepareBatchRecordData(input);
      if (preparedResult.isErr()) return err(preparedResult.error);
      final prepared = preparedResult.value;
      final WorkoutRecord baseRecord = WorkoutRecord.create(
        version: input.version,
        workoutId: input.workoutId,
        startedAt: DateUtilities.getDateUnix(input.startedAt),
        completedAt: DateUtilities.getDateUnix(input.completedAt),
        status: ProgressStatus.completed,
        totalSets: input.sets.length,
        totalRestSecs: prepared.totalRestSecs,
        totalReps: prepared.totalReps,
        totalVolume: prepared.totalVolume,
        muscleGroups: prepared.muscleGroups,
        muscles: prepared.muscles,
      );

      final createdDto = await _workoutRecordDao.startTransaction((trx) async {
        final int recordId = await _workoutRecordDao.insert(baseRecord, trx);
        final savedChildren = await _insertBatchSetsAndExercises(
          trx: trx,
          workoutRecordId: recordId,
          sets: input.sets,
          exerciseMap: prepared.exerciseMap,
        );
        // Throw inside the transaction to roll back earlier writes.
        if (savedChildren.isErr()) throw savedChildren.error;
        final setRecordDtos = savedChildren.value;
        return WorkoutRecordDto.fromModel(
          baseRecord.copyWith(id: Nullable(recordId)),
          setRecords: setRecordDtos.isEmpty ? null : setRecordDtos,
        );
      });
      _logger.info('Batch created workout record with id ${createdDto.id}');
      return ok(createdDto);
    } on ServiceError<OperationErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to batch create workout record', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to batch create workout record',
        ),
      );
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
  batchUpdateWorkoutRecord(
    int workoutRecordId,
    WorkoutRecordBatchInput input,
  ) async {
    _logger.info('Batch updating workout record with id $workoutRecordId');
    try {
      final WorkoutRecord? record = await _workoutRecordDao.selectOne(
        workoutRecordId,
      );
      if (record == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Workout record with id: $workoutRecordId not found',
          ),
        );
      }

      final preparedResult = await _prepareBatchRecordData(input);
      if (preparedResult.isErr()) return err(preparedResult.error);
      final prepared = preparedResult.value;
      final updatedRecord = record.copyWith(
        workoutId: input.workoutId,
        version: input.version,
        startedAt: DateUtilities.getDateUnix(input.startedAt),
        completedAt: Nullable(DateUtilities.getDateUnix(input.completedAt)),
        droppedAt: const Nullable(null),
        status: ProgressStatus.completed,
        totalSets: input.sets.length,
        totalRestSecs: prepared.totalRestSecs,
        totalReps: prepared.totalReps,
        totalVolume: prepared.totalVolume,
        muscleGroups: prepared.muscleGroups,
        muscles: prepared.muscles,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );

      final updatedDto = await _workoutRecordDao.startTransaction((trx) async {
        await _setExerciseRecordDao.deleteMany(
          where: WorkoutSetExerciseRecordColumns.workoutRecordId.equal,
          whereArgs: [workoutRecordId],
          trx: trx,
        );
        await _setRecordDao.deleteMany(
          where: WorkoutSetRecordColumns.workoutRecordId.equal,
          whereArgs: [workoutRecordId],
          trx: trx,
        );
        await _workoutRecordDao.update(updatedRecord, trx);

        final savedChildren = await _insertBatchSetsAndExercises(
          trx: trx,
          workoutRecordId: workoutRecordId,
          sets: input.sets,
          exerciseMap: prepared.exerciseMap,
        );
        // Throw inside the transaction to roll back earlier writes.
        if (savedChildren.isErr()) throw savedChildren.error;
        final setRecordDtos = savedChildren.value;
        return WorkoutRecordDto.fromModel(
          updatedRecord,
          setRecords: setRecordDtos.isEmpty ? null : setRecordDtos,
        );
      });
      _logger.info('Batch updated workout record with id $workoutRecordId');
      return ok(updatedDto);
    } on ServiceError<OperationErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to batch update workout record', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to batch update workout record',
        ),
      );
    }
  }
}
