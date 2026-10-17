import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/exercise_record_model.dart';
import '../models/repository.dart';
import '../models/strength_goal_model.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/exercise_dto.dart';
import 'dtos/exercise_record_dto.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/strength_goal_dto.dart';
import 'inputs/exercise_record_input.dart';
import 'inputs/strength_goal_input.dart';

class ExerciseRecordService {
  ExerciseRecordService._();

  static final ExerciseRecordService _instance = ExerciseRecordService._();

  factory ExerciseRecordService() => _instance;

  final Logger _logger = Logger('Exercise Record Service');

  final Repository<ExerciseRecord> _repository = Repository<ExerciseRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: ExerciseRecord.table,
    fromMap: ExerciseRecord.fromMap,
  );

  final Repository<Exercise> _exerciseRepository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: Exercise.fromMap,
  );

  final Repository<StrengthGoal> _strengthGoalRepository =
      Repository<StrengthGoal>(
        databaseHelper: DatabaseHelper(),
        tableName: StrengthGoal.table,
        fromMap: StrengthGoal.fromMap,
      );

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
  createExerciseRecord(ExerciseRecordInput input) async {
    _logger.info('Creating exercise record for exercise ${input.exerciseId}');
    try {
      final Exercise? exercise = await _exerciseRepository.selectOne(
        input.exerciseId,
      );
      if (exercise == null) {
        _logger.warning("Exercise with id: ${input.exerciseId} not found");
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: "Exercise with id ${input.exerciseId} not found",
          ),
        );
      }

      final ExerciseRecord exerciseRecord = ExerciseRecord.create(
        exerciseId: input.exerciseId,
        weight: input.weight,
        reps: input.reps,
        picture: input.picture.value,
        video: input.video.value,
        recordDate: DateUtilities.getDateUnix(input.recordDate),
      );
      final int id = await _repository.insert(exerciseRecord);
      _logger.info('Created exercise record with id $id');
      return ok(
        ExerciseRecordDto.fromModel(
          exerciseRecord.copyWith(id: Nullable(id)),
          exercise: ExerciseDto.fromModel(exercise),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to create exercise record', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Failed to create exercise record with error ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
  getExerciseRecord(int id) async {
    _logger.info('Getting exercise record with id $id');
    try {
      final ExerciseRecord? exerciseRecord = await _repository.selectOne(id);
      if (exerciseRecord == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise record with id $id not found',
          ),
        );
      }

      final Exercise? exercise = await _exerciseRepository.selectOne(
        exerciseRecord.exerciseId,
      );
      if (exercise == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Exercise with id ${exerciseRecord.exerciseId} not found',
          ),
        );
      }

      _logger.info('Got exercise record with id $id');
      return ok(
        ExerciseRecordDto.fromModel(
          exerciseRecord,
          exercise: ExerciseDto.fromModel(exercise),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get exercise record with id $id', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Failed to get exercise record with error ${e.toString()}',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<ExerciseRecordDto, ExerciseRecord>,
      ServiceError<SingleErrorTypes>
    >
  >
  getExerciseRecords({
    (DateTime start, DateTime end)? dateRange,
    int? exerciseId,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting exercise records');
    final WhereBuilder query = WhereBuilder();

    if (dateRange != null) {
      final startOfDay = DateTime(
        dateRange.$1.year,
        dateRange.$1.month,
        dateRange.$1.day,
        0,
        0,
        0,
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
        ExerciseRecordColumns.recordDate.greaterThanOrEqual,
        DateUtilities.getDateUnix(startOfDay),
      );
      query.and(
        ExerciseRecordColumns.recordDate.lessThanOrEqual,
        DateUtilities.getDateUnix(endOfDay),
      );
    }

    try {
      if (exerciseId != null) {
        final Exercise? exercise = await _exerciseRepository.selectOne(
          exerciseId,
        );
        if (exercise == null) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Exercise with id $exerciseId not found',
            ),
          );
        }

        query.and('${ExerciseRecordColumns.exerciseId.value} = ?', exerciseId);
      }

      final List<ExerciseRecord> records = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [
          ExerciseRecordColumns.recordDate.orderDesc,
          ExerciseRecordColumns.id.orderDesc,
        ],
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${records.length} exercise records');

      if (exerciseId != null) {
        return ok(
          PaginatedDto<ExerciseRecordDto, ExerciseRecord>.mapData(
            data: records,
            mapper: ExerciseRecordDto.fromModel,
            total: total,
            limit: limit,
            offset: offset,
          ),
        );
      }

      final Set<int> exerciseIds = records
          .map((record) => record.exerciseId)
          .toSet();
      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where:
            '${ExerciseColumns.id.value} IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exerciseIds.length != exercises.length) {
        _logger.warning("Not all exercises were found");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Some exercises were not found',
          ),
        );
      }

      final Map<int, ExerciseDto> exerciseMap = exercises.fold({}, (map, e) {
        map[e.id!] = ExerciseDto.fromModel(e);
        return map;
      });
      return ok(
        PaginatedDto<ExerciseRecordDto, ExerciseRecord>.mapData(
          data: records,
          mapper: (record) => ExerciseRecordDto.fromModel(
            record,
            exercise: exerciseMap[record.exerciseId],
          ),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get exercise records', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Failed to get exercise records with error ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
  getLatestRecord(int exerciseId) async {
    _logger.info('Getting latest record for exercise $exerciseId');
    try {
      final List<ExerciseRecord> records = await _repository.selectMany(
        where: ExerciseRecordColumns.exerciseId.equal,
        whereArgs: [exerciseId],
        orderBy: [ExerciseRecordColumns.recordDate.orderDesc],
        limit: 1,
      );
      if (records.isEmpty) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Latest exercise record not found',
          ),
        );
      }

      _logger.info('Got latest exercise record');
      return ok(ExerciseRecordDto.fromModel(records.first));
    } catch (e) {
      _logger.severe('Failed to get latest exercise record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get latest exercise record',
        ),
      );
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
  updateExerciseRecord(int id, ExerciseRecordInput input) async {
    _logger.info('Updating exercise record with id $id');
    try {
      final ExerciseRecord? exerciseRecord = await _repository.selectOne(id);

      if (exerciseRecord == null) {
        _logger.info('Exercise record with id $id not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise record with id $id not found',
          ),
        );
      }

      final Exercise? exercise = await _exerciseRepository.selectOne(
        input.exerciseId,
      );
      if (exercise == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise with id ${input.exerciseId} not found',
          ),
        );
      }

      final ExerciseRecord updatedExerciseRecord = exerciseRecord.copyWith(
        exerciseId: input.exerciseId,
        weight: input.weight,
        reps: input.reps,
        picture: input.picture,
        video: input.video,
        recordDate: DateUtilities.getDateUnix(input.recordDate),
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedExerciseRecord);
      _logger.info('Updated exercise record with id $id');
      return ok(
        ExerciseRecordDto.fromModel(
          updatedExerciseRecord,
          exercise: ExerciseDto.fromModel(exercise),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to update exercise record with id $id', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Failed to update exercise record with error ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteExerciseRecord(
    int id,
  ) async {
    _logger.info('Deleting exercise record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise record not found',
          ),
        );
      }
      _logger.info('Deleted exercise record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete exercise record with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete exercise record',
        ),
      );
    }
  }

  Future<Result<StrengthGoalDto, ServiceError<SingleErrorTypes>>>
  createStrengthGoal(StrengthGoalInput input) async {
    _logger.info('Creating strength goal for exercise ${input.exerciseId}');
    try {
      final Exercise? exercise = await _exerciseRepository.selectOne(
        input.exerciseId,
      );
      if (exercise == null) {
        _logger.warning('Exercise with id ${input.exerciseId} not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise with id ${input.exerciseId} not found',
          ),
        );
      }

      final StrengthGoal goal = StrengthGoal.create(
        exerciseId: input.exerciseId,
        name: input.name,
        targetReps: input.targetReps,
        targetWeight: input.targetWeight,
        targetMaxStrength: input.targetMaxStrength,
        startDate: DateUtilities.getDateUnix(input.startDate),
        status: input.status,
        completedAt: input.completedAt.value != null
            ? DateUtilities.getDateUnix(input.completedAt.value!)
            : null,
      );

      if (input.status != ProgressStatus.inProgress) {
        final int id = await _strengthGoalRepository.insert(goal);
        _logger.info('Created strength goal with id $id');
        return ok(StrengthGoalDto.fromModel(goal.copyWith(id: Nullable(id))));
      }

      final int id = await _strengthGoalRepository.startTransaction((
        txn,
      ) async {
        final activeGoals = await _strengthGoalRepository.selectMany(
          where:
              '${StrengthGoalColumns.exerciseId.equal} AND ${StrengthGoalColumns.status.equal}',
          whereArgs: [input.exerciseId, ProgressStatus.inProgress.value],
          trx: txn,
        );
        final now = DateUtilities.getNowUtcUnix();
        for (final activeGoal in activeGoals) {
          await _strengthGoalRepository.update(
            activeGoal.copyWith(
              status: ProgressStatus.abandoned,
              completedAt: Nullable(now),
              updatedAt: now,
            ),
            txn,
          );
        }
        return await _strengthGoalRepository.insert(goal, txn);
      });
      _logger.info('Created strength goal with id $id');
      return ok(StrengthGoalDto.fromModel(goal.copyWith(id: Nullable(id))));
    } catch (e) {
      _logger.severe('Failed to create strength goal', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create strength goal',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<StrengthGoalDto, StrengthGoal>,
      ServiceError<OperationErrorTypes>
    >
  >
  getStrengthGoals({
    int? exerciseId,
    bool skipInProgress = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting strength goals');
    try {
      final where = WhereBuilder();
      if (exerciseId != null) {
        where.and(StrengthGoalColumns.exerciseId.equal, exerciseId);
      }
      if (skipInProgress) {
        where.and(
          StrengthGoalColumns.status.notEqual,
          ProgressStatus.inProgress.value,
        );
      }

      final List<StrengthGoal> goals = await _strengthGoalRepository
          .selectPaginated(
            where: where.where,
            whereArgs: where.args,
            limit: limit,
            offset: offset,
            orderBy: [
              StrengthGoalColumns.startDate.orderDesc,
              StrengthGoalColumns.createdAt.orderDesc,
            ],
          );
      final int total = await _strengthGoalRepository.count(
        where: where.where,
        whereArgs: where.args,
      );
      _logger.info('Got ${goals.length} strength goals');
      return ok(
        PaginatedDto<StrengthGoalDto, StrengthGoal>.mapData(
          data: goals,
          mapper: (goal) => StrengthGoalDto.fromModel(goal),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get strength goals', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get strength goals',
        ),
      );
    }
  }

  Future<Result<StrengthGoalDto, ServiceError<SingleErrorTypes>>>
  getActiveStrengthGoal({int? exerciseId}) async {
    _logger.info('Getting active strength goal');
    try {
      final where = WhereBuilder();
      where.and(
        StrengthGoalColumns.status.equal,
        ProgressStatus.inProgress.value,
      );
      if (exerciseId != null) {
        where.and(StrengthGoalColumns.exerciseId.equal, exerciseId);
      }

      final List<StrengthGoal> goals = await _strengthGoalRepository.selectMany(
        where: where.where,
        whereArgs: where.args,
        orderBy: [
          StrengthGoalColumns.startDate.orderDesc,
          StrengthGoalColumns.createdAt.orderDesc,
        ],
        limit: 1,
      );
      if (goals.isEmpty) {
        _logger.info('No active strength goal found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No active strength goal found',
          ),
        );
      }
      return ok(StrengthGoalDto.fromModel(goals.first));
    } catch (e) {
      _logger.severe('Failed to get active strength goal', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get active strength goal',
        ),
      );
    }
  }

  Future<Result<StrengthGoalDto, ServiceError<SingleErrorTypes>>>
  getStrengthGoal(int id) async {
    _logger.info('Getting strength goal with id $id');
    try {
      final StrengthGoal? goal = await _strengthGoalRepository.selectOne(id);
      if (goal == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Strength goal not found',
          ),
        );
      }
      return ok(StrengthGoalDto.fromModel(goal));
    } catch (e) {
      _logger.severe('Failed to get strength goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get strength goal',
        ),
      );
    }
  }

  Future<Result<StrengthGoalDto, ServiceError<SingleErrorTypes>>>
  updateStrengthGoal(int id, StrengthGoalInput input) async {
    _logger.info('Updating strength goal with id $id');
    try {
      final StrengthGoal? goal = await _strengthGoalRepository.selectOne(id);
      if (goal == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Strength goal not found',
          ),
        );
      }

      final exercise = await _exerciseRepository.selectOne(input.exerciseId);
      if (exercise == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise not found',
          ),
        );
      }
      final StrengthGoal updated = goal.copyWith(
        exerciseId: input.exerciseId,
        name: input.name,
        targetReps: input.targetReps,
        targetWeight: input.targetWeight,
        targetMaxStrength: input.targetMaxStrength,
        startDate: DateUtilities.getDateUnix(input.startDate),
        status: input.status,
        completedAt: Nullable(
          input.completedAt.value != null
              ? DateUtilities.getDateUnix(input.completedAt.value!)
              : null,
        ),
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _strengthGoalRepository.startTransaction((txn) async {
        if (input.status == ProgressStatus.inProgress) {
          final activeGoals = await _strengthGoalRepository.selectMany(
            where:
                '${StrengthGoalColumns.exerciseId.equal} AND ${StrengthGoalColumns.status.equal} AND ${StrengthGoalColumns.id.value} != ?',
            whereArgs: [input.exerciseId, ProgressStatus.inProgress.value, id],
            trx: txn,
          );
          final now = DateUtilities.getNowUtcUnix();
          for (final activeGoal in activeGoals) {
            await _strengthGoalRepository.update(
              activeGoal.copyWith(
                status: ProgressStatus.abandoned,
                completedAt: Nullable(now),
                updatedAt: now,
              ),
              txn,
            );
          }
        }
        await _strengthGoalRepository.update(updated, txn);
      });
      _logger.info('Updated strength goal with id $id');
      return ok(StrengthGoalDto.fromModel(updated));
    } catch (e) {
      _logger.severe('Failed to update strength goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update strength goal',
        ),
      );
    }
  }

  Future<Result<StrengthGoalDto, ServiceError<SingleErrorTypes>>>
  completeStrengthGoal(int id) async {
    _logger.info('Completing strength goal with id $id');
    try {
      final StrengthGoal? goal = await _strengthGoalRepository.selectOne(id);
      if (goal == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Strength goal not found',
          ),
        );
      }

      final StrengthGoal updated = goal.copyWith(
        status: ProgressStatus.completed,
        completedAt: Nullable(DateUtilities.getNowUtcUnix()),
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _strengthGoalRepository.update(updated);
      _logger.info('Completed strength goal with id $id');
      return ok(StrengthGoalDto.fromModel(updated));
    } catch (e) {
      _logger.severe('Failed to complete strength goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to complete strength goal',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteStrengthGoal(
    int id,
  ) async {
    _logger.info('Deleting strength goal with id $id');
    try {
      final bool deleted = await _strengthGoalRepository.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Strength goal not found',
          ),
        );
      }
      _logger.info('Deleted strength goal with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete strength goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete strength goal',
        ),
      );
    }
  }
}
