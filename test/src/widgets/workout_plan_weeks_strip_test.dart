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
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_day_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_week_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/app_dropdown.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/active/active_workout_plan_schedule_card.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/details/workout_plan_schedule_card.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_phase_badge.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_plan_week_group_selector.dart';
import 'package:myfitnesstale/src/ui/workout_plans/widgets/workout_plan_weeks_strip.dart';

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

  final workoutDay2 = WorkoutPlanDayDto(
    id: 2,
    planVersion: 1,
    day: 2,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [planWorkout],
  );

  final weekBlock1 = WorkoutPlanWeekDto(
    id: 1,
    planVersion: 1,
    startWeek: 1,
    endWeek: 4,
    totalDays: 2,
    totalWorkouts: 2,
    scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
    phase: WorkoutPhase.endurance,
    days: [workoutDay, workoutDay2],
  );

  final weekBlock2 = WorkoutPlanWeekDto(
    id: 2,
    planVersion: 1,
    startWeek: 5,
    endWeek: 8,
    totalDays: 1,
    totalWorkouts: 1,
    scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
    phase: WorkoutPhase.hypertrophy,
    days: [workoutDay],
  );

  group('WorkoutPlanWeeksStrip', () {
    testWidgets('renders all week labels W1 to W4', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanWeeksStrip(
              startWeek: 1,
              endWeek: 4,
              selectedWeek: 1,
              onSelectWeek: (_) {},
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
            ),
          ),
        ),
      );

      for (int i = 1; i <= 4; i++) {
        expect(find.text('W$i'), findsWidgets);
      }
    });

    testWidgets('triggers onSelectWeek callback when tapped', (tester) async {
      int? selectedWeek;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanWeeksStrip(
              startWeek: 1,
              endWeek: 4,
              selectedWeek: 1,
              onSelectWeek: (w) => selectedWeek = w,
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('W3').first);
      await tester.pump();

      expect(selectedWeek, equals(3));
    });

    testWidgets('shows completed icon for completed week', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanWeeksStrip(
              startWeek: 1,
              endWeek: 2,
              selectedWeek: 2,
              onSelectWeek: (_) {},
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              isWeekCompleted: (weekNum) => weekNum == 1,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('WorkoutPlanWeekGroupSelector', () {
    testWidgets('renders single group info cleanly without dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanWeekGroupSelector(
              weekGroups: [weekBlock1],
              selectedGroupIndex: 0,
              onSelectGroup: (_) {},
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
            ),
          ),
        ),
      );

      expect(find.text('Weeks 1 - 4'), findsOneWidget);
      expect(find.byType(WorkoutPhaseBadge), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byType(AppDropdown<int>), findsNothing);
    });

    testWidgets('renders dropdown for multiple week groups', (tester) async {
      int? selectedGroup;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanWeekGroupSelector(
              weekGroups: [weekBlock1, weekBlock2],
              selectedGroupIndex: 0,
              onSelectGroup: (idx) => selectedGroup = idx,
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
            ),
          ),
        ),
      );

      expect(find.text('Weeks 1 - 4'), findsWidgets);
      expect(find.byType(AppDropdown<int>), findsOneWidget);
      expect(find.byType(WorkoutPhaseBadge), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<int?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weeks 5 - 8').last);
      await tester.pumpAndSettle();

      expect(selectedGroup, equals(1));
    });
  });

  group('ActiveWorkoutPlanScheduleCard', () {
    testWidgets('skip actions fit a narrow schedule with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActiveWorkoutPlanScheduleCard(
                sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs),
                theme: ThemeData.light(),
                isDarkTheme: false,
                weeks: [weekBlock1, weekBlock2],
                currentWeekNum: 2,
                relativeDayIndex: 2,
                workoutPlanRecord: WorkoutPlanRecordDto.empty().copyWith(
                  id: 40,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['SKIP WEEK', 'SKIP DAY', 'SKIP']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('CANCEL'));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('W3'));
      await tester.tap(find.text('W3'));
      await tester.pumpAndSettle();
      expect(find.text('SKIP WEEK'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('only current week can be skipped and asks for confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActiveWorkoutPlanScheduleCard(
                sizes: sizes,
                theme: ThemeData.light(),
                isDarkTheme: false,
                weeks: [weekBlock1],
                currentWeekNum: 2,
                relativeDayIndex: 2,
                workoutPlanRecord: WorkoutPlanRecordDto.empty().copyWith(
                  id: 40,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SKIP WEEK'), findsOneWidget);
      await tester.ensureVisible(find.text('SKIP WEEK'));
      await tester.tap(find.text('SKIP WEEK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(
          'Skip all unfinished workouts for Week 2? Completed workouts will be kept.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      for (final week in ['W1', 'W3']) {
        await tester.ensureVisible(find.text(week));
        await tester.tap(find.text(week));
        await tester.pumpAndSettle();
        expect(find.text('SKIP WEEK'), findsNothing);
        expect(find.text('SKIP').hitTestable(), findsNothing);
        expect(find.text('SKIP DAY').hitTestable(), findsNothing);
      }
    });

    testWidgets(
      'swipes and week groups keep skip actions on the current page',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActiveWorkoutPlanScheduleCard(
                  sizes: sizes,
                  theme: ThemeData.light(),
                  isDarkTheme: false,
                  weeks: [weekBlock1, weekBlock2],
                  currentWeekNum: 2,
                  relativeDayIndex: 2,
                  workoutPlanRecord: WorkoutPlanRecordDto.empty().copyWith(
                    id: 40,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final carousel = find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        );
        await tester.drag(carousel, const Offset(-750, 0));
        await tester.pumpAndSettle();
        expect(find.text('SKIP WEEK'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Weeks 5 - 8').last);
        await tester.pumpAndSettle();
        expect(find.text('SKIP WEEK'), findsNothing);
        expect(find.text('SKIP'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Weeks 1 - 4').last);
        await tester.pumpAndSettle();
        expect(find.text('SKIP WEEK').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('initializes to currentWeekNum and relativeDayIndex', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanScheduleCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              weeks: [weekBlock1, weekBlock2],
              currentWeekNum: 2,
              relativeDayIndex: 2,
              workoutPlanRecord: null,
            ),
          ),
        ),
      );

      // Group 1 selected (Weeks 1 - 4)
      expect(find.text('Weeks 1 - 4'), findsWidgets);
      // Week strip W1..W4 rendered
      expect(find.text('W1'), findsWidgets);
      expect(find.text('W2'), findsWidgets);
      expect(find.text('W3'), findsWidgets);
      expect(find.text('W4'), findsWidgets);
      // Day strip D1..D7 rendered for each week page in the carousel
      expect(find.text('D1'), findsWidgets);
      expect(find.text('D2'), findsWidgets);
      // Workout details rendered in carousel
      expect(find.text('Upper Body Blast'), findsWidgets);
    });

    testWidgets('switching week updates carousel scroll and indicators', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanScheduleCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              weeks: [weekBlock1, weekBlock2],
              currentWeekNum: 1,
              relativeDayIndex: 1,
              workoutPlanRecord: null,
            ),
          ),
        ),
      );

      // Tap W3 in the weeks strip
      await tester.tap(find.text('W3').first);
      await tester.pumpAndSettle();

      // Days strip should still be rendered for W3 in carousel
      expect(find.text('D1'), findsWidgets);
      expect(find.text('D2'), findsWidgets);
    });

    testWidgets('swiping carousel changes selected week', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanScheduleCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              weeks: [weekBlock1, weekBlock2],
              currentWeekNum: 1,
              relativeDayIndex: 1,
              workoutPlanRecord: null,
            ),
          ),
        ),
      );

      // Swipe left on carousel content (scroll to W2)
      final carouselScroll = find.byType(SingleChildScrollView).last;
      await tester.drag(carouselScroll, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Carousel has scrolled to next week
      expect(find.text('Weeks 1 - 4'), findsWidgets);
      expect(find.text('W2'), findsWidgets);
    });

    testWidgets('shows skip week button when record exists and week is incomplete', (
      tester,
    ) async {
      final record = WorkoutPlanRecordDto(
        id: 100,
        workoutPlanId: 1,
        workoutPlanVersion: 1,
        status: ProgressStatus.inProgress,
        startedAt: DateTime.now(),
        currentWeek: 1,
        currentDay: 1,
        currentWorkoutPosition: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutPlanScheduleCard(
              sizes: sizes,
              theme: ThemeData.light(),
              isDarkTheme: false,
              weeks: [weekBlock1, weekBlock2],
              currentWeekNum: 1,
              relativeDayIndex: 1,
              workoutPlanRecord: record,
            ),
          ),
        ),
      );

      expect(find.text('SKIP WEEK'), findsOneWidget);
    });

    testWidgets(
      'skipped week causes no overflow and unlocks Week 2 Day 1 and skipped workouts',
      (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final now = DateTime.now();
        final skippedWeek1Record = WorkoutPlanRecordDto(
          id: 100,
          workoutPlanId: 1,
          workoutPlanVersion: 1,
          status: ProgressStatus.inProgress,
          startedAt: now,
          currentWeek: 1,
          currentDay: 1,
          currentWorkoutPosition: 1,
          weeks: [
            WorkoutPlanWeekRecordDto(
              id: 10,
              workoutPlanRecordId: 100,
              workoutPlanWeekId: weekBlock1.id,
              week: 1,
              status: ProgressStatus.skipped,
              completedAt: now,
              days: [
                WorkoutPlanDayRecordDto(
                  id: 11,
                  workoutPlanRecordId: 100,
                  workoutPlanWeekRecordId: 10,
                  workoutPlanDayId: workoutDay.id,
                  week: 1,
                  day: 1,
                  currentWorkoutPosition: 1,
                  status: ProgressStatus.skipped,
                  completedAt: now,
                  workouts: [
                    WorkoutPlanWorkoutRecordDto(
                      id: 12,
                      workoutPlanRecordId: 100,
                      workoutPlanWeekRecordId: 10,
                      workoutPlanDayRecordId: 11,
                      workoutPlanWorkoutId: planWorkout.id,
                      workoutRecordId: 201,
                      position: 1,
                      startedAt: now,
                      status: ProgressStatus.skipped,
                    ),
                  ],
                ),
                WorkoutPlanDayRecordDto(
                  id: 13,
                  workoutPlanRecordId: 100,
                  workoutPlanWeekRecordId: 10,
                  workoutPlanDayId: workoutDay2.id,
                  week: 1,
                  day: 2,
                  currentWorkoutPosition: 1,
                  status: ProgressStatus.skipped,
                  completedAt: now,
                  workouts: [
                    WorkoutPlanWorkoutRecordDto(
                      id: 14,
                      workoutPlanRecordId: 100,
                      workoutPlanWeekRecordId: 10,
                      workoutPlanDayRecordId: 13,
                      workoutPlanWorkoutId: planWorkout.id,
                      workoutRecordId: 202,
                      position: 1,
                      startedAt: now,
                      status: ProgressStatus.skipped,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActiveWorkoutPlanScheduleCard(
                  sizes: sizes,
                  theme: ThemeData.light(),
                  isDarkTheme: false,
                  weeks: [weekBlock1, weekBlock2],
                  currentWeekNum: 1,
                  relativeDayIndex: 1,
                  workoutPlanRecord: skippedWeek1Record,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Advanced to Week 2 Day 1 automatically, with active controls ready
        expect(find.text('TODAY').hitTestable(), findsOneWidget);
        expect(find.text('START').hitTestable(), findsOneWidget);
        expect(find.text('LOG').hitTestable(), findsOneWidget);
        expect(find.text('SKIP WEEK').hitTestable(), findsOneWidget);
        expect(find.text('SKIP DAY').hitTestable(), findsOneWidget);

        // Switching back to skipped Week 1 renders Skipped chip without overflow and still allows Start/Log
        await tester.tap(find.text('W1').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Skipped').hitTestable(), findsOneWidget);
        expect(find.text('START').hitTestable(), findsOneWidget);
        expect(find.text('LOG').hitTestable(), findsOneWidget);
      },
    );

    testWidgets(
      'skipping Day 1 advances current day to Day 2 so it can be started',
      (tester) async {
        final now = DateTime.now();
        final skippedDay1Record = WorkoutPlanRecordDto(
          id: 100,
          workoutPlanId: 1,
          workoutPlanVersion: 1,
          status: ProgressStatus.inProgress,
          startedAt: now,
          currentWeek: 1,
          currentDay: 1,
          currentWorkoutPosition: 1,
          weeks: [
            WorkoutPlanWeekRecordDto(
              id: 10,
              workoutPlanRecordId: 100,
              workoutPlanWeekId: weekBlock1.id,
              week: 1,
              status: ProgressStatus.inProgress,
              days: [
                WorkoutPlanDayRecordDto(
                  id: 11,
                  workoutPlanRecordId: 100,
                  workoutPlanWeekRecordId: 10,
                  workoutPlanDayId: workoutDay.id,
                  week: 1,
                  day: 1,
                  currentWorkoutPosition: 1,
                  status: ProgressStatus.skipped,
                  completedAt: now,
                  workouts: [
                    WorkoutPlanWorkoutRecordDto(
                      id: 12,
                      workoutPlanRecordId: 100,
                      workoutPlanWeekRecordId: 10,
                      workoutPlanDayRecordId: 11,
                      workoutPlanWorkoutId: planWorkout.id,
                      workoutRecordId: 201,
                      position: 1,
                      startedAt: now,
                      status: ProgressStatus.skipped,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActiveWorkoutPlanScheduleCard(
                  sizes: sizes,
                  theme: ThemeData.light(),
                  isDarkTheme: false,
                  weeks: [weekBlock1],
                  currentWeekNum: 1,
                  relativeDayIndex: 1,
                  workoutPlanRecord: skippedDay1Record,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Day 2').hitTestable(), findsOneWidget);
        expect(find.text('TODAY').hitTestable(), findsOneWidget);
        expect(find.text('START').hitTestable(), findsOneWidget);
        expect(find.text('LOG').hitTestable(), findsOneWidget);
      },
    );
  });

  group('WorkoutPlanScheduleCard', () {
    testWidgets(
      'renders schedule with group selector, weeks strip and days strip',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkoutPlanScheduleCard(
                sizes: sizes,
                theme: ThemeData.light(),
                isDarkTheme: false,
                weeks: [weekBlock1, weekBlock2],
              ),
            ),
          ),
        );

        expect(find.text('Weeks 1 - 4'), findsWidgets);
        expect(find.text('W1'), findsWidgets);
        expect(find.text('W2'), findsWidgets);
        expect(find.text('D1'), findsWidgets);
        expect(find.text('Upper Body Blast'), findsWidgets);
      },
    );
  });
}
