import '../models/db.dart';
import '../models/enums.dart';
import '../models/equipment_model.dart';
import '../models/exercise_equipment_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_muscle_model.dart';
import '../models/muscle_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';

class ExerciseService {
  ExerciseService._();

  static final ExerciseService instance = ExerciseService._();

  factory ExerciseService() => instance;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final Repository<Exercise> _repository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: (map) => Exercise.fromMap(map),
  );

  final JoinRepository<ExerciseMuscle, Muscle> _exerciseMuscleRepository =
      JoinRepository<ExerciseMuscle, Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: ExerciseMuscle.table,
    fromMap: (map) => ExerciseMuscle.fromMap(map),
    primaryKeys: ExerciseMuscle.primaryKeys,
    joinTableName: Muscle.table,
    joinFromMap: (map) => Muscle.fromMap(map),
  );

  final JoinRepository<ExerciseEquipment, Equipment>
      _exerciseEquipmentRepository =
      JoinRepository<ExerciseEquipment, Equipment>(
    databaseHelper: DatabaseHelper(),
    tableName: ExerciseEquipment.table,
    fromMap: (map) => ExerciseEquipment.fromMap(map),
    primaryKeys: ExerciseEquipment.primaryKeys,
    joinTableName: Equipment.table,
    joinFromMap: (map) => Equipment.fromMap(map),
  );

  Future<List<Exercise>> getExercises({
    String? name,
    int? muscleGroupId,
    bool? isFavorite,
    int? difficulty,
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
    if (isFavorite != null) {
      query.add('is_favorite = ?', isFavorite ? 1 : 0);
    }
    if (difficulty != null) {
      query.add('difficulty = ?', difficulty);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
    );
  }

  Future<Exercise?> getExercise(int id) async {
    return await _repository.selectOne(id);
  }

  Future<Map<int, Exercise>> getExercisesByIdsLoader(List<int> ids) async {
    final WhereBuilder query = WhereBuilder();
    query.add('id IN (${ids.join(',')})');

    final List<Exercise> exercises = await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
    );

    return {for (final Exercise e in exercises) e.id!: e};
  }

  Future<List<Muscle>> getExerciseMuscles(int exerciseId) async {
    return await _exerciseMuscleRepository.selectJoined(exerciseId);
  }

  Future<List<Equipment>> getExerciseEquipments(int exerciseId) async {
    return await _exerciseEquipmentRepository.selectJoined(exerciseId);
  }

  Future<Exercise> createExercise({
    required String name,
    required int muscleGroupId,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
    List<(int, ExerciseMuscleCategory)>? muscleIds,
    List<int>? equipmentIds,
    int? difficulty,
    bool isFavorite = false,
  }) async {
    final Exercise exercise = Exercise.create(
      name: name,
      muscleGroupId: muscleGroupId,
      description: description,
      pictureUri: pictureUri,
      videoData: videoData,
    ).copyWith(
      isFavorite: isFavorite,
      difficulty: difficulty,
    );

    if (muscleIds == null && equipmentIds == null) {
      final int id = await _repository.insert(exercise);
      return exercise.copyWith(id: id);
    }

    final int id = await (await _databaseHelper.db).transaction((txn) async {
      final int exerciseId = await _repository.insert(exercise, txn);

      if (muscleIds != null) {
        final List<ExerciseMuscle> exerciseMuscles = muscleIds
            .map((e) => ExerciseMuscle.create(exerciseId, e.$1, e.$2))
            .toList();
        await _exerciseMuscleRepository.insertMany(exerciseMuscles, txn);
      }

      if (equipmentIds != null) {
        final List<ExerciseEquipment> exerciseEquipments = equipmentIds
            .map((e) => ExerciseEquipment.create(exerciseId, e))
            .toList();
        await _exerciseEquipmentRepository.insertMany(exerciseEquipments, txn);
      }

      return exerciseId;
    });
    return exercise.copyWith(id: id);
  }

  Future<void> createExercises(List<Exercise> exercises) async {
    await _repository.insertMany(exercises);
  }

  Future<Exercise?> updateExercise(
    int id, {
    String? name,
    String? description,
    int? muscleGroupId,
    String? pictureUri,
    String? videoUri,
    bool? isFavorite,
    int? difficulty,
  }) async {
    final Exercise? exercise = await _repository.selectOne(id);
    if (exercise == null) {
      return null;
    }

    final Exercise updatedExercise = exercise.copyWith(
      name: name,
      description: description,
      muscleGroupId: muscleGroupId,
      pictureUri: pictureUri,
      videoUri: videoUri,
      isFavorite: isFavorite,
      difficulty: difficulty,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedExercise);

    return updatedExercise;
  }

  Future<List<Exercise>> getFavoriteExercises({
    int? limit,
    int? offset,
  }) async {
    return await getExercises(
      isFavorite: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<bool> addExerciseMuscle(
    int exerciseId,
    int muscleId,
    ExerciseMuscleCategory category,
  ) async {
    final Exercise? exercise = await _repository.selectOne(exerciseId);
    if (exercise == null) {
      return false;
    }

    final ExerciseMuscle exerciseMuscle =
        ExerciseMuscle.create(exerciseId, muscleId, category);
    return await _exerciseMuscleRepository.insert(exerciseMuscle) > 0;
  }

  Future<bool> removeExerciseMuscle(int exerciseId, int muscleId) async {
    return await _exerciseMuscleRepository.deleteOne(exerciseId, muscleId);
  }

  Future<bool> addExerciseEquipment(
    int exerciseId,
    int equipmentId,
  ) async {
    final Exercise? exercise = await _repository.selectOne(exerciseId);
    if (exercise == null) {
      return false;
    }

    final ExerciseEquipment exerciseEquipment =
        ExerciseEquipment.create(exerciseId, equipmentId);
    return await _exerciseEquipmentRepository.insert(exerciseEquipment) > 0;
  }

  Future<bool> removeExerciseEquipment(int exerciseId, int equipmentId) async {
    return await _exerciseEquipmentRepository.deleteOne(
        exerciseId, equipmentId);
  }

  Future<bool> deleteExercise(int id) async {
    return await _repository.deleteOne(id);
  }
}
