import '../models/db.dart';
import '../models/muscle_group_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';

class MuscleGroupService {
  MuscleGroupService._();

  static final MuscleGroupService instance = MuscleGroupService._();

  factory MuscleGroupService() => instance;

  final Repository<MuscleGroup> _repository = Repository<MuscleGroup>(
    databaseHelper: DatabaseHelper(),
    tableName: MuscleGroup.table,
    fromMap: (map) => MuscleGroup.fromMap(map),
  );

  Future<List<MuscleGroup>> getMuscleGroups({String? name}) async {
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('name LIKE ?', '%$name%');
    }

    return await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
    );
  }

  Future<MuscleGroup?> getMuscleGroup(int id) async {
    return await _repository.selectOne(id);
  }

  Future<MuscleGroup> createMuscleGroup({
    required String name,
    required String pictureUri,
  }) async {
    final MuscleGroup muscleGroup = MuscleGroup.create(
      name,
      pictureUri,
    );
    final int id = await _repository.insert(muscleGroup);
    return muscleGroup.copyWith(id: id);
  }

  Future<void> createMuscleGroups(List<MuscleGroup> muscleGroups) async {
    await _repository.insertMany(muscleGroups);
  }

  Future<MuscleGroup?> updateMuscleGroup(
    int id, {
    String? name,
    String? pictureUri,
  }) async {
    final MuscleGroup? muscleGroup = await getMuscleGroup(id);
    if (muscleGroup == null) {
      return null;
    }

    final MuscleGroup updatedMuscleGroup = muscleGroup.copyWith(
      name: name,
      pictureUri: pictureUri,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(muscleGroup);

    return updatedMuscleGroup;
  }

  Future<bool> deleteMuscleGroup(int id) async {
    return await _repository.deleteOne(id);
  }
}
