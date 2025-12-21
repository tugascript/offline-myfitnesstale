import '../models/db.dart';
import '../models/muscle_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';

class MuscleService {
  MuscleService._();

  static final MuscleService instance = MuscleService._();

  factory MuscleService() => instance;

  final Repository<Muscle> _repository = Repository<Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: Muscle.table,
    fromMap: (map) => Muscle.fromMap(map),
  );

  Future<List<Muscle>> getMuscles({
    String? name,
    int? muscleGroupId,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('name LIKE ?', '%$name%');
    }
    if (muscleGroupId != null) {
      query.add('muscle_group_id = ?', muscleGroupId);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
      orderBy: 'name ASC',
    );
  }

  Future<Muscle?> getMuscle(int id) async {
    return await _repository.selectOne(id);
  }

  Future<Muscle> createMuscle({
    required String name,
    required int muscleGroupId,
    String? pictureUri,
  }) async {
    final Muscle muscle = Muscle.create(
      name,
      muscleGroupId,
      pictureUri,
    );
    final int id = await _repository.insert(muscle);
    return muscle.copyWith(id: id);
  }

  Future<void> createMuscles(List<Muscle> muscles) async {
    await _repository.insertMany(muscles);
  }

  Future<bool> deleteMuscle(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<Muscle> updateMuscle(
    int id, {
    String? name,
    String? pictureUri,
    int? muscleGroupId,
  }) async {
    final Muscle? muscle = await _repository.selectOne(id);
    if (muscle == null) {
      throw Exception('Muscle does not exist');
    }

    final Muscle updatedMuscle = muscle.copyWith(
      name: name,
      pictureUri: pictureUri,
      muscleGroupId: muscleGroupId,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedMuscle);

    return updatedMuscle;
  }
}
