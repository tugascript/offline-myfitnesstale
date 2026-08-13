import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/entitlement_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/workout_plan_state.dart';
import 'package:myfitnesstale/src/cubits/states/workout_state.dart';
import 'package:myfitnesstale/src/cubits/workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/views/workouts/workout_edit_view.dart';
import 'package:myfitnesstale/src/views/workouts/workouts_view.dart';
import 'package:myfitnesstale/src/widgets/workout_plan/editor/create_workout_plan_modal.dart';

class _WorkoutPlanCubit extends WorkoutPlanCubit {
  _WorkoutPlanCubit() {
    emit(WorkoutPlanState.initial().copyWith(createdWorkoutPlansCount: 3));
  }

  @override
  Future<void> countCreatedWorkoutPlans() async {}
}

class _WorkoutCubit extends WorkoutCubit {
  _WorkoutCubit(WorkoutDto workout) {
    emit(WorkoutState.initial().copyWith(selectedWorkout: workout));
  }

  @override
  Future<void> getWorkout(
    int id, {
    int? version,
    bool refresh = false,
  }) async {}
}

void main() {
  const sizes = DataDisplaySizesList(
    viewPadding: 10,
    subtitleFontSize: 14,
    titleFontSize: 20,
    fontSize: 12,
    smallFontSize: 10,
    buttonIconSize: 18,
    buttonSize: 40,
    margins: 16,
    padding: 12,
    spacing: 12,
    inputSpacing: 8,
    elevation: 1,
  );

  testWidgets('plan limit explains unavailability without an upgrade action',
      (tester) async {
    final planCubit = _WorkoutPlanCubit();
    final entitlementCubit = EntitlementCubit();
    addTearDown(planCubit.close);
    addTearDown(entitlementCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutPlanCubit>.value(value: planCubit),
          BlocProvider<EntitlementCubit>.value(value: entitlementCubit),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => CreateWorkoutPlanModal(
              theme: Theme.of(context),
              sizes: sizes,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('unavailable in this build'), findsOneWidget);
    expect(find.textContaining('UPGRADE'), findsNothing);
    expect(find.text('CLOSE'), findsOneWidget);
  });

  testWidgets('advanced workout lock has only a working back action',
      (tester) async {
    const workout = WorkoutDto(
      id: 1,
      name: 'Advanced Workout',
      muscleGroups: <MuscleGroup>{},
      muscles: TargetMuscles(
        primary: <Muscle>{},
        secondary: <Muscle>{},
      ),
      difficulty: Difficulty.advanced,
      version: 1,
      isFavorite: false,
      totalSets: 0,
      totalReps: 0,
      editorType: EditorType.advanced,
      createdBy: CreatedBy.user,
    );
    final workoutCubit = _WorkoutCubit(workout);
    final entitlementCubit = EntitlementCubit();
    addTearDown(workoutCubit.close);
    addTearDown(entitlementCubit.close);

    final router = GoRouter(
      initialLocation: '/workouts/1/edit',
      routes: [
        GoRoute(
          path: WorkoutEditView.routeName,
          builder: (context, state) => const WorkoutEditView(workoutId: 1),
        ),
        GoRoute(
          path: WorkoutsView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Workouts destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutCubit>.value(value: workoutCubit),
          BlocProvider<EntitlementCubit>.value(value: entitlementCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.textContaining('unavailable in this build'), findsOneWidget);
    expect(find.textContaining('Subscribe'), findsNothing);
    expect(find.textContaining('Restore'), findsNothing);
    expect(find.text('Back to Workouts'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to Workouts'));
    await tester.tap(find.text('Back to Workouts'));
    await tester.pumpAndSettle();

    expect(find.text('Workouts destination'), findsOneWidget);
  });
}
