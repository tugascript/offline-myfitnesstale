import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/weight_goal_model.dart';

class WeightGoalService {
  WeightGoalService._();

  static final WeightGoalService _instance = WeightGoalService._();

  factory WeightGoalService() => _instance;

  final Repository<WeightGoal> _repository = Repository<WeightGoal>(
    databaseHelper: DatabaseHelper(),
    tableName: WeightGoal.table,
    fromMap: (map) => WeightGoal.fromMap(map),
  );

  Future<WeightGoal> createWeightGoal({
    required int targetWeight,
    required DateTime startDate,
    required DateTime endDate,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    final WeightGoal weightGoal = WeightGoal.create(
      targetWeight,
      DateUtilities.getNumericDate(startDate),
      DateUtilities.getNumericDate(endDate),
      status: status,
    );
    final int id = await _repository.insert(weightGoal);
    return weightGoal.copyWith(id: id);
  }

  Future<List<WeightGoal>> getWeightGoals({
    int? limit,
    int? offset,
  }) async {
    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC, id DESC',
    );
  }

  Future<WeightGoal?> getWeightGoal(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WeightGoal?> getActiveWeightGoal() async {
    final List<WeightGoal> goals = await _repository.selectPaginated(
      where: 'status = ?',
      whereArgs: [ProgressStatus.inProgress.value],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return goals.isNotEmpty ? goals.first : null;
  }

  Future<WeightGoal> updateWeightGoal({
    required int id,
    int? targetWeight,
    DateTime? startDate,
    DateTime? endDate,
    ProgressStatus? status,
    DateTime? completedAt,
  }) async {
    final WeightGoal? weightGoal = await _repository.selectOne(id);

    if (weightGoal == null) {
      throw Exception('Weight goal does not exist');
    }

    final WeightGoal updatedWeightGoal = weightGoal.copyWith(
      targetWeight: targetWeight,
      startDate: startDate != null
          ? DateUtilities.getNumericDate(startDate)
          : weightGoal.startDate,
      endDate: endDate != null
          ? DateUtilities.getNumericDate(endDate)
          : weightGoal.endDate,
      completedAt: completedAt != null
          ? DateUtilities.getNumericDate(completedAt)
          : weightGoal.completedAt,
      status: status,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedWeightGoal);
    return updatedWeightGoal;
  }

  Future<bool> deleteWeightGoal(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<WeightGoal> completeWeightGoal(int id, DateTime completedAt) async {
    return await updateWeightGoal(
      id: id,
      status: ProgressStatus.completed,
      completedAt: completedAt,
    );
  }

  Future<int> getWeightGoalCount({
    ProgressStatus? status,
  }) async {
    if (status != null) {
      return await _repository.count(
        where: 'status = ?',
        whereArgs: [status.value],
      );
    }
    return await _repository.count();
  }

  Future<List<WeightGoal>> getWeightGoalsByStatus(ProgressStatus status) async {
    return await _repository.selectMany(
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
  }
}
