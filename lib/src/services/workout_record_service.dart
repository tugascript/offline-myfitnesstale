import 'package:logging/logging.dart';

import '../models/db.dart';
import '../models/repository.dart'
    show Repository, kDefaultLimit, kDefaultOffset;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_model.dart';
import '../models/workout_record_model.dart';
import '../models/workout_set_exercise_record_model.dart';
import '../models/workout_set_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_record_dto.dart';
import 'dtos/workout_set_exercise_record_dto.dart';
import 'dtos/workout_set_record_dto.dart';

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

  Future<
      Result<PaginatedDto<WorkoutRecordDto, WorkoutRecord>,
          ServiceError<SingleErrorTypes>>> getWorkoutRecords({
    int? workoutId,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout records');
    final WhereBuilder query = WhereBuilder();

    if (workoutId != null) {
      final Workout? workout = await _workoutRepository.selectOne(workoutId);
      if (workout == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id: $workoutId not found',
        ));
      }

      query.and('${WorkoutRecordColumns.workoutId.value} = ?', workoutId);
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
      return ok(PaginatedDto<WorkoutRecordDto, WorkoutRecord>.mapData(
        data: records,
        mapper: WorkoutRecordDto.fromModel,
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get workout records', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout records error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
      getWorkoutRecord(
    int id,
  ) async {
    _logger.info('Getting workout record with id $id');
    try {
      final WorkoutRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout record not found',
        ));
      }

      final List<WorkoutSetRecord> setRecords =
          await _setRecordRepository.selectMany(
        where: '${WorkoutSetRecordColumns.workoutRecordId.value} = ?',
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
        where: '${WorkoutSetExerciseRecordColumns.workoutRecordId.value} = ?',
        whereArgs: setRecords.map((sr) => sr.id).toList(),
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
                .map(
                  (sr) => WorkoutSetRecordDto.fromModel(sr),
                )
                .toList(),
          ),
        );
      }

      final setExerciseRecordsMap =
          setExerciseRecords.fold<Map<int, List<WorkoutSetExerciseRecordDto>>>(
        {},
        (map, setExerciseRecord) {
          map.update(
            setExerciseRecord.workoutSetRecordId,
            (list) => list
              ..add(
                WorkoutSetExerciseRecordDto.fromModel(setExerciseRecord),
              ),
            ifAbsent: () => [
              WorkoutSetExerciseRecordDto.fromModel(setExerciseRecord),
            ],
          );
          return map;
        },
      );

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
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout record error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<OperationErrorTypes>>>
      createWorkoutRecord({
    required int workoutId,
    required DateTime startedAt,
  }) async {
    _logger.info('Creating workout record');
    try {
      final Workout? workout = await _workoutRepository.selectOne(workoutId);
      if (workout == null) {
        return err(ServiceError(
          type: OperationErrorTypes.invalidInput,
          description: 'Workout with id: $workoutId not found',
        ));
      }

      final WorkoutRecord record = WorkoutRecord.create(
        workoutId: workoutId,
        startedAt: DateUtilities.getDateUnix(startedAt),
      );
      final int id = await _repository.insert(record);
      _logger.info('Created workout record with id $id');
      return ok(WorkoutRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout record',
      ));
    }
  }

  Future<Result<WorkoutRecordDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutRecord({
    required int id,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? droppedAt,
  }) async {
    _logger.info('Updating workout record with id $id');
    try {
      final WorkoutRecord? record = await _repository.selectOne(id);
      if (record == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout record with id: $id not found',
        ));
      }

      final WorkoutRecord updatedRecord = record.copyWith(
        startedAt: startedAt != null
            ? DateUtilities.getDateUnix(startedAt)
            : record.startedAt,
        completedAt: completedAt != null
            ? DateUtilities.getDateUnix(completedAt)
            : record.completedAt,
        droppedAt: droppedAt != null
            ? DateUtilities.getDateUnix(droppedAt)
            : record.droppedAt,
      );
      await _repository.update(updatedRecord);
      _logger.info('Updated workout record with id $id');
      return ok(WorkoutRecordDto.fromModel(updatedRecord));
    } catch (e) {
      _logger.severe('Failed to update workout record with id $id', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout record error: ${e.toString()}',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutRecord(
    int id,
  ) async {
    _logger.info('Deleting workout record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout record with id: $id not found',
        ));
      }
      _logger.info('Deleted workout record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout record with id $id', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout record error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutSetRecordDto, ServiceError<OperationErrorTypes>>>
      upsertWorkoutSetRecord({
    required int workoutSetId,
    required int workoutRecordId,
    required int setNumber,
    int? totalRestSecs,
    DateTime? completedAt,
  }) async {
    _logger.info('Creating workout set record');
    final whereBuild = WhereBuilder();
    whereBuild.and(WorkoutSetRecordColumns.workoutSetId.equal, workoutSetId);
    whereBuild.and(
        WorkoutSetRecordColumns.workoutRecordId.equal, workoutRecordId);
    whereBuild.and(WorkoutSetRecordColumns.setNumber.equal, setNumber);

    try {
      final List<WorkoutSetRecord> records =
          await _setRecordRepository.selectMany(
        where: whereBuild.where,
        whereArgs: whereBuild.args,
        limit: 1,
      );

      if (records.isNotEmpty) {
        final WorkoutSetRecord record = records.first;
        final WorkoutSetRecord updatedRecord = record.copyWith(
          totalRestSecs: totalRestSecs,
          completedAt: completedAt != null
              ? DateUtilities.getDateUnix(completedAt)
              : null,
        );
        await _setRecordRepository.update(updatedRecord);
        _logger.info('Updated workout set record with id ${record.id}');
        return ok(WorkoutSetRecordDto.fromModel(updatedRecord));
      }

      final WorkoutSetRecord record = WorkoutSetRecord.create(
        workoutSetId: workoutSetId,
        workoutRecordId: workoutRecordId,
        setNumber: setNumber,
        startedAt: DateUtilities.getNowUtcUnix(),
        totalRestSecs: totalRestSecs,
        completedAt:
            completedAt != null ? DateUtilities.getDateUnix(completedAt) : null,
      );
      final int id = await _setRecordRepository.insert(record);
      _logger.info('Created workout set record with id $id');
      return ok(WorkoutSetRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout set record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout set record',
      ));
    }
  }

  Future<Result<WorkoutSetExerciseRecordDto, ServiceError<OperationErrorTypes>>>
      upsertWorkoutSetExerciseRecord({
    required int workoutSetExerciseId,
    required int workoutRecordId,
    required int workoutSetRecordId,
    required int exerciseId,
    required int position,
    required int reps,
    required int weight,
    int? difficulty,
    String? difficultyType,
  }) async {
    _logger.info('Creating workout set exercise record');
    final whereBuild = WhereBuilder();
    whereBuild.and(
      WorkoutSetExerciseRecordColumns.workoutSetExerciseId.equal,
      workoutSetExerciseId,
    );
    whereBuild.and(
      WorkoutSetExerciseRecordColumns.workoutSetRecordId.equal,
      workoutSetRecordId,
    );
    whereBuild.and(
      WorkoutSetExerciseRecordColumns.position.equal,
      position,
    );

    try {
      final List<WorkoutSetExerciseRecord> records =
          await _setExerciseRecordRepository.selectMany(
        where: whereBuild.where,
        whereArgs: whereBuild.args,
        limit: 1,
      );

      if (records.isNotEmpty) {
        final WorkoutSetExerciseRecord record = records.first;
        final WorkoutSetExerciseRecord updatedRecord = record.copyWith(
          workoutSetRecordId: workoutSetRecordId,
          exerciseId: exerciseId,
          reps: reps,
          weightGrams: weight,
          difficulty: difficulty,
          difficultyType: difficultyType,
        );
        await _setExerciseRecordRepository.update(updatedRecord);
        _logger.info(
          'Updated workout set exercise record with id ${record.id}',
        );
        return ok(WorkoutSetExerciseRecordDto.fromModel(updatedRecord));
      }

      final WorkoutSetExerciseRecord record = WorkoutSetExerciseRecord.create(
        workoutSetExerciseId: workoutSetExerciseId,
        workoutRecordId: workoutRecordId,
        workoutSetRecordId: workoutSetRecordId,
        exerciseId: exerciseId,
        position: position,
        reps: reps,
        weightGrams: weight,
        difficulty: difficulty,
        difficultyType: difficultyType,
      );
      final int id = await _setExerciseRecordRepository.insert(record);
      _logger.info('Created workout set exercise record with id $id');
      return ok(WorkoutSetExerciseRecordDto.fromModel(record.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout set exercise record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout set exercise record',
      ));
    }
  }
}
