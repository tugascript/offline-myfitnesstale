import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_day_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_week_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/widgets/workout_plan/editor/weeks/workout_plan_weeks_editor.dart';

void main() {
  Future<WorkoutPlanWeekDto> createWeekDto({
    int weekId = 1,
    int dayId = 1,
    int planWorkoutId = 1,
    int workoutId = 1,
    String workoutName = 'Workout',
    int startWeek = 1,
    int endWeek = 1,
    bool isRestDay = false,
    List<WorkoutPlanWorkoutDto>? workouts,
  }) async {
    final workoutDto = WorkoutDto(
      id: workoutId,
      name: workoutName,
      muscleGroups: const {},
      muscles: const {},
      difficulty: Difficulty.beginner,
      isFavorite: false,
      totalSets: 0,
      totalReps: 0,
      editorType: EditorType.basic,
      createdBy: CreatedBy.user,
    );

    final effectiveWorkouts = workouts ??
        [
          WorkoutPlanWorkoutDto(
            id: planWorkoutId,
            planVersion: 1,
            position: 1,
            workoutId: workoutId,
            workout: workoutDto,
          ),
        ];

    return WorkoutPlanWeekDto(
      id: weekId,
      planVersion: 1,
      startWeek: startWeek,
      endWeek: endWeek,
      totalDays: isRestDay ? 0 : 1,
      totalWorkouts: isRestDay ? 0 : effectiveWorkouts.length,
      scheduleMode: WorkoutPlanWeekScheduleMode.manual,
      days: [
        WorkoutPlanDayDto(
          id: dayId,
          planVersion: 1,
          day: 1,
          totalWorkouts: isRestDay ? 0 : effectiveWorkouts.length,
          isRestDay: isRestDay,
          planWorkouts: isRestDay ? [] : effectiveWorkouts,
        ),
      ],
    );
  }

  Widget buildHarness({
    required WorkoutPlanCubit cubit,
    required int workoutPlanId,
    required int currentVersion,
    required List<WorkoutPlanWeekDto> initialWeeks,
  }) {
    const sizes = DataDisplaySizesList(
      subtitleFontSize: 14,
      titleFountSize: 20,
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

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: Builder(builder: (context) {
            return WorkoutPlanWeeksEditor(
              theme: Theme.of(context),
              sizes: sizes,
              workoutPlanId: workoutPlanId,
              currentVersion: currentVersion,
              initialWeeks: initialWeeks,
            );
          }),
        ),
      ),
    );
  }

  testWidgets('renders initial structure from initialWeeks', (tester) async {
    final cubit = WorkoutPlanCubit();
    final week = await createWeekDto();

    await tester.pumpWidget(buildHarness(
      cubit: cubit,
      workoutPlanId: 1,
      currentVersion: 1,
      initialWeeks: [week],
    ));

    expect(find.text('Week Block 1'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('invalid structure blocks save with validation message',
      (tester) async {
    final cubit = WorkoutPlanCubit();
    final invalidWeek = await createWeekDto(
      isRestDay: false,
      workouts: [],
    );

    await tester.pumpWidget(buildHarness(
      cubit: cubit,
      workoutPlanId: 1,
      currentVersion: 1,
      initialWeeks: [invalidWeek],
    ));

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(
      find.text('Workout days must include between 1 and 3 workouts'),
      findsOneWidget,
    );

    await cubit.close();
  });

  testWidgets('no-op save shows no structural changes message', (tester) async {
    final cubit = WorkoutPlanCubit();
    final week = await createWeekDto();

    await tester.pumpWidget(buildHarness(
      cubit: cubit,
      workoutPlanId: 1,
      currentVersion: 1,
      initialWeeks: [week],
    ));

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('No structural changes to save.'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('cancel resets local edits to baseline', (tester) async {
    final cubit = WorkoutPlanCubit();
    final week = await createWeekDto();

    await tester.pumpWidget(buildHarness(
      cubit: cubit,
      workoutPlanId: 1,
      currentVersion: 1,
      initialWeeks: [week],
    ));

    final endWeekField = find.byType(TextFormField).at(1);

    await tester.enterText(endWeekField, '2');
    await tester.pump();

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('No structural changes to save.'), findsOneWidget);

    await cubit.close();
  });
}
