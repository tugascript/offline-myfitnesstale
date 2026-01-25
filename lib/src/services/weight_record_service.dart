import 'package:logging/logging.dart';
import 'package:myfitnesstale/src/models/enums.dart';

import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/weight_goal_model.dart';
import '../models/weight_record_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/weight_goal_dto.dart';
import 'dtos/weight_record_dto.dart';

class WeightRecordService {
  WeightRecordService._();

  static final WeightRecordService _instance = WeightRecordService._();

  factory WeightRecordService() => _instance;

  final Logger _logger = Logger('Weight Record Service');

  final Repository<WeightRecord> _repository = Repository<WeightRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WeightRecord.table,
    fromMap: (map) => WeightRecord.fromMap(map),
  );

  final Repository<WeightGoal> _weightGoalRepository = Repository<WeightGoal>(
    databaseHelper: DatabaseHelper(),
    tableName: WeightGoal.table,
    fromMap: (map) => WeightGoal.fromMap(map),
  );

  Future<Result<WeightRecordDto, ServiceError<OperationErrorTypes>>>
      createWeightRecord({
    required int weight,
    required DateTime date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    _logger.info('Creating weight record');
    try {
      final WeightRecord weightRecord = WeightRecord.create(
        weight,
        DateUtilities.getDateUnix(date),
        fatPercentage,
        pictureUri,
      );
      final int id = await _repository.insert(weightRecord);
      _logger.info('Created weight record with id $id');
      return ok(WeightRecordDto.fromModel(weightRecord.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create weight record', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create weight record',
      ));
    }
  }

  Future<
      Result<PaginatedDto<WeightRecordDto, WeightRecord>,
          ServiceError<OperationErrorTypes>>> getWeightRecords({
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting weight records');
    try {
      final List<WeightRecord> records = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        orderBy: 'record_date DESC, id DESC',
      );
      final int total = await _repository.count();
      _logger.info('Got ${records.length} weight records');
      return ok(PaginatedDto<WeightRecordDto, WeightRecord>.mapData(
        data: records,
        mapper: (record) => WeightRecordDto.fromModel(record),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get weight records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get weight records',
      ));
    }
  }

  Future<Result<WeightRecordDto, ServiceError<SingleErrorTypes>>>
      getLatestRecorded() async {
    _logger.info('Getting latest weight record');
    try {
      final List<WeightRecord> records = await _repository.selectMany(
        orderBy: 'record_date DESC, id DESC',
        limit: 1,
      );
      if (records.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Latest weight record not found',
        ));
      }

      _logger.info('Got latest weight record');
      return ok(WeightRecordDto.fromModel(records.first));
    } catch (e) {
      _logger.severe('Failed to get latest weight record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get latest weight record',
      ));
    }
  }

  Future<Result<int, ServiceError<OperationErrorTypes>>>
      getWeightRecordTotalCount() async {
    _logger.info('Getting weight record total count');
    try {
      final int count = await _repository.count();
      return ok(count);
    } catch (e) {
      _logger.severe('Failed to get weight record total count', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get weight record total count',
      ));
    }
  }

  Future<Result<WeightRecordDto, ServiceError<SingleErrorTypes>>>
      getWeightRecord(int id) async {
    _logger.info('Getting weight record with id $id');
    try {
      final WeightRecord? weightRecord = await _repository.selectOne(id);
      if (weightRecord == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight record not found',
        ));
      }
      _logger.info('Got weight record with id $id');
      return ok(WeightRecordDto.fromModel(weightRecord));
    } catch (e) {
      _logger.severe('Failed to get weight record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get weight record',
      ));
    }
  }

  Future<Result<WeightRecordDto, ServiceError<SingleErrorTypes>>>
      updateWeightRecord({
    required int id,
    int? weight,
    DateTime? date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    _logger.info('Updating weight record with id $id');
    try {
      final WeightRecord? weightRecord = await _repository.selectOne(id);

      if (weightRecord == null) {
        _logger.info('Weight record with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight record not found',
        ));
      }

      final WeightRecord updatedWeightRecord = weightRecord.copyWith(
        weight: weight,
        recordDate: date != null
            ? DateUtilities.getDateUnix(date)
            : weightRecord.recordDate,
        fatPercentage: fatPercentage,
        pictureUri: pictureUri,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedWeightRecord);
      _logger.info('Updated weight record with id $id');
      return ok(WeightRecordDto.fromModel(updatedWeightRecord));
    } catch (e) {
      _logger.severe('Failed to update weight record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update weight record',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWeightRecord(
      int id) async {
    _logger.info('Deleting weight record with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight record not found',
        ));
      }
      _logger.info('Deleted weight record with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete weight record with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete weight record',
      ));
    }
  }

  Future<Result<WeightGoalDto, ServiceError<OperationErrorTypes>>>
      createWeightGoal({
    required int targetWeight,
    required DateTime startDate,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    _logger.info('Creating weight goal');
    try {
      final WeightGoal weightGoal = WeightGoal.create(
        targetWeight: targetWeight,
        startDate: DateUtilities.getDateUnix(startDate),
        status: status,
      );
      final int id = await _weightGoalRepository.insert(weightGoal);
      _logger.info('Created weight goal with id $id');
      return ok(WeightGoalDto.fromModel(weightGoal.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create weight goal', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create weight goal',
      ));
    }
  }

  Future<
      Result<PaginatedDto<WeightGoalDto, WeightGoal>,
          ServiceError<OperationErrorTypes>>> getWeightGoals({
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting weight goals');
    try {
      final List<WeightGoal> goals =
          await _weightGoalRepository.selectPaginated(
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC, id DESC',
      );
      final int total = await _weightGoalRepository.count();
      _logger.info('Got ${goals.length} weight goals');
      return ok(PaginatedDto<WeightGoalDto, WeightGoal>.mapData(
        data: goals,
        mapper: (goal) => WeightGoalDto.fromModel(goal),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get weight goals', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get weight goals',
      ));
    }
  }

  Future<Result<WeightGoalDto, ServiceError<SingleErrorTypes>>> getWeightGoal(
      int id) async {
    _logger.info('Getting weight goal with id $id');
    try {
      final WeightGoal? weightGoal = await _weightGoalRepository.selectOne(id);
      if (weightGoal == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight goal not found',
        ));
      }
      _logger.info('Got weight goal with id $id');
      return ok(WeightGoalDto.fromModel(weightGoal));
    } catch (e) {
      _logger.severe('Failed to get weight goal with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get weight goal',
      ));
    }
  }

  Future<Result<WeightGoalDto, ServiceError<SingleErrorTypes>>>
      getActiveWeightGoal() async {
    _logger.info('Getting active weight goal');
    try {
      final List<WeightGoal> goals = await _weightGoalRepository.selectMany(
        where: 'status = ?',
        whereArgs: [ProgressStatus.inProgress.value],
        orderBy: 'id DESC',
        limit: 1,
      );
      if (goals.isEmpty) {
        _logger.info('No active weight goal found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No active weight goal found',
        ));
      }
      _logger.info('Got active weight goal ${goals.first.id}');
      return ok(WeightGoalDto.fromModel(goals.first));
    } catch (e) {
      _logger.severe('Failed to get active weight goal', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get active weight goal',
      ));
    }
  }

  Future<Result<WeightGoalDto, ServiceError<SingleErrorTypes>>>
      updateWeightGoal({
    required int id,
    int? targetWeight,
    DateTime? startDate,
    ProgressStatus? status,
    DateTime? completedAt,
  }) async {
    _logger.info('Updating weight goal with id $id');
    try {
      final WeightGoal? weightGoal = await _weightGoalRepository.selectOne(id);

      if (weightGoal == null) {
        _logger.info('Weight goal with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight goal not found',
        ));
      }

      final WeightGoal updatedWeightGoal = weightGoal.copyWith(
        targetWeight: targetWeight,
        startDate: startDate != null
            ? DateUtilities.getDateUnix(startDate)
            : weightGoal.startDate,
        completedAt: completedAt != null
            ? DateUtilities.getDateUnix(completedAt)
            : weightGoal.completedAt,
        status: status,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _weightGoalRepository.update(updatedWeightGoal);
      _logger.info('Updated weight goal with id $id');
      return ok(WeightGoalDto.fromModel(updatedWeightGoal));
    } catch (e) {
      _logger.severe('Failed to update weight goal with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update weight goal',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWeightGoal(
      int id) async {
    _logger.info('Deleting weight goal with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Weight goal not found',
        ));
      }
      _logger.info('Deleted weight goal with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete weight goal with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete weight goal',
      ));
    }
  }

  Future<Result<WeightGoalDto, ServiceError<SingleErrorTypes>>>
      completeWeightGoal(
    int id,
    DateTime completedAt,
  ) async {
    return await updateWeightGoal(
      id: id,
      status: ProgressStatus.completed,
      completedAt: completedAt,
    );
  }

  Future<Result<List<WeightGoalDto>, ServiceError<OperationErrorTypes>>>
      getWeightGoalsByStatus(ProgressStatus status) async {
    _logger.info('Getting weight goals by status $status');
    try {
      final List<WeightGoal> goals = await _weightGoalRepository.selectMany(
        where: 'status = ?',
        whereArgs: [status.value],
        orderBy: 'created_at DESC',
      );
      _logger.info('Got ${goals.length} weight goals with status $status');
      return ok(goals.map((g) => WeightGoalDto.fromModel(g)).toList());
    } catch (e) {
      _logger.severe('Failed to get weight goals by status', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get weight goals by status',
      ));
    }
  }
}
