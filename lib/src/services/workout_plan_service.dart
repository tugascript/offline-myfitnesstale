import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_model.dart';
import '../models/workout_plan_week_model.dart';
import '../models/workout_plan_workout_model.dart';

class WorkoutPlanService {
  WorkoutPlanService._();

  static final WorkoutPlanService instance = WorkoutPlanService._();

  factory WorkoutPlanService() => instance;

  final Repository<WorkoutPlan> _repository = Repository<WorkoutPlan>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlan.table,
    fromMap: (map) => WorkoutPlan.fromMap(map),
  );

  final Repository<WorkoutPlanWeek> _weekRepository =
      Repository<WorkoutPlanWeek>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeek.table,
    fromMap: (map) => WorkoutPlanWeek.fromMap(map),
  );

  final Repository<WorkoutPlanDay> _dayRepository = Repository<WorkoutPlanDay>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDay.table,
    fromMap: (map) => WorkoutPlanDay.fromMap(map),
  );

  final Repository<WorkoutPlanWorkout> _workoutRepository =
      Repository<WorkoutPlanWorkout>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkout.table,
    fromMap: (map) => WorkoutPlanWorkout.fromMap(map),
  );

  Future<List<WorkoutPlan>> getWorkoutPlans({
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
      orderBy: 'name ASC',
    );
  }

  Future<WorkoutPlan?> getWorkoutPlan(int id) async {
    return await _repository.selectOne(id);
  }

  Future<List<WorkoutPlanWeek>> getWorkoutPlanWeeks(int workoutPlanId) async {
    return await _weekRepository.selectMany(
      where: 'workout_plan_id = ?',
      whereArgs: [workoutPlanId],
      orderBy: 'start_week ASC',
    );
  }

  Future<List<WorkoutPlanDay>> getWorkoutPlanDays({
    required int workoutPlanId,
    int? workoutPlanWeekId,
  }) async {
    final WhereBuilder query = WhereBuilder();
    query.add('workout_plan_id = ?', workoutPlanId);

    if (workoutPlanWeekId != null) {
      query.add('workout_plan_week_id = ?', workoutPlanWeekId);
    }

    return await _dayRepository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'day ASC',
    );
  }

  Future<List<WorkoutPlanWorkout>> getWorkoutPlanWorkouts({
    required int workoutPlanId,
    int? workoutPlanWeekId,
    int? workoutPlanDayId,
  }) async {
    final WhereBuilder query = WhereBuilder();
    query.add('workout_plan_id = ?', workoutPlanId);

    if (workoutPlanWeekId != null) {
      query.add('workout_plan_week_id = ?', workoutPlanWeekId);
    }

    if (workoutPlanDayId != null) {
      query.add('workout_plan_day_id = ?', workoutPlanDayId);
    }

    return await _workoutRepository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'position ASC',
    );
  }

  Future<Workout?> getWorkoutForPlanWorkout(int workoutId) async {
    final db = await DatabaseHelper().db;
    final List<Map<String, dynamic>> maps = await db.query(
      Workout.table,
      where: 'id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Workout.fromMap(maps.first);
  }

  Future<WorkoutPlan> createWorkoutPlan({
    required String name,
    required int totalWeeks,
    required Difficulty difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    final WorkoutPlan plan = WorkoutPlan.create(
      name,
      totalWeeks,
      difficulty.value,
      description,
      pictureUri,
      videoData,
    );
    final int id = await _repository.insert(plan);
    return plan.copyWith(id: id);
  }

  Future<WorkoutPlan?> updateWorkoutPlan(
    int id, {
    String? name,
    int? totalWeeks,
    Difficulty? difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    final WorkoutPlan? plan = await getWorkoutPlan(id);
    if (plan == null) {
      return null;
    }

    final WorkoutPlan updatedPlan = plan.copyWith(
      name: name,
      totalWeeks: totalWeeks,
      difficulty: difficulty?.value ?? plan.difficulty,
      description: description,
      pictureUri: pictureUri,
      videoUri: videoData?.$2,
      videoPlatform: videoData?.$1.value,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedPlan);

    return updatedPlan;
  }

  Future<bool> deleteWorkoutPlan(int id) async {
    return await _repository.deleteOne(id);
  }
}
