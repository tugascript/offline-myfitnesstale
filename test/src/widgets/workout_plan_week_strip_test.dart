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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_day_tile.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_week_card.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_plan_week_strip.dart';

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
    id: 1,
    name: 'Upper Body Blast',
    version: 1,
    muscleGroups: const {MuscleGroup.push},
    muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.beginner,
    isFavorite: false,
    totalSets: 3,
    totalReps: 30,
    editorType: EditorType.basic,
    createdBy: CreatedBy.system,
  );

  final planWorkout = WorkoutPlanWorkoutDto(
    id: 1,
    planVersion: 1,
    position: 1,
    workoutId: workout.id,
    workout: workout,
  );

  final workoutDay = WorkoutPlanDayDto(
    id: 1,
    planVersion: 1,
    day: 1,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [planWorkout],
  );

  final restDay = WorkoutPlanDayDto(
    id: 2,
    planVersion: 1,
    day: 2,
    totalWorkouts: 0,
    isRestDay: true,
  );

  Widget buildStripHarness({
    required List<WorkoutPlanDayDto> days,
    required int selectedDay,
    required ValueChanged<int> onSelectDay,
    DayProgressStatus? Function(int dayNum)? getDayProgressStatus,
    bool Function(int dayNum)? isDayCompleted,
    bool Function(int dayNum)? isDayMissed,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            body: WorkoutPlanWeekStrip(
              days: days,
              selectedDay: selectedDay,
              onSelectDay: onSelectDay,
              sizes: sizes,
              theme: theme,
              isDarkTheme: false,
              getDayProgressStatus: getDayProgressStatus,
              isDayCompleted: isDayCompleted,
              isDayMissed: isDayMissed,
            ),
          );
        },
      ),
    );
  }

  group('WorkoutPlanWeekStrip', () {
    testWidgets('renders all 7 day labels D1 to D7', (tester) async {
      await tester.pumpWidget(
        buildStripHarness(
          days: [workoutDay, restDay],
          selectedDay: 1,
          onSelectDay: (_) {},
        ),
      );

      for (int i = 1; i <= 7; i++) {
        expect(find.text('D$i'), findsOneWidget);
      }
    });

    testWidgets('renders workout, rest, and empty cell states', (tester) async {
      await tester.pumpWidget(
        buildStripHarness(
          days: [workoutDay, restDay], // days 3..7 are missing
          selectedDay: 1,
          onSelectDay: (_) {},
        ),
      );

      // Day 1 has 1 workout with fitness icon
      expect(find.text(' 1'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      // Day 2 has snooze icon for rest
      expect(find.byIcon(Icons.snooze), findsOneWidget);
      // Days 3..7 have hollow '—' (5 missing days)
      expect(find.text('—'), findsNWidgets(5));
    });

    testWidgets('shows completed icon for completed day', (tester) async {
      await tester.pumpWidget(
        buildStripHarness(
          days: [workoutDay],
          selectedDay: 1,
          onSelectDay: (_) {},
          isDayCompleted: (dayNum) => dayNum == 1,
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('triggers onSelectDay callback when a cell is tapped', (
      tester,
    ) async {
      int tapped = 0;
      await tester.pumpWidget(
        buildStripHarness(
          days: [workoutDay, restDay],
          selectedDay: 1,
          onSelectDay: (dayNum) => tapped = dayNum,
        ),
      );

      await tester.tap(find.text('D2'));
      expect(tapped, 2);

      await tester.tap(find.text('D4'));
      expect(tapped, 4);
    });
  });

  group('ActiveWorkoutPlanWeekCard', () {
    final week = WorkoutPlanWeekDto(
      id: 1,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      totalDays: 2,
      totalWorkouts: 1,
      scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
      phase: WorkoutPhase.hypertrophy,
      days: [workoutDay, restDay],
    );

    testWidgets('defaults selection to relativeDayIndex on current week', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanWeekCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              week: week,
              weekNumber: 1,
              currentWeekNum: 1,
              relativeDayIndex: 2,
              workoutPlanRecord: null,
            ),
          ),
        ),
      );

      // Week 1 is auto-expanded because currentWeekNum == weekNumber
      expect(find.byType(WorkoutPlanWeekStrip), findsOneWidget);
      // Selected day 2 is Rest Day
      expect(find.text('Day 2'), findsWidgets);
      expect(find.text('Rest Day'), findsOneWidget);
      // Phase badge is displayed
      expect(find.text('Hypertrophy'), findsOneWidget);
    });

    testWidgets('switching selected day updates detail panel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanWeekCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              week: week,
              weekNumber: 1,
              currentWeekNum: 1,
              relativeDayIndex: 1,
              workoutPlanRecord: null,
            ),
          ),
        ),
      );

      // Initially day 1 is selected
      expect(find.text('Upper Body Blast'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);

      // Tap D2 (rest day)
      await tester.tap(find.text('D2'));
      await tester.pumpAndSettle();

      expect(find.text('Rest Day'), findsOneWidget);
      expect(find.text('Upper Body Blast'), findsNothing);

      // Tap D3 (empty / unscheduled day)
      await tester.tap(find.text('D3'));
      await tester.pumpAndSettle();

      expect(find.text('No workout scheduled for Day 3'), findsOneWidget);
    });
  });
}
