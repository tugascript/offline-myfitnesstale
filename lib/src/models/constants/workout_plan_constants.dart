import '../enums.dart';
import 'workout_constants.dart';

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

  const WorkoutPlanDayData({
    required this.workouts,
  });
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
  final int totalWeeks;
  final int totalDays;
  final int totalWorkouts;
  final List<WorkoutPlanWeekData> weeks;

  const WorkoutPlanData({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalWorkouts,
    required this.weeks,
  });
}

const WorkoutPlanData kWorkoutPlanData = WorkoutPlanData(
  name: "Standard Upper/Lower Workout Plan",
  description:
      "Workout with Upper and Lower body split.\nIt has the standard volume of 8 sets per muscle per week with 4 workouts per week, 2 upper body and 2 lower body alternating between each.\nIt goes through the 4 phases of the workout plan: Endurance, Hypertrophy, Max Strength and Power, each phase with a duration of 4 weeks for a total of 16 weeks.\nIt is recommended 1 rest day between each pair of workouts, and 2 rest days before the following week workouts.",
  difficulty: Difficulty.beginner,
  totalWeeks: 16,
  totalDays: 64,
  totalWorkouts: 64,
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
