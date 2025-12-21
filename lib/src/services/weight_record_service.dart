import '../models/db.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/weight_record_model.dart';

class WeightRecordService {
  WeightRecordService._();

  static final WeightRecordService _instance = WeightRecordService._();

  factory WeightRecordService() => _instance;

  final Repository<WeightRecord> _repository = Repository<WeightRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: WeightRecord.table,
    fromMap: (map) => WeightRecord.fromMap(map),
  );

  Future<WeightRecord> createWeightRecord({
    required int weight,
    required DateTime date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    final WeightRecord weightRecord = WeightRecord.create(
      weight,
      DateUtilities.getNumericDate(date),
      fatPercentage,
      pictureUri,
    );
    final int id = await _repository.insert(weightRecord);
    return weightRecord.copyWith(id: id);
  }

  Future<List<WeightRecord>> getWeightRecords({
    int? limit,
    int? offset,
  }) async {
    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      orderBy: 'record_date DESC, id DESC',
    );
  }

  Future<WeightRecord?> getLatestRecorded() async {
    final List<WeightRecord> records = await _repository.selectMany(
      orderBy: 'record_date DESC, id DESC',
      limit: 1,
    );
    return records.isNotEmpty ? records.first : null;
  }

  Future<int> getWeightRecordTotalCount() async {
    return await _repository.count();
  }

  Future<WeightRecord?> getWeightRecord(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WeightRecord> updateWeightRecord({
    required int id,
    int? weight,
    DateTime? date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    final WeightRecord? weightRecord = await _repository.selectOne(id);

    if (weightRecord == null) {
      throw Exception('Weight record does not exist');
    }

    final WeightRecord updatedWeightRecord = weightRecord.copyWith(
      weight: weight,
      recordDate: date != null
          ? DateUtilities.getNumericDate(date)
          : weightRecord.recordDate,
      fatPercentage: fatPercentage,
      pictureUri: pictureUri,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedWeightRecord);
    return updatedWeightRecord;
  }

  Future<bool> deleteWeightRecord(int id) async {
    return await _repository.deleteOne(id);
  }
}
