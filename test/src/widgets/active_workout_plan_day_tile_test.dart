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
          ),
        ),
      ),
    );
  }

  testWidgets('missed plan workout offers live and manual recording', (
    tester,
  ) async {
    await tester.pumpWidget(harness(status: DayProgressStatus.past));

    expect(find.text('MISSED'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
  });

  testWidgets('completed plan workout shows completion instead of actions', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      harness(
        status: DayProgressStatus.past,
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
    expect(find.text('Log'), findsNothing);
    expect(find.text('Start'), findsNothing);
  });
}
