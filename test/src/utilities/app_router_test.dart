import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/cubits/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/profile_state.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/utilities/app_router.dart';
import 'package:myfitnesstale/src/views/exercise_progress_view.dart';
import 'package:myfitnesstale/src/views/exercises/exercise_records_view.dart';
import 'package:myfitnesstale/src/views/not_found_view.dart';
import 'package:myfitnesstale/src/views/profile/reminder_preferences_view.dart';
import 'package:myfitnesstale/src/views/workout_plans/workout_plan_history_view.dart';

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
    emit(ProfileState(
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
    ));
  }

  @override
  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
  }) async {}
}

void main() {
  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final exerciseCubit = _ExerciseCubit();
    final exerciseRecordCubit = _ExerciseRecordCubit();
    final workoutPlanRecordCubit = _WorkoutPlanRecordCubit();
    final profileCubit = _ProfileCubit();
    final router = AppRouter.createRouter(initialLocation: location);

    addTearDown(() async {
      router.dispose();
      await exerciseCubit.close();
      await exerciseRecordCubit.close();
      await workoutPlanRecordCubit.close();
      await profileCubit.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ExerciseCubit>.value(value: exerciseCubit),
          BlocProvider<ExerciseRecordCubit>.value(value: exerciseRecordCubit),
          BlocProvider<WorkoutPlanRecordCubit>.value(
            value: workoutPlanRecordCubit,
          ),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  testWidgets('exercise progress wins over the dynamic exercise ID route',
      (tester) async {
    await pumpRoute(tester, ExerciseProgressView.routeName);

    expect(find.byType(ExerciseProgressView), findsOneWidget);
    expect(find.byType(NotFoundView), findsNothing);
  });

  testWidgets('valid plan history IDs resolve', (tester) async {
    await pumpRoute(tester, WorkoutPlanHistoryView.location(42));

    final view = tester.widget<WorkoutPlanHistoryView>(
      find.byType(WorkoutPlanHistoryView),
    );
    expect(view.workoutPlanId, 42);
  });

  testWidgets('invalid plan history IDs show Not Found', (tester) async {
    await pumpRoute(tester, '/workout-plans/not-a-number/history');

    expect(find.byType(NotFoundView), findsOneWidget);
  });

  testWidgets('reminder preferences resolve', (tester) async {
    await pumpRoute(tester, ReminderPreferencesView.routeName);

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
