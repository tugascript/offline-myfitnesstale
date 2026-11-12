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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_day_tile.dart';

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

  final workout = WorkoutDto(
    id: 10,
    name: 'Upper body',
    version: 2,
    muscleGroups: const {MuscleGroup.push},
    muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.beginner,
    isFavorite: false,
    totalSets: 3,
    totalReps: 24,
    editorType: EditorType.basic,
    createdBy: CreatedBy.user,
  );
  late final planWorkout = WorkoutPlanWorkoutDto(
    id: 20,
    planVersion: 1,
    position: 1,
    workoutId: workout.id,
    workout: workout,
  );
  late final day = WorkoutPlanDayDto(
    id: 30,
    planVersion: 1,
    day: 2,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [planWorkout],
  );

  Widget harness({
    required DayProgressStatus status,
    List<WorkoutPlanWorkoutRecordDto> records = const [],
    ValueChanged<WorkoutPlanWorkoutDto>? onSkipWorkout,
    VoidCallback? onSkipDay,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ActiveWorkoutPlanDayTile(
            sizes: sizes,
            theme: Theme.of(context),
            isDarkTheme: false,
            day: day,
            status: status,
            week: 1,
            workoutPlanRecordId: 40,
            workoutRecords: records,
            onSkipWorkout: onSkipWorkout,
            onSkipDay: onSkipDay,
          ),
        ),
      ),
    );
  }

  testWidgets('missed plan workout offers live and manual recording', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        status: DayProgressStatus.past,
        onSkipWorkout: (_) {},
        onSkipDay: () {},
      ),
    );

    expect(find.text('MISSED'), findsOneWidget);
    expect(find.text('LOG'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('SKIP DAY'), findsNothing);
    expect(find.text('Completed'), findsNothing);
  });

  for (final action in ['SKIP', 'SKIP DAY']) {
    testWidgets('current day $action requires confirmation', (tester) async {
      var skippedWorkouts = 0;
      var skippedDays = 0;
      await tester.pumpWidget(
        harness(
          status: DayProgressStatus.current,
          onSkipWorkout: (_) => skippedWorkouts++,
          onSkipDay: () => skippedDays++,
        ),
      );

      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(skippedWorkouts, 0);
      expect(skippedDays, 0);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(skippedWorkouts, 0);
      expect(skippedDays, 0);

      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.text(
                action == 'SKIP' ? 'SKIP WORKOUT' : 'SKIP DAY',
              ),
            )
            .last,
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(skippedWorkouts, action == 'SKIP' ? 1 : 0);
      expect(skippedDays, action == 'SKIP DAY' ? 1 : 0);
    });
  }

  testWidgets('future workouts and days offer Start/Log and cannot be skipped', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        status: DayProgressStatus.future,
        onSkipWorkout: (_) {},
        onSkipDay: () {},
      ),
    );
    expect(find.text('LOG'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('SKIP DAY'), findsNothing);
  });

  testWidgets('completed plan workout shows completion instead of actions', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      harness(
        status: DayProgressStatus.past,
        onSkipWorkout: (_) {},
        onSkipDay: () {},
        records: [
          WorkoutPlanWorkoutRecordDto(
            id: 50,
            workoutPlanRecordId: 40,
            workoutPlanWeekRecordId: 41,
            workoutPlanDayRecordId: 42,
            workoutPlanWorkoutId: planWorkout.id,
            workoutRecordId: 60,
            position: 1,
            startedAt: now.subtract(const Duration(hours: 1)),
            status: ProgressStatus.completed,
            completedAt: now,
          ),
        ],
      ),
    );

    expect(find.text('MISSED'), findsNothing);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('LOG'), findsNothing);
    expect(find.text('START'), findsNothing);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('SKIP DAY'), findsNothing);
  });

  testWidgets(
    'skipped plan workout shows skipped chip and still allows Start and Log',
    (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        harness(
          status: DayProgressStatus.current,
          onSkipWorkout: (_) {},
          onSkipDay: () {},
          records: [
            WorkoutPlanWorkoutRecordDto(
              id: 50,
              workoutPlanRecordId: 40,
              workoutPlanWeekRecordId: 41,
              workoutPlanDayRecordId: 42,
              workoutPlanWorkoutId: planWorkout.id,
              workoutRecordId: 60,
              position: 1,
              startedAt: now.subtract(const Duration(hours: 1)),
              status: ProgressStatus.skipped,
            ),
          ],
        ),
      );

      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('LOG'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.text('SKIP'), findsNothing);
      expect(find.text('SKIP DAY'), findsNothing);
    },
  );

  testWidgets('past rest day does not show MISSED badge', (tester) async {
    const restDay = WorkoutPlanDayDto(
      id: 31,
      planVersion: 1,
      day: 2,
      totalWorkouts: 0,
      isRestDay: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ActiveWorkoutPlanDayTile(
              sizes: sizes,
              theme: Theme.of(context),
              isDarkTheme: false,
              day: restDay,
              status: DayProgressStatus.past,
              week: 1,
              workoutPlanRecordId: 40,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rest Day'), findsOneWidget);
    expect(find.text('MISSED'), findsNothing);
  });
}
