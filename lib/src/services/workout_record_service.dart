import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/common.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/repository.dart'
    show Repository, kDefaultLimit, kDefaultOffset;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_model.dart';
import '../models/workout_record_model.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../models/workout_set_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/exercise_dto.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_record_dto.dart';
import 'dtos/workout_set_exercise_record_dto.dart';
import 'dtos/workout_set_record_dto.dart';
import 'inputs/workout_record_input.dart';

export 'inputs/workout_record_input.dart';

class WorkoutRecordService {
  WorkoutRecordService._();

  static final WorkoutRecordService instance = WorkoutRecordService._();

  factory WorkoutRecordService() => instance;

  final Logger _logger = Logger('Workout Record Service');

  final _repository = Repository<WorkoutRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutRecord.table,
    fromMap: WorkoutRecord.fromMap,
  );

  final _setRecordRepository = Repository<WorkoutSetRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetRecord.table,
    fromMap: WorkoutSetRecord.fromMap,
  );

  final _setExerciseRecordRepository = Repository<WorkoutSetExerciseRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExerciseRecord.table,
    fromMap: WorkoutSetExerciseRecord.fromMap,
  );

  final _workoutRepository = Repository<Workout>(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: Workout.fromMap,
  );

  final _exerciseRepository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: Exercise.fromMap,
  );

  Future<
    Result<
      PaginatedDto<WorkoutRecordDto, WorkoutRecord>,
      ServiceError<SingleErrorTypes>
    >
  >
  getWorkoutRecords({
    int? workoutId,
    (DateTime start, DateTime end)? dateRange,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout records');
    final WhereBuilder query = WhereBuilder();

    if (workoutId != null) {
      final Workout? workout = await _workoutRepository.selectOne(workoutId);
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
      final List<WorkoutRecord> records = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutRecordColumns.startedAt.orderDesc],
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${records.length} workout records');
      return ok(
        PaginatedDto<WorkoutRecordDto, WorkoutRecord>.mapData(
          data: records,
          mapper: WorkoutRecordDto.fromModel,
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
      final WorkoutRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout record not found',
          ),
        );
      }

      final List<WorkoutSetRecord> setRecords = await _setRecordRepository
          .selectMany(
            where: WorkoutSetRecordColumns.workoutRecordId.equal,
            whereArgs: [id],
            orderBy: [
              WorkoutSetRecordColumns.workoutRecordId.orderAsc,
              WorkoutSetRecordColumns.setNumber.orderAsc,
            ],
          );
      if (setRecords.isEmpty) {
        _logger.info('Got workout record with id $id');
        return ok(WorkoutRecordDto.fromModel(record));
      }

      final List<WorkoutSetExerciseRecord> setExerciseRecords =
          await _setExerciseRecordRepository.selectMany(
            where: WorkoutSetExerciseRecordColumns.workoutRecordId.equal,
            whereArgs: [id],
            orderBy: [
              WorkoutSetExerciseRecordColumns.workoutSetRecordId.orderAsc,
              WorkoutSetExerciseRecordColumns.position.orderAsc,
            ],
          );
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

      final exercisesIds = setExerciseRecords.map((s) => s.exerciseId).toSet();
      final exercises = await _exerciseRepository.selectMany(
        where: ExerciseColumns.id.inList(exercisesIds.length),
        whereArgs: exercisesIds.toList(),
      );

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
  getLatestWorkoutRecord(int workoutId) async {
    _logger.info('Getting latest workout record for workout $workoutId');
    try {
      final List<WorkoutRecord> records = await _repository.selectMany(
        where: WorkoutRecordColumns.workoutId.equal,
        whereArgs: [workoutId],
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

      _logger.info('Got latest workout record for workout $workoutId');
      return ok(WorkoutRecordDto.fromModel(records.first));
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
      final Workout? workout = await _workoutRepository.selectOne(
        input.workoutId,
      );
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
      final List<WorkoutRecord> records = await _repository.selectMany(
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
      final int id = await _repository.insert(record);
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

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
  updateWorkoutRecord(int id, WorkoutRecordInput input) async {
    _logger.info('Updating workout record with id $id');
    try {
      final WorkoutRecord? record = await _repository.selectOne(id);
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
      await _repository.update(updatedRecord);
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
      final bool deleted = await _repository.deleteOne(id);
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
      final WorkoutRecord? workoutRecord = await _repository.selectOne(
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

      final List<WorkoutSetRecord> records = await _setRecordRepository
          .selectMany(
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
        await _repository.startTransaction((trx) async {
          await _setRecordRepository.update(updatedRecord, trx);
          final updatedWorkoutRecord = workoutRecord.copyWith(
            totalRestSecs:
                workoutRecord.totalRestSecs +
                (updatedRecord.totalRestSecs ?? 0) -
                (oldRest ?? 0),
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _repository.update(updatedWorkoutRecord, trx);
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
      final int id = await _repository.startTransaction((trx) async {
        final int id = await _setRecordRepository.insert(record, trx);

        final updatedWorkoutRecord = workoutRecord.copyWith(
          totalSets: workoutRecord.totalSets + 1,
          totalRestSecs:
              workoutRecord.totalRestSecs + (record.totalRestSecs ?? 0),
          currentSetPosition: workoutRecord.currentSetPosition + 1,
          currentSetNumber: workoutRecord.currentSetNumber + 1,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedWorkoutRecord, trx);

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
      final WorkoutRecord? workoutRecord = await _repository.selectOne(
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

      final WorkoutSetRecord? workoutSetRecord = await _setRecordRepository
          .selectOne(input.workoutSetRecordId);
      if (workoutSetRecord == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description:
                'Workout set record with id: ${input.workoutSetRecordId} not found',
          ),
        );
      }

      final Exercise? exercise = await _exerciseRepository.selectOne(
        input.exerciseId,
      );
      if (exercise == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Exercise with id: ${input.exerciseId} not found',
          ),
        );
      }

      final whereBuild = WhereBuilder();
      whereBuild.and(
        WorkoutSetExerciseRecordColumns.workoutSetExerciseId.equal,
        input.workoutSetExerciseId,
      );
      whereBuild.and(
        WorkoutSetExerciseRecordColumns.workoutRecordId.equal,
        input.workoutRecordId,
      );
      whereBuild.and(
        WorkoutSetExerciseRecordColumns.workoutSetRecordId.equal,
        input.workoutSetRecordId,
      );
      whereBuild.and(
        WorkoutSetExerciseRecordColumns.position.equal,
        input.position,
      );
      final List<WorkoutSetExerciseRecord> records =
          await _setExerciseRecordRepository.selectMany(
            where: whereBuild.where,
            whereArgs: whereBuild.args,
            limit: 1,
          );
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
        await _repository.startTransaction((trx) async {
          await _setExerciseRecordRepository.update(updatedRecord, trx);
          final updatedWorkoutRecord = workoutRecord.copyWith(
            totalReps: workoutRecord.totalReps + (input.reps - previousReps),
            totalVolume:
                workoutRecord.totalVolume +
                (input.reps * input.weight - previousVolume),
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _repository.update(updatedWorkoutRecord, trx);
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
      final int id = await _repository.startTransaction((trx) async {
        final int id = await _setExerciseRecordRepository.insert(record, trx);
        final updatedWorkoutRecord = workoutRecord.copyWith(
          totalReps: workoutRecord.totalReps + input.reps,
          totalVolume: workoutRecord.totalVolume + (input.reps * input.weight),
          muscleGroups: workoutRecord.muscleGroups..add(exercise.muscleGroup),
          muscles: workoutRecord.muscles.addOther(exercise.muscles),
          currentExercisePosition: workoutRecord.currentExercisePosition + 1,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedWorkoutRecord, trx);
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

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
  batchCreateWorkoutRecord(WorkoutRecordBatchInput input) async {
    _logger.info('Batch creating workout record');
    try {
      final Workout? workout = await _workoutRepository.selectOne(
        input.workoutId,
      );
      if (workout == null) {
        return err(
          ServiceError(
            type: OperationErrorTypes.invalidInput,
            description: 'Workout with id: ${input.workoutId} not found',
          ),
        );
      }

      final int batchTotalRestSecs = input.sets.fold<int>(
        0,
        (int sum, WorkoutSetRecordBatchInput s) => sum + s.totalRestSecs,
      );

      final result = await _repository.startTransaction((trx) async {
        // 1. Create WorkoutRecord
        final WorkoutRecord record = WorkoutRecord.create(
          version: workout.version,
          workoutId: input.workoutId,
          startedAt: DateUtilities.getDateUnix(input.startedAt),
        );
        final int recordId = await _repository.insert(
          record.copyWith(
            completedAt: Nullable(DateUtilities.getDateUnix(input.completedAt)),
            status: ProgressStatus.completed,
            totalSets: input.sets.length,
            totalRestSecs: batchTotalRestSecs,
            // Calculate total reps and volume
            totalReps: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(0, (int sum, ex) => sum + ex.reps),
            ),
            totalVolume: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(
                    0,
                    (int sum, ex) => sum + (ex.reps * ex.weight),
                  ),
            ),
          ),
          trx,
        );

        // Fetch all exercises to update muscles mapping
        final Set<int> allExerciseIds = input.sets
            .expand((s) => s.exercises)
            .map((e) => e.exerciseId)
            .toSet();
        final List<Exercise> fetchedExercises = allExerciseIds.isNotEmpty
            ? await _exerciseRepository.selectMany(
                where: ExerciseColumns.id.inList(allExerciseIds.length),
                whereArgs: allExerciseIds.toList(),
                trx: trx,
              )
            : [];
        final Set<MuscleGroup> muscleGroups = {};
        TargetMuscles muscles = const TargetMuscles(
          primary: <Muscle>{},
          secondary: <Muscle>{},
        );
        for (var e in fetchedExercises) {
          muscleGroups.add(e.muscleGroup);
          muscles = muscles.addOther(e.muscles);
        }

        // Update record with gathered muscles
        await _repository.update(
          record.copyWith(
            id: Nullable(recordId),
            completedAt: Nullable(DateUtilities.getDateUnix(input.completedAt)),
            status: ProgressStatus.completed,
            totalSets: input.sets.length,
            totalRestSecs: batchTotalRestSecs,
            totalReps: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(0, (int sum, ex) => sum + ex.reps),
            ),
            totalVolume: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(
                    0,
                    (int sum, ex) => sum + (ex.reps * ex.weight),
                  ),
            ),
            muscleGroups: muscleGroups,
            muscles: muscles,
          ),
          trx,
        );

        // 2. Insert Sets & Exercises
        for (final setDto in input.sets) {
          final WorkoutSetRecord setRecord = WorkoutSetRecord.create(
            workoutSetId: setDto.workoutSetId,
            workoutRecordId: recordId,
            setNumber: setDto.setNumber,
            startedAt: DateUtilities.getDateUnix(setDto.startedAt),
            completedAt: setDto.completedAt != null
                ? DateUtilities.getDateUnix(setDto.completedAt!)
                : null,
            totalRestSecs: setDto.totalRestSecs,
          );
          final int setRecordId = await _setRecordRepository.insert(
            setRecord,
            trx,
          );

          for (final exDto in setDto.exercises) {
            final WorkoutSetExerciseRecord exRecord =
                WorkoutSetExerciseRecord.create(
                  workoutSetExerciseId: exDto.workoutSetExerciseId,
                  workoutRecordId: recordId,
                  workoutSetRecordId: setRecordId,
                  exerciseId: exDto.exerciseId,
                  position: exDto.position,
                  reps: exDto.reps,
                  weightGrams: exDto.weight,
                  difficulty: exDto.difficulty,
                );
            await _setExerciseRecordRepository.insert(exRecord, trx);
          }
        }
        return recordId;
      });
      _logger.info('Batch created workout record with id $result');

      final newRecordRes = await getWorkoutRecord(result);
      if (newRecordRes.isErr()) {
        return err(
          const ServiceError(
            type: OperationErrorTypes.operationFailure,
            description: 'Failed to retrieve batch created workout record',
          ),
        );
      }
      return ok(newRecordRes.value);
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
      final WorkoutRecord? record = await _repository.selectOne(
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

      final int batchTotalRestSecs = input.sets.fold<int>(
        0,
        (int sum, WorkoutSetRecordBatchInput s) => sum + s.totalRestSecs,
      );

      await _repository.startTransaction((trx) async {
        // Delete existing sets and exercises
        await _setExerciseRecordRepository.deleteMany(
          where: '${WorkoutSetExerciseRecordColumns.workoutRecordId.value} = ?',
          whereArgs: [workoutRecordId],
          trx: trx,
        );
        await _setRecordRepository.deleteMany(
          where: '${WorkoutSetRecordColumns.workoutRecordId.value} = ?',
          whereArgs: [workoutRecordId],
          trx: trx,
        );

        // Fetch all exercises to update muscles mapping
        final Set<int> allExerciseIds = input.sets
            .expand((s) => s.exercises)
            .map((e) => e.exerciseId)
            .toSet();
        final List<Exercise> fetchedExercises = allExerciseIds.isNotEmpty
            ? await _exerciseRepository.selectMany(
                where: ExerciseColumns.id.inList(allExerciseIds.length),
                whereArgs: allExerciseIds.toList(),
                trx: trx,
              )
            : [];
        final Set<MuscleGroup> muscleGroups = {};
        TargetMuscles muscles = const TargetMuscles(
          primary: <Muscle>{},
          secondary: <Muscle>{},
        );
        for (var e in fetchedExercises) {
          muscleGroups.add(e.muscleGroup);
          muscles = muscles.addOther(e.muscles);
        }

        // Update record
        await _repository.update(
          record.copyWith(
            workoutId: input.workoutId,
            version: input.version,
            startedAt: DateUtilities.getDateUnix(input.startedAt),
            completedAt: Nullable(DateUtilities.getDateUnix(input.completedAt)),
            droppedAt: const Nullable(null),
            status: ProgressStatus.completed,
            totalSets: input.sets.length,
            totalRestSecs: batchTotalRestSecs,
            totalReps: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(0, (int sum, ex) => sum + ex.reps),
            ),
            totalVolume: input.sets.fold<int>(
              0,
              (int sum, set) =>
                  sum +
                  set.exercises.fold<int>(
                    0,
                    (int sum, ex) => sum + (ex.reps * ex.weight),
                  ),
            ),
            muscleGroups: muscleGroups,
            muscles: muscles,
            updatedAt: DateUtilities.getNowUtcUnix(),
          ),
          trx,
        );

        // Insert Sets & Exercises
        for (final setDto in input.sets) {
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
          final int setRecordId = await _setRecordRepository.insert(
            setRecord,
            trx,
          );

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
            await _setExerciseRecordRepository.insert(exRecord, trx);
          }
        }
      });
      _logger.info('Batch updated workout record with id $workoutRecordId');

      final newRecordRes = await getWorkoutRecord(workoutRecordId);
      if (newRecordRes.isErr()) {
        return err(
          const ServiceError(
            type: OperationErrorTypes.operationFailure,
            description: 'Failed to retrieve batch updated workout record',
          ),
        );
      }
      return ok(newRecordRes.value);
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
