import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/cubits/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/profile_state.dart';
import 'package:myfitnesstale/src/cubits/workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_record_cubit.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/routing/app_router.dart';
import 'package:myfitnesstale/src/routing/routing.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_progress_view.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_records_view.dart';
import 'package:myfitnesstale/src/views/not_found_view.dart';
import 'package:myfitnesstale/src/views/profile/reminder_preferences_view.dart';
import 'package:myfitnesstale/src/views/workout_plans/workout_plan_history_view.dart';
import 'package:myfitnesstale/src/views/workouts/workout_history_view.dart';

class _ExerciseCubit extends ExerciseCubit {
  @override
  Future<void> getExercise(int id) async {}
}

class _ExerciseRecordCubit extends ExerciseRecordCubit {
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

  _WorkoutCubit({WorkoutDto? selectedWorkout}) {
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
  @override
  Future<void> getWorkoutPlanRecords({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit() {
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
        remindersConfig: const RemindersConfigDto(
          id: 1,
          workoutsOn: false,
          weightRecordsOn: false,
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

    expect(find.byType(ExerciseProgressView), findsOneWidget);
    expect(find.byType(NotFoundView), findsNothing);
  });

  testWidgets('global and single plan history routing resolve', (tester) async {
    await pumpRoute(tester, WorkoutPlanHistoryView.location());

    var view = tester.widget<WorkoutPlanHistoryView>(
      find.byType(WorkoutPlanHistoryView),
    );
    expect(view.workoutPlanId, isNull);

    await pumpRoute(tester, WorkoutPlanHistoryView.location(42));

    view = tester.widget<WorkoutPlanHistoryView>(
      find.byType(WorkoutPlanHistoryView),
    );
    expect(view.workoutPlanId, 42);
  });

  testWidgets('invalid plan history IDs show Not Found', (tester) async {
    await pumpRoute(tester, '/workout-plans/history?id=not-a-number');

    expect(find.byType(NotFoundView), findsOneWidget);
  });

  testWidgets('global and single workout history routing resolve', (
    tester,
  ) async {
    await pumpRoute(tester, WorkoutHistoryView.location());

    var view = tester.widget<WorkoutHistoryView>(
      find.byType(WorkoutHistoryView),
    );
    expect(view.workoutId, isNull);
    expect(view.version, isNull);

    await pumpRoute(
      tester,
      WorkoutHistoryView.location(workoutId: 12, version: 3),
    );

    view = tester.widget<WorkoutHistoryView>(find.byType(WorkoutHistoryView));
    expect(view.workoutId, 12);
    expect(view.version, 3);

    final workoutCubit = await pumpRoute(
      tester,
      WorkoutHistoryView.location(workoutId: 12),
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

    view = tester.widget<WorkoutHistoryView>(find.byType(WorkoutHistoryView));
    expect(view.workoutId, 12);
    expect(view.version, isNull);
    expect(workoutCubit.calls, [(12, null)]);
  });

  testWidgets('invalid workout history query params show Not Found', (
    tester,
  ) async {
    await pumpRoute(tester, '/workouts/history?id=not-a-number');
    expect(find.byType(NotFoundView), findsOneWidget);

    await pumpRoute(tester, '/workouts/history?version=3');
    expect(find.byType(NotFoundView), findsOneWidget);

    await pumpRoute(tester, '/workouts/history?id=12&version=not-a-number');
    expect(find.byType(NotFoundView), findsOneWidget);
  });

  testWidgets('reminder preferences resolve', (tester) async {
    await pumpRoute(tester, Routes.reminderPreferences.name);

    expect(find.byType(ReminderPreferencesView), findsOneWidget);
  });

  testWidgets('exercise records resolve with a parsed ID', (tester) async {
    await pumpRoute(tester, ExerciseRecordsView.location(17));

    final view = tester.widget<ExerciseRecordsView>(
      find.byType(ExerciseRecordsView),
    );
    expect(view.exerciseId, 17);
  });

  testWidgets('unknown paths still show Not Found', (tester) async {
    await pumpRoute(tester, '/definitely-unknown');

    expect(find.byType(NotFoundView), findsOneWidget);
  });
}
