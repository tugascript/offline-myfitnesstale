// Copyright (C) 2026 afonsobarracha
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

import '../../utils/enums.dart';
import './workout_constants.dart';

final class WorkoutPlanWorkoutData {
  final WorkoutTimeOfDay timeOfDay;
  final String workoutName;

  const WorkoutPlanWorkoutData({
    required this.timeOfDay,
    required this.workoutName,
  });
}

final class WorkoutPlanDayData {
  final List<WorkoutPlanWorkoutData> workouts;

  const WorkoutPlanDayData({required this.workouts});
}

final class WorkoutPlanWeekData {
  final int startWeek;
  final int endWeek;
  final WorkoutPhase phase;
  final List<WorkoutPlanDayData> days;

  const WorkoutPlanWeekData({
    required this.startWeek,
    required this.endWeek,
    required this.phase,
    required this.days,
  });
}

final class WorkoutPlanData {
  final String name;
  final String description;
  final Difficulty difficulty;
  final List<WorkoutPlanWeekData> weeks;

  const WorkoutPlanData({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.weeks,
  });
}

const WorkoutPlanData kWorkoutPlanData = WorkoutPlanData(
  name: "Standard Upper/Lower Workout Plan",
  description: "Workout with Upper and Lower body split.\n\nIt has the standard volume of 8 sets per muscle per week with 4 workouts per week, 2 upper body and 2 lower body alternating between each.\n\nIt goes through the 4 phases of the workout plan: Endurance, Hypertrophy, Max Strength and Power, each phase with a duration of 4 weeks for a total of 16 weeks.\n\nIt is recommended 1 rest day between each pair of workouts, and 2 rest days before the following week workouts.",
  difficulty: Difficulty.beginner,
  weeks: [
    WorkoutPlanWeekData(
      startWeek: 1,
      endWeek: 4,
      phase: WorkoutPhase.endurance,
      days: [
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kEnduranceStandardUpperWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kEnduranceStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kEnduranceStandardUpperWorkout2Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kEnduranceStandardLowerWorkout2Name,
            ),
          ],
        ),
      ],
    ),
    WorkoutPlanWeekData(
      startWeek: 5,
      endWeek: 8,
      phase: WorkoutPhase.hypertrophy,
      days: [
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kHypotrophyStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kHypotrophyStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kHypotrophyStandardUpperWorkout2Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kHypotrophyStandardLowerWorkout2Name,
            ),
          ],
        ),
      ],
    ),
    WorkoutPlanWeekData(
      startWeek: 9,
      endWeek: 12,
      phase: WorkoutPhase.maxStrength,
      days: [
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kMaxStrengthStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kMaxStrengthStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kMaxStrengthStandardUpperWorkout2Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kMaxStrengthStandardLowerWorkout2Name,
            ),
          ],
        ),
      ],
    ),
    WorkoutPlanWeekData(
      startWeek: 13,
      endWeek: 16,
      phase: WorkoutPhase.power,
      days: [
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kPowerStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kPowerStandardLowerWorkout1Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kPowerStandardUpperWorkout2Name,
            ),
          ],
        ),
        WorkoutPlanDayData(
          workouts: [
            WorkoutPlanWorkoutData(
              timeOfDay: WorkoutTimeOfDay.anytime,
              workoutName: kPowerStandardLowerWorkout2Name,
            ),
          ],
        ),
      ],
    ),
  ],
);
