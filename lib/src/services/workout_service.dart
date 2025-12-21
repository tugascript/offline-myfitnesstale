import '../models/db.dart';
import '../models/enums.dart';
import '../models/muscle_group_model.dart';
import '../models/muscle_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_muscle_group_model.dart';
import '../models/workout_muscle_model.dart';

class WorkoutService {
  WorkoutService._();

  static final WorkoutService instance = WorkoutService._();

  factory WorkoutService() => instance;

  final Repository<Workout> _repository = Repository<Workout>(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: (map) => Workout.fromMap(map),
  );

  final JoinRepository<WorkoutMuscleGroup, MuscleGroup> _muscleGroupRepository =
      JoinRepository<WorkoutMuscleGroup, MuscleGroup>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscleGroup.table,
    joinTableName: MuscleGroup.table,
    fromMap: (map) => WorkoutMuscleGroup.fromMap(map),
    primaryKeys: WorkoutMuscleGroup.primaryKeys,
    joinFromMap: (map) => MuscleGroup.fromMap(map),
  );

  final JoinRepository<WorkoutMuscle, Muscle> _muscleRepository =
      JoinRepository<WorkoutMuscle, Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscle.table,
    joinTableName: Muscle.table,
    fromMap: (map) => WorkoutMuscle.fromMap(map),
    primaryKeys: WorkoutMuscle.primaryKeys,
    joinFromMap: (map) => Muscle.fromMap(map),
  );

  Future<List<Workout>> getWorkouts({
    String? name,
    Difficulty? difficulty,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('name LIKE ?', '%$name%');
    }

    if (difficulty != null) {
      query.add('difficulty = ?', difficulty.value);
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
    );
  }

  Future<Workout?> getWorkout(int id) async {
    return await _repository.selectOne(id);
  }

  Future<List<MuscleGroup>> getWorkoutMuscleGroups(int workoutId) async {
    return await _muscleGroupRepository.selectJoined(workoutId);
  }

  Future<List<Muscle>> getWorkoutMuscles(int workoutId) async {
    return await _muscleRepository.selectJoined(workoutId);
  }

  Future<Workout> createWorkout({
    required String name,
    required Difficulty difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    final Workout workout = Workout.create(
      name,
      difficulty,
      description,
      pictureUri,
      videoData,
    );
    final int id = await _repository.insert(workout);
    return workout.copyWith(id: id);
  }

  Future<Workout?> updateWorkout(
    int id, {
    String? name,
    Difficulty? difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    final Workout? workout = await getWorkout(id);
    if (workout == null) {
      return null;
    }

    final Workout updatedWorkout = workout.copyWith(
      name: name,
      difficulty: difficulty,
      description: description,
      pictureUri: pictureUri,
      videoData: videoData,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedWorkout);

    return updatedWorkout;
  }

  Future<bool> deleteWorkout(int id) async {
    return await _repository.deleteOne(id);
  }
}
