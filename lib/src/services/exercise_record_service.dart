import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/db.dart';
import '../models/exercise_model.dart';
import '../models/exercise_record_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/exercise_dto.dart';
import 'dtos/exercise_record_dto.dart';
import 'dtos/paginated_dto.dart';

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

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
      createExerciseRecord({
    required int exerciseId,
    required int weight,
    required int reps,
    required DateTime date,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating exercise record for exercise $exerciseId');
    try {
      final Exercise? exercise = await _exerciseRepository.selectOne(
        exerciseId,
      );
      if (exercise == null) {
        _logger.warning("Exercise with id: $exerciseId not found");
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: "Exercise with id $exerciseId not found",
        ));
      }

      final ExerciseRecord exerciseRecord = ExerciseRecord.create(
        exerciseId: exerciseId,
        weight: weight,
        reps: reps,
        picture: picture,
        video: video,
        recordDate: DateUtilities.getDateUnix(date),
      );
      final int id = await _repository.insert(exerciseRecord);
      _logger.info('Created exercise record with id $id');
      return ok(ExerciseRecordDto.fromModel(
        exerciseRecord.copyWith(id: id),
        exercise: ExerciseDto.fromModel(exercise),
      ));
    } catch (e) {
      _logger.severe('Failed to create exercise record', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to create exercise record with error ${e.toString()}',
      ));
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
      getExerciseRecord(int id) async {
    _logger.info('Getting exercise record with id $id');
    try {
      final ExerciseRecord? exerciseRecord = await _repository.selectOne(id);
      if (exerciseRecord == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Exercise record with id $id not found',
        ));
      }

      final Exercise? exercise = await _exerciseRepository.selectOne(
        exerciseRecord.exerciseId,
      );
      if (exercise == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Exercise with id ${exerciseRecord.exerciseId} not found',
        ));
      }

      _logger.info('Got exercise record with id $id');
      return ok(ExerciseRecordDto.fromModel(
        exerciseRecord,
        exercise: ExerciseDto.fromModel(exercise),
      ));
    } catch (e) {
      _logger.severe('Failed to get exercise record with id $id', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get exercise record with error ${e.toString()}',
      ));
    }
  }

  Future<
      Result<PaginatedDto<ExerciseRecordDto, ExerciseRecord>,
          ServiceError<SingleErrorTypes>>> getExerciseRecords({
    int? exerciseId,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting exercise records');
    final WhereBuilder query = WhereBuilder();

    try {
      if (exerciseId != null) {
        final Exercise? exercise = await _exerciseRepository.selectOne(
          exerciseId,
        );
        if (exercise == null) {
          return err(ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise with id $exerciseId not found',
          ));
        }

        query.and(
          '${ExerciseRecordColumns.exerciseId.value} = ?',
          [exerciseId],
        );
      }

      final List<ExerciseRecord> records = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy:
            '${ExerciseRecordColumns.recordDate.value} DESC, ${ExerciseRecordColumns.id.value} DESC',
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${records.length} exercise records');

      if (exerciseId != null) {
        return ok(PaginatedDto<ExerciseRecordDto, ExerciseRecord>.mapData(
          data: records,
          mapper: ExerciseRecordDto.fromModel,
          total: total,
          limit: limit,
          offset: offset,
        ));
      }

      final Set<int> exerciseIds = records
          .map(
            (record) => record.exerciseId,
          )
          .toSet();
      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where:
            '${ExerciseColumns.id.value} IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exerciseIds.length != exercises.length) {
        _logger.warning("Not all exercises were found");
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises were not found',
        ));
      }

      final Map<int, ExerciseDto> exerciseMap = exercises.fold({}, (map, e) {
        map[e.id!] = ExerciseDto.fromModel(e);
        return map;
      });
      return ok(PaginatedDto<ExerciseRecordDto, ExerciseRecord>.mapData(
        data: records,
        mapper: (record) => ExerciseRecordDto.fromModel(
          record,
          exercise: exerciseMap[record.exerciseId],
        ),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get exercise records', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to get exercise records with error ${e.toString()}',
      ));
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
      getLatestRecord(int exerciseId) async {
    _logger.info('Getting latest record for exercise $exerciseId');
    try {
      final List<ExerciseRecord> records = await _repository.selectMany(
        where: '${ExerciseRecordColumns.exerciseId.value} = ?',
        whereArgs: [exerciseId],
        orderBy: '${ExerciseRecordColumns.id.value} DESC',
        limit: 1,
      );
      if (records.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Latest exercise record not found',
        ));
      }

      _logger.info('Got latest exercise record');
      return ok(ExerciseRecordDto.fromModel(records.first));
    } catch (e) {
      _logger.severe('Failed to get latest exercise record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get latest exercise record',
      ));
    }
  }

  Future<Result<ExerciseRecordDto, ServiceError<SingleErrorTypes>>>
      updateExerciseRecord({
    required int id,
    int? weight,
    int? reps,
    int? maxStrength,
    PictureData? picture,
    VideoData? video,
    DateTime? date,
  }) async {
    _logger.info('Updating exercise record with id $id');
    try {
      final ExerciseRecord? exerciseRecord = await _repository.selectOne(id);

      if (exerciseRecord == null) {
        _logger.info('Exercise record with id $id not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Exercise record with id $id not found',
        ));
      }

      final int newWeight = weight ?? exerciseRecord.weight;
      final int newReps = reps ?? exerciseRecord.reps;
      final int newMaxStrength = maxStrength ??
          MaxStrengthCalculator.calculateMaxStrength(newReps, newWeight);

      final ExerciseRecord updatedExerciseRecord = exerciseRecord.copyWith(
        weight: newWeight,
        reps: newReps,
        maxStrength: newMaxStrength,
        picture: picture,
        video: video,
        recordDate: date != null
            ? DateUtilities.getDateUnix(date)
            : exerciseRecord.recordDate,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedExerciseRecord);
      _logger.info('Updated exercise record with id $id');
      return ok(ExerciseRecordDto.fromModel(updatedExerciseRecord));
    } catch (e) {
      _logger.severe('Failed to update exercise record with id $id', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to update exercise record with error ${e.toString()}',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteExerciseRecord(
    int id,
  ) async {
    _logger.info('Deleting exercise record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Exercise record not found',
        ));
      }
      _logger.info('Deleted exercise record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete exercise record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete exercise record',
      ));
    }
  }
}
