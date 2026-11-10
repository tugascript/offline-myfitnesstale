// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_record_cubit.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/app_router.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_progress_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_records_screen.dart';
import 'package:myfitnesstale/src/ui/core/screens/not_found_screen.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/reminder_preferences_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_history_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workout_history_screen.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';

class _ExerciseCubit extends ExerciseCubit {
  _ExerciseCubit() : super(exerciseRepository: ExerciseRepository.create());

  @override
  Future<void> getExercise(int id) async {}
}

class _ExerciseRecordCubit extends ExerciseRecordCubit {
  _ExerciseRecordCubit()
    : super(exerciseRecordRepository: ExerciseRecordRepository.create());

  @override
  Future<void> getExerciseRecords({
    int limit = 25,
    int offset = 0,
    (DateTime start, DateTime end)? dateRange,
    int? exerciseId,
  }) async {}
}

class _WorkoutCubit extends WorkoutCubit {
  final List<(int, int?)> calls = [];

  _WorkoutCubit({WorkoutDto? selectedWorkout})
    : super(workoutRepository: WorkoutRepository.create()) {
    if (selectedWorkout != null) {
      emit(state.copyWith(selectedWorkout: Nullable(selectedWorkout)));
    }
  }

  @override
  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    calls.add((id, version));
  }
}

class _WorkoutRecordCubit extends WorkoutRecordCubit {
  _WorkoutRecordCubit()
    : super(workoutRecordRepository: WorkoutRecordRepository.create());

  @override
  Future<void> getLatestWorkoutRecord([int? workoutId]) async {}

  @override
  Future<void> getWorkoutRecords({
    int? workoutId,
    int? limit,
    int? offset,
    (DateTime start, DateTime end)? dateRange,
  }) async {}
}

class _WorkoutPlanRecordCubit extends WorkoutPlanRecordCubit {
  _WorkoutPlanRecordCubit()
    : super(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
      );

  @override
  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit() : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Router Tester',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ),
        system: const SystemDto(
          id: 1,
          units: Units.metric,
          theme: ThemeType.system,
          initialSetup: SetUpStatus.completed,
          notificationsOn: false,
        ),
        remindersConfig: RemindersConfigDto(
          id: 1,
          workoutsOn: false,
          workoutsReminderTime: DateTime(2026, 1, 1, 8),
          weightRecordsOn: false,
          weightRecordsReminderTime: DateTime(2026, 1, 1, 8),
          macroTrackingOn: false,
          macroTrackingReminderTime: DateTime(2026, 1, 1, 8),
        ),
        isLoading: false,
        isInitiated: true,
      ),
    );
  }

  @override
  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
    bool? macroTrackingOn,
  }) async {}
}

void main() {
  Future<_WorkoutCubit> pumpRoute(
    WidgetTester tester,
    String location, {
    WorkoutDto? selectedWorkout,
  }) async {
    final exerciseCubit = _ExerciseCubit();
    final exerciseRecordCubit = _ExerciseRecordCubit();
    final workoutCubit = _WorkoutCubit(selectedWorkout: selectedWorkout);
    final workoutRecordCubit = _WorkoutRecordCubit();
    final workoutPlanRecordCubit = _WorkoutPlanRecordCubit();
    final profileCubit = _ProfileCubit();
    final router = AppRouter.createRouter(initialLocation: location);

    addTearDown(() async {
      router.dispose();
      await exerciseCubit.close();
      await exerciseRecordCubit.close();
      await workoutCubit.close();
      await workoutRecordCubit.close();
      await workoutPlanRecordCubit.close();
      await profileCubit.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
          BlocProvider<ExerciseRecordCubit>.value(value: exerciseRecordCubit),
          BlocProvider<WorkoutCubit>.value(value: workoutCubit),
          BlocProvider<WorkoutRecordCubit>.value(value: workoutRecordCubit),
          BlocProvider<WorkoutPlanRecordCubit>.value(
            value: workoutPlanRecordCubit,
          ),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    return workoutCubit;
  }

  testWidgets('exercise progress wins over the dynamic exercise ID route', (
    tester,
  ) async {
    await pumpRoute(tester, Routes.exerciseProgress.name);

    expect(find.byType(ExerciseProgressScreen), findsOneWidget);
    expect(find.byType(NotFoundScreen), findsNothing);
  });

  testWidgets('global and single plan history routing resolve', (tester) async {
    await pumpRoute(tester, WorkoutPlanHistoryScreen.location());

    var view = tester.widget<WorkoutPlanHistoryScreen>(
      find.byType(WorkoutPlanHistoryScreen),
    );
    expect(view.workoutPlanId, isNull);

    await pumpRoute(tester, WorkoutPlanHistoryScreen.location(42));

    view = tester.widget<WorkoutPlanHistoryScreen>(
      find.byType(WorkoutPlanHistoryScreen),
    );
    expect(view.workoutPlanId, 42);
  });

  testWidgets('invalid plan history IDs show Not Found', (tester) async {
    await pumpRoute(tester, '/workout-plans/history?id=not-a-number');

    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  testWidgets('global and single workout history routing resolve', (
    tester,
  ) async {
    await pumpRoute(tester, WorkoutHistoryScreen.location());

    var view = tester.widget<WorkoutHistoryScreen>(
      find.byType(WorkoutHistoryScreen),
    );
    expect(view.workoutId, isNull);
    expect(view.version, isNull);

    await pumpRoute(
      tester,
      WorkoutHistoryScreen.location(workoutId: 12, version: 3),
    );

    view = tester.widget<WorkoutHistoryScreen>(
      find.byType(WorkoutHistoryScreen),
    );
    expect(view.workoutId, 12);
    expect(view.version, 3);

    final workoutCubit = await pumpRoute(
      tester,
      WorkoutHistoryScreen.location(workoutId: 12),
      selectedWorkout: const WorkoutDto(
        id: 12,
        name: 'Cached Older Workout',
        muscleGroups: {MuscleGroup.push},
        muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
        difficulty: Difficulty.intermediate,
        version: 1,
        isFavorite: false,
        totalSets: 3,
        totalReps: 30,
        editorType: EditorType.basic,
        createdBy: CreatedBy.user,
      ),
    );

    view = tester.widget<WorkoutHistoryScreen>(
      find.byType(WorkoutHistoryScreen),
    );
    expect(view.workoutId, 12);
    expect(view.version, isNull);
    expect(workoutCubit.calls, [(12, null)]);
  });

  testWidgets('invalid workout history query params show Not Found', (
    tester,
  ) async {
    await pumpRoute(tester, '/workouts/history?id=not-a-number');
    expect(find.byType(NotFoundScreen), findsOneWidget);

    await pumpRoute(tester, '/workouts/history?version=3');
    expect(find.byType(NotFoundScreen), findsOneWidget);

    await pumpRoute(tester, '/workouts/history?id=12&version=not-a-number');
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  testWidgets('reminder preferences resolve', (tester) async {
    await pumpRoute(tester, Routes.reminderPreferences.name);

    expect(find.byType(ReminderPreferencesScreen), findsOneWidget);
  });

  testWidgets('exercise records resolve with a parsed ID', (tester) async {
    await pumpRoute(tester, ExerciseRecordsScreen.location(17));

    final view = tester.widget<ExerciseRecordsScreen>(
      find.byType(ExerciseRecordsScreen),
    );
    expect(view.exerciseId, 17);
  });

  testWidgets('unknown paths still show Not Found', (tester) async {
    await pumpRoute(tester, '/definitely-unknown');

    expect(find.byType(NotFoundScreen), findsOneWidget);
  });
}
