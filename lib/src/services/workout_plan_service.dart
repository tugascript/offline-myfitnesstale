import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart'
    show Repository, kDefaultLimit, kDefaultOffset;
import '../models/utilities.dart' show WhereBuilder, DateUtilities;
import '../models/workout_model.dart';
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_model.dart';
import '../models/workout_plan_week_model.dart';
import '../models/workout_plan_workout_model.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_dto.dart';
import 'dtos/workout_plan_day_dto.dart';
import 'dtos/workout_plan_dto.dart';
import 'dtos/workout_plan_week_dto.dart';
import 'dtos/workout_plan_workout_dto.dart';

class WeekWorkoutInput {
  final int workoutId;
  final WorkoutTimeOfDay? timeOfDay;

  const WeekWorkoutInput({
    required this.workoutId,
    this.timeOfDay,
  });
}

class WorkoutPlanWorkoutRegistrationInput {
  final WorkoutDto workout;
  final WorkoutTimeOfDay timeOfDay;

  const WorkoutPlanWorkoutRegistrationInput({
    required this.workout,
    required this.timeOfDay,
  });
}

class WorkoutPlanDayRegistrationInput {
  final List<WorkoutPlanWorkoutRegistrationInput> workouts;

  const WorkoutPlanDayRegistrationInput({
    required this.workouts,
  });
}

class WorkoutPlanWeekRegistrationInput {
  final int startWeek;
  final int endWeek;
  final WorkoutPhase phase;
  final List<WorkoutPlanDayRegistrationInput> days;

  const WorkoutPlanWeekRegistrationInput({
    required this.startWeek,
    required this.endWeek,
    required this.phase,
    required this.days,
  });
}

class WorkoutPlanRegistrationInput {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final int totalWeeks;
  final int totalDays;
  final int totalWorkouts;
  final List<WorkoutPlanWeekRegistrationInput> weeks;

  const WorkoutPlanRegistrationInput({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalWorkouts,
    required this.weeks,
  });
}

class WorkoutPlanService {
  WorkoutPlanService._();

  static final WorkoutPlanService instance = WorkoutPlanService._();

  factory WorkoutPlanService() => instance;

  final Logger _logger = Logger('Workout Plan Service');

  final Repository<WorkoutPlan> _repository = Repository<WorkoutPlan>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlan.table,
    fromMap: WorkoutPlan.fromMap,
  );

  final Repository<WorkoutPlanWeek> _weekRepository =
      Repository<WorkoutPlanWeek>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWeek.table,
    fromMap: WorkoutPlanWeek.fromMap,
  );

  final Repository<WorkoutPlanDay> _dayRepository = Repository<WorkoutPlanDay>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanDay.table,
    fromMap: WorkoutPlanDay.fromMap,
  );

  final Repository<WorkoutPlanWorkout> _planWorkoutRepository =
      Repository<WorkoutPlanWorkout>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutPlanWorkout.table,
    fromMap: WorkoutPlanWorkout.fromMap,
  );

  final Repository<Workout> _workoutRepository = Repository<Workout>(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: Workout.fromMap,
  );

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<
      Result<PaginatedDto<WorkoutPlanDto, WorkoutPlan>,
          ServiceError<OperationErrorTypes>>> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workout plans');
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('name LIKE ?', '%$name%');
    }

    if (difficulty != null) {
      query.add('difficulty = ?', difficulty.value);
    }

    try {
      final List<WorkoutPlan> plans = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: 'name ASC',
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${plans.length} workout plans');
      return ok(PaginatedDto<WorkoutPlanDto, WorkoutPlan>.mapData(
        data: plans,
        mapper: WorkoutPlanDto.fromModel,
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get workout plans', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workout plans',
      ));
    }
  }

  Future<Result<WorkoutPlanDto, ServiceError<SingleErrorTypes>>> getWorkoutPlan(
    int id,
  ) async {
    _logger.info('Getting workout plan with id $id');
    try {
      final WorkoutPlan? plan = await _repository.selectOne(id);
      if (plan == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan with id $id not found',
        ));
      }

      // TODO: add weeks, days and workouts to the workout plan

      _logger.info('Got workout plan with id $id');
      return ok(WorkoutPlanDto.fromModel(plan));
    } catch (e) {
      _logger.severe('Failed to get workout plan with id $id', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan with error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanDto, ServiceError<OperationErrorTypes>>>
      createWorkoutPlan({
    required String name,
    required int totalWeeks,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout plan with name $name');
    try {
      final WorkoutPlan plan = WorkoutPlan.create(
        name: name,
        totalWeeks: totalWeeks,
        difficulty: difficulty,
        description: description,
        picture: picture,
        video: video,
      );
      final int id = await _repository.insert(plan);
      _logger.info('Created workout plan with id $id');
      return ok(WorkoutPlanDto.fromModel(plan.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout plan with name $name', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout plan',
      ));
    }
  }

  Future<Result<List<WorkoutPlanDto>, ServiceError<OperationErrorTypes>>>
      createWorkoutPlans(
    List<WorkoutPlanRegistrationInput> plans, {
    CreatedBy createdBy = CreatedBy.user,
  }) async {
    _logger.info('Creating ${plans.length} workout plans...');

    try {
      final List<WorkoutPlanDto> createdPlans =
          await (await _databaseHelper.db).transaction((txn) async {
        final List<WorkoutPlanDto> createdPlans = [];

        for (final planInput in plans) {
          final plan = WorkoutPlan.create(
            name: planInput.name,
            totalWeeks: planInput.totalWeeks,
            difficulty: planInput.difficulty,
            description: planInput.description,
            picture: planInput.picture,
            video: planInput.video,
            totalDays: planInput.totalDays,
            totalWorkouts: planInput.totalWorkouts,
            createdBy: createdBy,
          );

          final int planId = await _repository.insert(plan, txn);
          final List<WorkoutPlanWeekDto> createdWeeks = [];

          for (final weekInput in planInput.weeks) {
            final week = WorkoutPlanWeek.create(
              workoutPlanId: planId,
              startWeek: weekInput.startWeek,
              endWeek: weekInput.endWeek,
              phase: weekInput.phase,
              createdBy: createdBy,
            );

            final int weekId = await _weekRepository.insert(week, txn);
            final List<WorkoutPlanDayDto> createdDays = [];

            for (int i = 0; i < weekInput.days.length; i++) {
              final dayInput = weekInput.days[i];
              final day = WorkoutPlanDay.create(
                workoutPlanId: planId,
                workoutPlanWeekId: weekId,
                day: i + 1,
                createdBy: createdBy,
              );

              final int dayId = await _dayRepository.insert(day, txn);
              final List<WorkoutPlanWorkoutDto> createdWorkouts = [];

              for (int j = 0; j < dayInput.workouts.length; j++) {
                final workoutInput = dayInput.workouts[j];
                final workout = WorkoutPlanWorkout.create(
                  position: j + 1,
                  workoutPlanId: planId,
                  workoutPlanWeekId: weekId,
                  workoutPlanDayId: dayId,
                  workoutId: workoutInput.workout.id,
                  timeOfDay: workoutInput.timeOfDay,
                  createdBy: createdBy,
                );

                final int workoutKey = await _planWorkoutRepository.insert(
                  workout,
                  txn,
                );

                createdWorkouts.add(WorkoutPlanWorkoutDto.fromModel(
                  workout.copyWith(id: workoutKey),
                  workout: workoutInput.workout,
                ));
              }

              createdDays.add(WorkoutPlanDayDto.fromModel(
                day.copyWith(id: dayId),
                planWorkouts: createdWorkouts,
              ));
            }

            createdWeeks.add(WorkoutPlanWeekDto.fromModel(
              week.copyWith(id: weekId),
              days: createdDays,
            ));
          }

          createdPlans.add(WorkoutPlanDto.fromModel(
            plan.copyWith(id: planId),
            weeks: createdWeeks,
          ));
        }

        return createdPlans;
      });

      _logger.info('Created ${createdPlans.length} workout plans');
      return ok(createdPlans);
    } catch (e) {
      _logger.severe('Failed to create workout plans', e);
      return err(ServiceError(
        type: OperationErrorTypes.operationFailure,
        description:
            'Failed to create workout plans with error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlan(
    int id, {
    String? name,
    int? totalWeeks,
    Difficulty? difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Updating workout plan with id $id');
    try {
      final WorkoutPlan? plan = await _repository.selectOne(id);
      if (plan == null) {
        _logger.info('Workout plan with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan not found',
        ));
      }

      final WorkoutPlan updatedPlan = plan.copyWith(
        name: name,
        totalWeeks: totalWeeks,
        difficulty: difficulty,
        description: description,
        picture: picture,
        video: video,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedPlan);
      _logger.info('Updated workout plan with id $id');
      return ok(WorkoutPlanDto.fromModel(updatedPlan));
    } catch (e) {
      _logger.severe('Failed to update workout plan with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutPlan(
      int id) async {
    _logger.info('Deleting workout plan with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan not found',
        ));
      }
      _logger.info('Deleted workout plan with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout plan with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekDto, ServiceError<SingleErrorTypes>>>
      createWorkoutPlanWeek({
    required int workoutPlanId,
    required int startWeek,
    required int endWeek,
  }) async {
    _logger.info(
        'Creating workout plan week for workout plan with id $workoutPlanId');
    if (startWeek < 1 || endWeek < startWeek) {
      return err(ServiceError(
        type: SingleErrorTypes.invalidInput,
        description: 'Invalid week range',
      ));
    }

    try {
      final WorkoutPlan? workoutPlan =
          await _repository.selectOne(workoutPlanId);
      if (workoutPlan == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan with id $workoutPlanId not found',
        ));
      }

      final WorkoutPlanWeek week = WorkoutPlanWeek.create(
        workoutPlanId: workoutPlanId,
        startWeek: startWeek,
        endWeek: endWeek,
      );
      final int id = await _weekRepository.insert(week);
      _logger.info('Created workout plan week with id $id');
      return ok(WorkoutPlanWeekDto.fromModel(week.copyWith(id: id)));
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan week for workout plan with id $workoutPlanId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create workout plan week',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanWeek({
    required int weekId,
    int? startWeek,
    int? endWeek,
  }) async {
    _logger.info('Updating workout plan week with id $weekId');
    try {
      final WorkoutPlanWeek? week = await _weekRepository.selectOne(weekId);
      if (week == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week with id $weekId not found',
        ));
      }

      final WorkoutPlanWeek updatedWeek = week.copyWith(
        startWeek: startWeek,
        endWeek: endWeek,
      );
      await _weekRepository.update(updatedWeek);
      _logger.info('Updated workout plan week with id $weekId');
      return ok(WorkoutPlanWeekDto.fromModel(updatedWeek));
    } catch (e) {
      _logger.severe('Failed to update workout plan week with id $weekId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout plan week',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutPlanWeek(
    int weekId,
  ) async {
    _logger.info('Deleting workout plan week with id $weekId');
    try {
      final bool deleted = await _weekRepository.deleteOne(weekId);
      if (!deleted) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week with id $weekId not found',
        ));
      }
      _logger.info('Deleted workout plan week with id $weekId');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout plan week with id $weekId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout plan week',
      ));
    }
  }

  Future<Result<WorkoutPlanWeekDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanWeek(
    int weekId,
  ) async {
    _logger.info('Getting workout plan week with id $weekId');
    try {
      final WorkoutPlanWeek? week = await _weekRepository.selectOne(weekId);
      if (week == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan week with id $weekId not found',
        ));
      }

      final List<WorkoutPlanDay> days = await _dayRepository.selectMany(
        where: "${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [weekId],
      );
      if (days.isEmpty) {
        _logger.info('No days found for workout plan week with id $weekId');
        return ok(WorkoutPlanWeekDto.fromModel(week));
      }

      final List<WorkoutPlanWorkout> planWorkouts =
          await _planWorkoutRepository.selectMany(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [weekId],
        orderBy:
            "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} ASC, ${WorkoutPlanWorkoutColumns.position.value} ASC",
      );
      if (planWorkouts.isEmpty) {
        _logger.info('No workouts found for workout plan week with id $weekId');
        return ok(WorkoutPlanWeekDto.fromModel(
          week,
          days: days.map((day) => WorkoutPlanDayDto.fromModel(day)).toList(),
        ));
      }

      final workoutIds = planWorkouts.map((e) => e.workoutId).toList();
      final workouts = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          workoutIds.length,
          '?',
        ).join(', ')})",
        whereArgs: workoutIds,
      );
      if (workouts.length != workoutIds.length) {
        _logger.warning(
          'Not all workouts found for workout plan week with id $weekId',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Not all workouts found for workout plan week with id $weekId',
          ),
        );
      }

      final workoutMap = workouts.fold<Map<int, WorkoutDto>>(
        {},
        (map, workout) {
          map[workout.id!] = WorkoutDto.fromModel(workout);
          return map;
        },
      );
      final workoutPlans =
          planWorkouts.fold<Map<int, List<WorkoutPlanWorkoutDto>>>(
        {},
        (map, sw) {
          map.update(
            sw.workoutPlanDayId,
            (list) => list
              ..add(WorkoutPlanWorkoutDto.fromModel(
                sw,
                workout: workoutMap[sw.workoutId],
              )),
            ifAbsent: () => [
              WorkoutPlanWorkoutDto.fromModel(
                sw,
                workout: workoutMap[sw.workoutId],
              )
            ],
          );
          return map;
        },
      );

      _logger.info('Got workout plan week with id $weekId');
      return ok(WorkoutPlanWeekDto.fromModel(
        week,
        days: days
            .map(
              (day) => WorkoutPlanDayDto.fromModel(
                day,
                planWorkouts: workoutPlans[day.id],
              ),
            )
            .toList(),
      ));
    } catch (e) {
      _logger.severe('Failed to get workout plan week with id $weekId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan week',
      ));
    }
  }

  Future<Result<List<WorkoutPlanWeekDto>, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanWeeks(
    int workoutPlanId,
  ) async {
    _logger.info(
        'Getting workout plan weeks for workout plan with id $workoutPlanId');
    try {
      final WorkoutPlan? plan = await _repository.selectOne(workoutPlanId);
      if (plan == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout plan with id $workoutPlanId not found',
        ));
      }

      final List<WorkoutPlanWeek> weeks = await _weekRepository.selectMany(
        where: "${WorkoutPlanWeekColumns.workoutPlanId.value} = ?",
        whereArgs: [workoutPlanId],
        orderBy: "${WorkoutPlanWeekColumns.startWeek.value} ASC",
      );
      if (weeks.isEmpty) {
        _logger.info('No weeks found for workout plan with id $workoutPlanId');
        return ok([]);
      }

      final List<WorkoutPlanDay> days = await _dayRepository.selectMany(
        where: "${WorkoutPlanDayColumns.workoutPlanId.value} = ?",
        whereArgs: [workoutPlanId],
        orderBy:
            "${WorkoutPlanDayColumns.workoutPlanWeekId.value} ASC, ${WorkoutPlanDayColumns.day.value} ASC",
      );
      if (days.isEmpty) {
        _logger.info('No days found for workout plan with id $workoutPlanId');
        return ok(
            weeks.map((week) => WorkoutPlanWeekDto.fromModel(week)).toList());
      }

      final daysMap = days.fold<Map<int, List<WorkoutPlanDayDto>>>(
        {},
        (map, day) {
          map.update(
            day.workoutPlanWeekId,
            (list) => list..add(WorkoutPlanDayDto.fromModel(day)),
            ifAbsent: () => [WorkoutPlanDayDto.fromModel(day)],
          );
          return map;
        },
      );

      final List<WorkoutPlanWorkout> planWorkouts =
          await _planWorkoutRepository.selectMany(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanId.value} = ?",
        whereArgs: [workoutPlanId],
        orderBy:
            "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} ASC, ${WorkoutPlanWorkoutColumns.position.value} ASC",
      );
      if (planWorkouts.isEmpty) {
        _logger
            .info('No workouts found for workout plan with id $workoutPlanId');
        return ok(
          weeks
              .map(
                (week) => WorkoutPlanWeekDto.fromModel(
                  week,
                  days: daysMap[week.id],
                ),
              )
              .toList(),
        );
      }

      final workoutIds = planWorkouts.map((e) => e.workoutId).toList();
      final workouts = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          workoutIds.length,
          '?',
        ).join(', ')})",
        whereArgs: workoutIds,
      );
      if (workouts.length != workoutIds.length) {
        _logger.warning(
          'Not all workouts found for workout plan with id $workoutPlanId',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Not all workouts found for workout plan with id $workoutPlanId',
          ),
        );
      }

      final workoutMap = workouts.fold<Map<int, WorkoutDto>>(
        {},
        (map, workout) {
          map[workout.id!] = WorkoutDto.fromModel(workout);
          return map;
        },
      );
      final workoutPlans =
          planWorkouts.fold<Map<int, List<WorkoutPlanWorkoutDto>>>(
        {},
        (map, sw) {
          map.update(
            sw.workoutPlanDayId,
            (list) => list
              ..add(WorkoutPlanWorkoutDto.fromModel(
                sw,
                workout: workoutMap[sw.workoutId],
              )),
            ifAbsent: () => [
              WorkoutPlanWorkoutDto.fromModel(
                sw,
                workout: workoutMap[sw.workoutId],
              )
            ],
          );
          return map;
        },
      );

      _logger.info(
          'Got workout plan weeks for workout plan with id $workoutPlanId');
      return ok(
        weeks
            .map(
              (week) => WorkoutPlanWeekDto.fromModel(
                week,
                days: daysMap[week.id]
                    ?.map(
                      (day) => day.copyWith(planWorkouts: workoutPlans[day.id]),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
    } catch (e) {
      _logger.severe(
        'Failed to get workout plan weeks for workout plan with id $workoutPlanId',
        e,
      );
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan weeks',
      ));
    }
  }

  Future<Result<WorkoutPlanDayDto, ServiceError<SingleErrorTypes>>>
      createWorkoutPlanDay({
    required int workoutPlanWeekId,
    required List<WeekWorkoutInput> workouts,
    int? day,
  }) async {
    _logger.info(
        'Creating workout plan day for workout week with id $workoutPlanWeekId');

    if (day != null && day > 7) {
      _logger.warning('Day must be between 1 and 7');
      return err(const ServiceError(
        type: SingleErrorTypes.invalidInput,
        description: 'Day must be between 1 and 7',
      ));
    }
    if (workouts.isEmpty) {
      _logger.warning('Workouts cannot be empty');
      return err(const ServiceError(
        type: SingleErrorTypes.invalidInput,
        description: 'Workouts cannot be empty',
      ));
    }

    try {
      final WorkoutPlanWeek? week =
          await _weekRepository.selectOne(workoutPlanWeekId);
      if (week == null) {
        _logger.warning(
          'Workout plan week with id $workoutPlanWeekId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan week with id $workoutPlanWeekId not found',
          ),
        );
      }

      final int daysCount = await _dayRepository.count(
        where: "${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [workoutPlanWeekId],
      );
      if (day == null && daysCount >= 7) {
        _logger.warning(
          'Workout plan week with id $workoutPlanWeekId already has 7 days',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.operationFailure,
            description:
                'Workout plan week with id $workoutPlanWeekId already has 7 days',
          ),
        );
      }

      final List<Workout> workoutModels = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          workouts.length,
          '?',
        ).join(', ')})",
        whereArgs: workouts.map((e) => e.workoutId).toList(),
      );
      if (workoutModels.length != workouts.length) {
        _logger.warning('Not all workouts found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Not all workouts found',
          ),
        );
      }

      final workoutMap = workoutModels.fold<Map<int, WorkoutDto>>(
        {},
        (map, workout) {
          map[workout.id!] = WorkoutDto.fromModel(workout);
          return map;
        },
      );

      final int dayInt = day ?? daysCount + 1;
      final WorkoutPlanDay planDay = WorkoutPlanDay.create(
        workoutPlanId: week.workoutPlanId,
        workoutPlanWeekId: workoutPlanWeekId,
        day: dayInt > daysCount ? daysCount + 1 : dayInt,
      );

      final (int planDayId, List<WorkoutPlanWorkout> planWorkouts) =
          await (await _databaseHelper.db).transaction(
        (txn) async {
          final int planDayId = await _dayRepository.insert(planDay);
          final List<WorkoutPlanWorkout> planWorkouts = [];

          for (int i = 0; i < workouts.length; i++) {
            final workout = workouts[i];
            final WorkoutPlanWorkout planWorkout = WorkoutPlanWorkout.create(
              position: i + 1,
              workoutPlanId: week.workoutPlanId,
              workoutPlanWeekId: workoutPlanWeekId,
              workoutPlanDayId: planDayId,
              workoutId: workout.workoutId,
              timeOfDay: workout.timeOfDay,
            );
            final int planWorkoutId = await _planWorkoutRepository.insert(
              planWorkout,
              txn,
            );
            planWorkouts.add(planWorkout.copyWith(id: planWorkoutId));
          }

          if (planDay.day < daysCount) {
            await txn.rawUpdate(
              """
              UPDATE ${WorkoutPlanDay.table} SET ${WorkoutPlanDayColumns.day.value} = ${WorkoutPlanDayColumns.day.value} + 1 
              WHERE ${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ? AND ${WorkoutPlanDayColumns.day.value} >= ?
              """,
              [
                workoutPlanWeekId,
                planDay.day,
              ],
            );
          }
          return (planDayId, planWorkouts);
        },
      );

      _logger.info('Created workout plan day with id $planDayId');
      return ok(
        WorkoutPlanDayDto.fromModel(
          planDay.copyWith(id: planDayId),
          planWorkouts: planWorkouts
              .map(
                (e) => WorkoutPlanWorkoutDto.fromModel(
                  e,
                  workout: workoutMap[e.workoutId],
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan day for workout week with id $workoutPlanWeekId and day $day',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to create workout plan day with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanDayDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanDay({
    required int workoutPlanDayId,
    required int day,
  }) async {
    _logger.info(
        'Updating workout plan day with id $workoutPlanDayId and day $day');

    if (day > 7) {
      _logger.warning('Day must be between 1 and 7');
      return err(const ServiceError(
        type: SingleErrorTypes.invalidInput,
        description: 'Day must be between 1 and 7',
      ));
    }

    try {
      final WorkoutPlanDay? planDay =
          await _dayRepository.selectOne(workoutPlanDayId);
      if (planDay == null) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final int oldDay = planDay.day;
      final int daysCount = await _dayRepository.count(
        where: "${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [planDay.workoutPlanWeekId],
      );
      final int dayInt = day > daysCount ? daysCount : day;

      if (dayInt < oldDay) {
        await (await _databaseHelper.db).rawUpdate("""
        UPDATE ${WorkoutPlanDay.table} SET ${WorkoutPlanDayColumns.day.value} = ${WorkoutPlanDayColumns.day.value} + 1
        WHERE ${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ? AND ${WorkoutPlanDayColumns.day.value} >= ?
        """, [planDay.workoutPlanWeekId, dayInt]);
      } else if (dayInt > oldDay) {
        await (await _databaseHelper.db).rawUpdate("""
        UPDATE ${WorkoutPlanDay.table} SET ${WorkoutPlanDayColumns.day.value} = ${WorkoutPlanDayColumns.day.value} - 1
        WHERE ${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ? AND ${WorkoutPlanDayColumns.day.value} <= ?
        """, [planDay.workoutPlanWeekId, dayInt]);
      }

      final List<WorkoutPlanWorkout> planWorkouts =
          await _planWorkoutRepository.selectMany(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} = ?",
        whereArgs: [workoutPlanDayId],
      );
      if (planWorkouts.isEmpty) {
        return ok(WorkoutPlanDayDto.fromModel(planDay.copyWith(day: dayInt)));
      }

      final List<Workout> workouts = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          planWorkouts.length,
          '?',
        ).join(
          ', ',
        )})",
        whereArgs: planWorkouts.map((e) => e.workoutId).toList(),
      );
      if (workouts.length != planWorkouts.length) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final Map<int, WorkoutDto> workoutMap = workouts.fold({}, (map, workout) {
        map[workout.id!] = WorkoutDto.fromModel(workout);
        return map;
      });
      _logger.info('Updated workout plan day with id $workoutPlanDayId');
      return ok(
        WorkoutPlanDayDto.fromModel(
          planDay.copyWith(day: dayInt),
          planWorkouts: planWorkouts
              .map(
                (e) => WorkoutPlanWorkoutDto.fromModel(
                  e,
                  workout: workoutMap[e.workoutId],
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to update workout plan day with id $workoutPlanDayId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to update workout plan day with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutPlanDay(
    int workoutPlanDayId,
  ) async {
    _logger.info('Deleting workout plan day with id $workoutPlanDayId');
    try {
      final WorkoutPlanDay? planDay =
          await _dayRepository.selectOne(workoutPlanDayId);
      if (planDay == null) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final int day = planDay.day;
      final int daysCount = await _dayRepository.count(
        where: "${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [planDay.workoutPlanWeekId],
      );
      if (day < daysCount) {
        final result =
            await (await _databaseHelper.db).transaction((txn) async {
          final deleted = await _dayRepository.deleteOne(workoutPlanDayId, txn);
          if (!deleted) {
            return false;
          }

          await txn.rawUpdate(
            """
            UPDATE ${WorkoutPlanDay.table} SET ${WorkoutPlanDayColumns.day.value} = ${WorkoutPlanDayColumns.day.value} - 1
            WHERE ${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ? AND ${WorkoutPlanDayColumns.day.value} > ?
            """,
            [planDay.workoutPlanWeekId, day],
          );
          return true;
        });
        if (!result) {
          return err(
            ServiceError(
              type: SingleErrorTypes.operationFailure,
              description:
                  'Failed to delete workout plan day with id $workoutPlanDayId',
            ),
          );
        }

        _logger.info('Deleted workout plan day with id $workoutPlanDayId');
        return ok(null);
      }

      final result = await _dayRepository.deleteOne(workoutPlanDayId);
      if (!result) {
        return err(
          ServiceError(
            type: SingleErrorTypes.operationFailure,
            description:
                'Failed to delete workout plan day with id $workoutPlanDayId',
          ),
        );
      }

      _logger.info('Deleted workout plan day with id $workoutPlanDayId');
      return ok(null);
    } catch (e) {
      _logger.severe(
        'Failed to delete workout plan day with id $workoutPlanDayId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to delete workout plan day with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanDayDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanDay(int workoutPlanDayId) async {
    _logger.info('Getting workout plan day with id $workoutPlanDayId');
    try {
      final WorkoutPlanDay? planDay = await _dayRepository.selectOne(
        workoutPlanDayId,
      );
      if (planDay == null) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final List<WorkoutPlanWorkout> planWorkouts =
          await _planWorkoutRepository.selectMany(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} = ?",
        whereArgs: [workoutPlanDayId],
      );
      if (planWorkouts.isEmpty) {
        return ok(WorkoutPlanDayDto.fromModel(planDay));
      }

      final List<Workout> workouts = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          planWorkouts.length,
          '?',
        ).join(
          ', ',
        )})",
        whereArgs: planWorkouts.map((e) => e.workoutId).toList(),
      );
      if (workouts.length != planWorkouts.length) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final Map<int, WorkoutDto> workoutMap = workouts.fold({}, (map, workout) {
        map[workout.id!] = WorkoutDto.fromModel(workout);
        return map;
      });
      _logger.info('Got workout plan day with id $workoutPlanDayId');
      return ok(
        WorkoutPlanDayDto.fromModel(
          planDay,
          planWorkouts: planWorkouts
              .map(
                (e) => WorkoutPlanWorkoutDto.fromModel(
                  e,
                  workout: workoutMap[e.workoutId],
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to get workout plan day with id $workoutPlanDayId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout plan day with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<List<WorkoutPlanDayDto>, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanDays(int workoutPlanWeekId) async {
    _logger.info(
        'Getting workout plan days with workout plan week id $workoutPlanWeekId');
    try {
      final WorkoutPlanWeek? planWeek = await _weekRepository.selectOne(
        workoutPlanWeekId,
      );
      if (planWeek == null) {
        _logger.warning(
          'Workout plan week with id $workoutPlanWeekId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan week with id $workoutPlanWeekId not found',
          ),
        );
      }

      final List<WorkoutPlanDay> planDays = await _dayRepository.selectMany(
        where: "${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [workoutPlanWeekId],
        orderBy: '${WorkoutPlanDayColumns.day.value} ASC',
      );
      if (planDays.isEmpty) {
        return ok([]);
      }

      final List<WorkoutPlanWorkout> planWorkouts =
          await _planWorkoutRepository.selectMany(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanWeekId.value} = ?",
        whereArgs: [workoutPlanWeekId],
        orderBy:
            '${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} ASC, ${WorkoutPlanWorkoutColumns.position} ASC',
      );
      final Set<int> workoutIds = planWorkouts.map((e) => e.workoutId).toSet();
      final List<Workout> workouts = await _workoutRepository.selectMany(
        where: "${WorkoutColumns.id.value} IN (${List.filled(
          workoutIds.length,
          '?',
        ).join(
          ', ',
        )})",
        whereArgs: workoutIds.toList(),
      );
      if (workouts.length != workoutIds.length) {
        _logger.warning(
          'Workout plan week with id $workoutPlanWeekId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan week with id $workoutPlanWeekId not found',
          ),
        );
      }

      final Map<int, WorkoutDto> workoutMap = workouts.fold({}, (map, workout) {
        map[workout.id!] = WorkoutDto.fromModel(workout);
        return map;
      });
      final Map<int, List<WorkoutPlanWorkoutDto>> planWorkoutMap =
          planWorkouts.fold(
        {},
        (map, planWorkout) => map
          ..update(
            planWorkout.workoutPlanDayId,
            (value) => value
              ..add(
                WorkoutPlanWorkoutDto.fromModel(
                  planWorkout,
                  workout: workoutMap[planWorkout.workoutId],
                ),
              ),
            ifAbsent: () => [
              WorkoutPlanWorkoutDto.fromModel(
                planWorkout,
                workout: workoutMap[planWorkout.workoutId],
              ),
            ],
          ),
      );

      _logger.info(
        'Got workout plan days with workout plan week id $workoutPlanWeekId',
      );
      return ok(
        planDays
            .map(
              (e) => WorkoutPlanDayDto.fromModel(
                e,
                planWorkouts: planWorkoutMap[e.id],
              ),
            )
            .toList(),
      );
    } catch (e) {
      _logger.severe(
        'Failed to get workout plan days with workout plan week id $workoutPlanWeekId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to get workout plan days with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutDto, ServiceError<SingleErrorTypes>>>
      getWorkoutPlanWorkout(
    int workoutPlanWorkoutId,
  ) async {
    _logger.info('Getting workout plan workout with id $workoutPlanWorkoutId');
    try {
      final WorkoutPlanWorkout? planWorkout =
          await _planWorkoutRepository.selectOne(workoutPlanWorkoutId);
      if (planWorkout == null) {
        _logger.warning(
          'Workout plan workout with id $workoutPlanWorkoutId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan workout with id $workoutPlanWorkoutId not found',
          ),
        );
      }

      final Workout? workout = await _workoutRepository.selectOne(
        planWorkout.workoutId,
      );
      if (workout == null) {
        _logger.warning(
          'Workout with id ${planWorkout.workoutId} not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout with id ${planWorkout.workoutId} not found',
          ),
        );
      }

      _logger.info('Got workout plan workout with id $workoutPlanWorkoutId');
      return ok(
        WorkoutPlanWorkoutDto.fromModel(
          planWorkout,
          workout: WorkoutDto.fromModel(workout),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to get workout plan workout with id $workoutPlanWorkoutId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to get workout plan workout with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutDto, ServiceError<SingleErrorTypes>>>
      createWorkoutPlanWorkout({
    required int workoutPlanDayId,
    required int workoutId,
    int? position,
    WorkoutTimeOfDay? timeOfDay,
  }) async {
    _logger.info(
      "Creating workout plan workout for workout plan day with id $workoutPlanDayId",
    );
    try {
      final WorkoutPlanDay? planDay = await _dayRepository.selectOne(
        workoutPlanDayId,
      );
      if (planDay == null) {
        _logger.warning(
          'Workout plan day with id $workoutPlanDayId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout plan day with id $workoutPlanDayId not found',
          ),
        );
      }

      final Workout? workout = await _workoutRepository.selectOne(workoutId);
      if (workout == null) {
        _logger.warning('Workout with id $workoutId not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout with id $workoutId not found',
          ),
        );
      }

      final int count = await _planWorkoutRepository.count(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} = ?",
        whereArgs: [workoutPlanDayId],
      );
      final int finalPosition = count + 1;
      final int intPosition = position ?? finalPosition;
      final int workoutPosition =
          intPosition > finalPosition ? finalPosition : intPosition;
      final WorkoutPlanWorkout planWorkout = WorkoutPlanWorkout.create(
        workoutPlanId: planDay.workoutPlanId,
        workoutPlanWeekId: planDay.workoutPlanWeekId,
        workoutPlanDayId: workoutPlanDayId,
        workoutId: workoutId,
        position: workoutPosition,
        timeOfDay: timeOfDay,
      );

      if (workoutPosition == finalPosition) {
        final int id = await _planWorkoutRepository.insert(planWorkout);
        _logger.info(
          'Created workout plan workout for workout plan day with id $workoutPlanDayId',
        );
        return ok(
          WorkoutPlanWorkoutDto.fromModel(
            planWorkout.copyWith(id: id),
            workout: WorkoutDto.fromModel(workout),
          ),
        );
      }

      final int id = await (await _databaseHelper.db).transaction((txn) async {
        await txn.rawUpdate("""
          UPDATE workout_plan_workouts
          SET position = position + 1
          WHERE workout_plan_day_id = ?
          AND position >= ?
        """, [
          workoutPlanDayId,
          workoutPosition,
        ]);
        final int id = await _planWorkoutRepository.insert(planWorkout, txn);
        return id;
      });

      _logger.info(
        'Created workout plan workout for workout plan day with id $workoutPlanDayId',
      );
      return ok(
        WorkoutPlanWorkoutDto.fromModel(
          planWorkout.copyWith(id: id),
          workout: WorkoutDto.fromModel(workout),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout plan workout for workout plan day with id $workoutPlanDayId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to create workout plan workout with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutPlanWorkoutDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutPlanWorkout({
    required int workoutPlanWorkoutId,
    required int position,
    WorkoutTimeOfDay? timeOfDay,
  }) async {
    _logger.info('Updating workout plan workout with id $workoutPlanWorkoutId');
    try {
      final WorkoutPlanWorkout? planWorkout =
          await _planWorkoutRepository.selectOne(
        workoutPlanWorkoutId,
      );
      if (planWorkout == null) {
        _logger.warning(
            'Workout plan workout with id $workoutPlanWorkoutId not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan workout with id $workoutPlanWorkoutId not found',
          ),
        );
      }

      final Workout? workout = await _workoutRepository.selectOne(
        planWorkout.workoutId,
      );
      if (workout == null) {
        _logger.warning('Workout with id ${planWorkout.workoutId} not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout with id ${planWorkout.workoutId} not found',
          ),
        );
      }

      if (position == planWorkout.position) {
        final WorkoutPlanWorkout updatedPlanWorkout = planWorkout.copyWith(
          timeOfDay: timeOfDay,
        );
        await _planWorkoutRepository.update(updatedPlanWorkout);
        _logger.info(
          'Updated workout plan workout with id $workoutPlanWorkoutId',
        );
        return ok(
          WorkoutPlanWorkoutDto.fromModel(
            updatedPlanWorkout,
            workout: WorkoutDto.fromModel(workout),
          ),
        );
      }

      final int oldPosition = planWorkout.position;
      final int finalPosition = await _planWorkoutRepository.count(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} = ?",
        whereArgs: [planWorkout.workoutPlanDayId],
      );
      final int workoutPosition =
          position > finalPosition ? finalPosition : position;
      final WorkoutPlanWorkout updatedPlanWorkout = planWorkout.copyWith(
        position: workoutPosition,
        timeOfDay: timeOfDay,
      );
      await (await _databaseHelper.db).transaction((txn) async {
        await _planWorkoutRepository.update(updatedPlanWorkout, txn);
        if (workoutPosition > oldPosition) {
          await txn.rawUpdate("""
            UPDATE workout_plan_workouts
            SET position = position - 1
            WHERE workout_plan_day_id = ?
            AND position > ?
            AND position <= ?
            AND id != ?
          """, [
            planWorkout.workoutPlanDayId,
            oldPosition,
            workoutPosition,
            workoutPlanWorkoutId,
          ]);
        } else {
          await txn.rawUpdate("""
            UPDATE workout_plan_workouts
            SET position = position + 1
            WHERE workout_plan_day_id = ?
            AND position >= ?
            AND position < ?
            AND id != ?
          """, [
            planWorkout.workoutPlanDayId,
            workoutPosition,
            oldPosition,
            workoutPlanWorkoutId,
          ]);
        }
      });
      _logger.info(
        'Updated workout plan workout with id $workoutPlanWorkoutId',
      );
      return ok(
        WorkoutPlanWorkoutDto.fromModel(
          updatedPlanWorkout,
          workout: WorkoutDto.fromModel(workout),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to update workout plan workout with id $workoutPlanWorkoutId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to update workout plan workout with err: ${e.toString()}',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutPlanWorkout({
    required int workoutPlanWorkoutId,
  }) async {
    _logger.info('Deleting workout plan workout with id $workoutPlanWorkoutId');
    try {
      final WorkoutPlanWorkout? planWorkout =
          await _planWorkoutRepository.selectOne(
        workoutPlanWorkoutId,
      );
      if (planWorkout == null) {
        _logger.warning(
            'Workout plan workout with id $workoutPlanWorkoutId not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout plan workout with id $workoutPlanWorkoutId not found',
          ),
        );
      }

      final int finalPosition = await _planWorkoutRepository.count(
        where: "${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} = ?",
        whereArgs: [planWorkout.workoutPlanDayId],
      );
      if (finalPosition == 1) {
        _logger.warning(
          'Workout plan workout with id $workoutPlanWorkoutId is the last workout in the workout plan day',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.operationFailure,
            description:
                'Workout plan workout with id $workoutPlanWorkoutId is the last workout in the workout plan day',
          ),
        );
      }
      if (planWorkout.position == finalPosition) {
        final deleted = await _planWorkoutRepository.deleteOne(
          workoutPlanWorkoutId,
        );
        if (!deleted) {
          _logger.warning(
            'Failed to delete plan workout with id: $workoutPlanWorkoutId',
          );
          return err(
            ServiceError(
              type: SingleErrorTypes.operationFailure,
              description:
                  'Failed to delete workout plan workout with id: $workoutPlanWorkoutId',
            ),
          );
        }

        _logger.info(
          'Deleted workout plan workout with id $workoutPlanWorkoutId',
        );
        return ok(null);
      }

      final deleted = await (await _databaseHelper.db).transaction((txn) async {
        final deleted = await _planWorkoutRepository.deleteOne(
          workoutPlanWorkoutId,
          txn,
        );
        if (!deleted) {
          return false;
        }

        await txn.rawUpdate("""
          UPDATE workout_plan_workouts SET position = position - 1
          WHERE workout_plan_day_id = ? AND position > ?
        """, [
          planWorkout.workoutPlanDayId,
          planWorkout.position,
        ]);
        return true;
      });

      if (!deleted) {
        _logger.warning(
          'Failed to delete plan workout with id: $workoutPlanWorkoutId',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.operationFailure,
            description:
                'Failed to delete workout plan workout with id: $workoutPlanWorkoutId',
          ),
        );
      }

      _logger.info(
        'Deleted workout plan workout with id $workoutPlanWorkoutId',
      );
      return ok(null);
    } catch (e) {
      _logger.severe(
        'Failed to delete workout plan workout with id $workoutPlanWorkoutId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Failed to delete workout plan workout with err: ${e.toString()}',
      ));
    }
  }
}
