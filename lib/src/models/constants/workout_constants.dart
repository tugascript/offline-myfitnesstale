import '../common.dart';
import '../enums.dart';
import 'exercise_constants.dart';

final class WorkoutSetExerciseData {
  final String exerciseName;
  final int minReps;
  final int maxReps;
  final WorkoutSetExerciseDifficulty difficulty;
  final List<String> exerciseOptionsNames;

  const WorkoutSetExerciseData({
    required this.exerciseName,
    required this.minReps,
    required this.maxReps,
    required this.difficulty,
    this.exerciseOptionsNames = const [],
  });
}

final class WorkoutSetData {
  final WorkoutSetType setType;
  final int minSets;
  final int maxSets;
  final int recommendedRestSecs;
  final int maxRestSecs;
  final List<WorkoutSetExerciseData> exercises;

  const WorkoutSetData({
    required this.setType,
    required this.minSets,
    required this.maxSets,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.exercises,
  });
}

final class WorkoutData {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final WorkoutPhase? phase;
  final List<WorkoutSetData> sets;
  const WorkoutData({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    this.phase,
    required this.sets,
  });
}

const String kEnduranceStandardUpperWorkout1Name =
    "Standard Push Focused Endurance Upper Body Workout";
const String kEnduranceStandardLowerWorkout1Name =
    "Standard Quad Focused Endurance Lower Body Workout";
const String kEnduranceStandardUpperWorkout2Name =
    "Standard Pull Focused Endurance Upper Body Workout";
const String kEnduranceStandardLowerWorkout2Name =
    "Standard Hamstring Focused Endurance Lower Body Workout";

const String kHypotrophyStandardUpperWorkout1Name =
    "Standard Push Focused Hypotrophy Upper Body Workout";
const String kHypotrophyStandardLowerWorkout1Name =
    "Standard Quad Focused Hypotrophy Lower Body Workout";
const String kHypotrophyStandardUpperWorkout2Name =
    "Standard Pull Focused Hypotrophy Upper Body Workout";
const String kHypotrophyStandardLowerWorkout2Name =
    "Standard Hamstring Focused Hypotrophy Lower Body Workout";

const String kMaxStrengthStandardUpperWorkout1Name =
    "Standard Push Focused Max Strength Upper Body Workout";
const String kMaxStrengthStandardLowerWorkout1Name =
    "Standard Quad Focused Max Strength Lower Body Workout";
const String kMaxStrengthStandardUpperWorkout2Name =
    "Standard Pull Focused Max Strength Upper Body Workout";
const String kMaxStrengthStandardLowerWorkout2Name =
    "Standard Hamstring Focused Max Strength Lower Body Workout";

const String kPowerStandardUpperWorkout1Name =
    "Standard Push Focused Power Upper Body Workout";
const String kPowerStandardLowerWorkout1Name =
    "Standard Quad Focused Power Lower Body Workout";
const String kPowerStandardUpperWorkout2Name =
    "Standard Pull Focused Power Upper Body Workout";
const String kPowerStandardLowerWorkout2Name =
    "Standard Hamstring Focused Power Lower Body Workout";

const WorkoutData kStandardEnduranceUpperWorkout1 = WorkoutData(
  name: kEnduranceStandardUpperWorkout1Name,
  description:
      "Upper body push focused workout with high reps to build muscular endurance.",
  difficulty: Difficulty.beginner,
  phase: WorkoutPhase.endurance,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kInclineDumbbellChestPressName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kInclineMachineChestPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kOverhandLatPulldownName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kPullUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 120,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableLateralRaisesName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBayesianCableCurlName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableEZBarBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 120,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDumbbellOverheadTricepsExtensionName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kTricepsPushdownName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedCableRowName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kChestSupportedRowMachineName],
        ),
      ],
    ),
  ],
);

const WorkoutData kStandardLowerWorkout1 = WorkoutData(
  name: kEnduranceStandardLowerWorkout1Name,
  description:
      "Lower body quad focused workout with high reps to build muscular endurance",
  difficulty: Difficulty.beginner,
  phase: WorkoutPhase.endurance,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kHackSquatName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kLegPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedLegCurlName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kLyingLegCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableCrunchesName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCrunchMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCaptainsChairLegRaisesName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
  ],
);

const WorkoutData kStandardUpperWorkout2 = WorkoutData(
  name: kEnduranceStandardUpperWorkout2Name,
  description:
      "Upper body pull focused workout with high reps to build muscular endurance",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.endurance,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kUnderhandLatPulldownName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kMachineShoulderPressName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kSeatedDumbbellShoulderPressName,
            kSeatedBarbellShoulderPressName,
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kMachineReverseFlysName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kBentOverDumbbellReverseFlysName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 120,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kMachineChestFlysName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableFlysName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 120,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellPreacherCurlName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kBarbellBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 60,
      maxRestSecs: 120,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableTricepKickbackName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kTricepsPushdownName],
        ),
      ],
    ),
  ],
);

const WorkoutData kStandardLowerWorkout2 = WorkoutData(
  name: kEnduranceStandardLowerWorkout2Name,
  description:
      "Lower body hamstring focused workout with high reps to build muscular endurance",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.endurance,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellRomanianDeadliftName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kDumbbellRomanianDeadliftName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLegExtensionName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLyingLegRaisesName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kCaptainsChairLegRaisesName,
            kHangingLegRaisesName,
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCrunchMachineName,
          minReps: 15,
          maxReps: 20,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableCrunchesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kHypotrophyStandardUpperWorkout1 = WorkoutData(
  name: kHypotrophyStandardUpperWorkout1Name,
  description:
      "Upper body push focused workout with medium reps to build muscular hypertrophy.",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.hypertrophy,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kInclineBarbellChestPressName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kInclineDumbbellChestPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kAssistedPullUpName,
          minReps: 6,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kPullUpName, kWeightedPullUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDumbbellLateralRaisesName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableLateralRaisesName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDumbbellBicepCurlName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableEZBarBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSmithMachineSkullCrushersName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSkullCrushersName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kTBarRowName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kInclineDumbbellRowName],
        ),
      ],
    ),
  ],
);

const WorkoutData kHypotrophyStandardLowerWorkout1 = WorkoutData(
  name: kHypotrophyStandardLowerWorkout1Name,
  description:
      "Lower body quad focused workout with medium reps to build muscular hypertrophy.",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.hypertrophy,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBackSquatName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSmithMachineSquatName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedLegCurlName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kLyingLegCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableCrunchesName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCrunchMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCaptainsChairLegRaisesName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kHangingLegRaisesName, kLyingLegRaisesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kHypotrophyStandardUpperWorkout2 = WorkoutData(
  name: kHypotrophyStandardUpperWorkout2Name,
  description:
      "Upper body pull focused workout with medium reps to build muscular hypertrophy.",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.hypertrophy,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kAssistedChinUpName,
          minReps: 6,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kChinUpName, kWeightedChinUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedDumbbellShoulderPressName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kStandingDumbbellShoulderPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kFacePullsName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kMachineReverseFlysName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kInclineDumbbellChestFlysName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kInclineCableFlysName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kHammerCurlName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableEZBarBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kTricepsPushdownName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableOverheadTricepsExtensionName],
        ),
      ],
    ),
  ],
);

const WorkoutData kHypotrophyStandardLowerWorkout2 = WorkoutData(
  name: kHypotrophyStandardLowerWorkout2Name,
  description:
      "Lower body quad focused workout with medium reps to build muscular hypertrophy.",
  difficulty: Difficulty.intermediate,
  phase: WorkoutPhase.hypertrophy,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellDeadliftName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSmithMachineRomanianDeadliftName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLegExtensionName,
          minReps: 10,
          maxReps: 12,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLyingLegRaisesName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kCaptainsChairLegRaisesName,
            kHangingLegRaisesName,
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 90,
      maxRestSecs: 180,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCrunchMachineName,
          minReps: 12,
          maxReps: 15,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableCrunchesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kMaxStrengthStandardUpperWorkout1 = WorkoutData(
  name: kMaxStrengthStandardUpperWorkout1Name,
  description:
      "Upper body push focused workout with low reps to build maximum strength.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.maxStrength,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellChestPressName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kDumbbellChestPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kWeightedChinUpName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kChinUpName, kAssistedChinUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDumbbellLateralRaisesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableLateralRaisesName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBentOverRowsName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kSingleArmSupportedDumbbellRowName,
            kSeatedCableRowName
          ],
        ),
      ],
    ),
  ],
);

const WorkoutData kMaxStrengthStandardLowerWorkout1 = WorkoutData(
  name: kMaxStrengthStandardLowerWorkout1Name,
  description:
      "Lower body quad focused workout with low reps to build maximum strength.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.maxStrength,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBackSquatName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSmithMachineSquatName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedLegCurlName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kLyingLegCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableCrunchesName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCrunchMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCaptainsChairLegRaisesName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kHangingLegRaisesName, kLyingLegRaisesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kMaxStrengthStandardUpperWorkout2 = WorkoutData(
  name: kMaxStrengthStandardUpperWorkout2Name,
  description:
      "Upper body pull focused workout with low reps to build maximum strength.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.maxStrength,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kWeightedPullUpName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kPullUpName, kAssistedPullUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingBarbellShoulderPressName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kSeatedBarbellShoulderPressName,
            kSmithMachineShoulderPressName
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBicepCurlName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kDumbbellBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDipsName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableTricepKickbackName],
        ),
      ],
    ),
  ],
);

const WorkoutData kMaxStrengthStandardLowerWorkout2 = WorkoutData(
  name: kMaxStrengthStandardLowerWorkout2Name,
  description:
      "Lower body hamstring focused workout with low reps to build maximum strength.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.maxStrength,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellDeadliftName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSmithMachineRomanianDeadliftName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLegExtensionName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLyingLegRaisesName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kHangingLegRaisesName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCrunchMachineName,
          minReps: 8,
          maxReps: 10,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableCrunchesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kPowerStandardUpperWorkout1 = WorkoutData(
  name: kPowerStandardUpperWorkout1Name,
  description:
      "Upper body push focused workout with very low reps to build explosive power.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.power,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellChestPressName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kDumbbellChestPressName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kWeightedChinUpName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kChinUpName, kAssistedChinUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDumbbellLateralRaisesName,
          minReps: 5,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableLateralRaisesName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kPendlayRowsName,
          minReps: 3,
          maxReps: 5,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kBarbellBentOverRowsName],
        ),
      ],
    ),
  ],
);

const WorkoutData kPowerStandardLowerWorkout1 = WorkoutData(
  name: kPowerStandardLowerWorkout1Name,
  description:
      "Lower body quad focused workout with very low reps to build explosive power.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.power,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBackSquatName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSmithMachineSquatName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kSeatedLegCurlName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kLyingLegCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCableCrunchesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCrunchMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCaptainsChairLegRaisesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kHangingLegRaisesName, kLyingLegRaisesName],
        ),
      ],
    ),
  ],
);

const WorkoutData kPowerStandardUpperWorkout2 = WorkoutData(
  name: kPowerStandardUpperWorkout2Name,
  description:
      "Upper body pull focused workout with very low reps to build explosive power.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.power,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kWeightedPullUpName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kPullUpName, kAssistedPullUpName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingBarbellShoulderPressName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kSeatedBarbellShoulderPressName,
            kSmithMachineShoulderPressName
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellBicepCurlName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kDumbbellBicepCurlName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kDipsName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableTricepKickbackName],
        ),
      ],
    ),
  ],
);

const WorkoutData kPowerStandardLowerWorkout2 = WorkoutData(
  name: kPowerStandardLowerWorkout2Name,
  description:
      "Lower body hamstring focused workout with very low reps to build explosive power.",
  difficulty: Difficulty.intermediateAdvanced,
  phase: WorkoutPhase.power,
  sets: [
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kBarbellDeadliftName,
          minReps: 2,
          maxReps: 3,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [
            kBarbellSumoDeadliftName,
            kBarbellRomanianDeadliftName
          ],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLegExtensionName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 2,
      maxSets: 3,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kStandingCalfRaisesName,
          minReps: 4,
          maxReps: 6,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kSeatedCalfMachineName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kLyingLegRaisesName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kHangingLegRaisesName],
        ),
      ],
    ),
    WorkoutSetData(
      setType: WorkoutSetType.standard,
      minSets: 3,
      maxSets: 4,
      recommendedRestSecs: 180,
      maxRestSecs: 300,
      exercises: [
        WorkoutSetExerciseData(
          exerciseName: kCrunchMachineName,
          minReps: 6,
          maxReps: 8,
          difficulty: WorkoutSetExerciseDifficulty(
            value: 2,
            type: WorkoutSetExerciseDifficultyType.rir,
          ),
          exerciseOptionsNames: [kCableCrunchesName],
        ),
      ],
    ),
  ],
);

const List<WorkoutData> kStandardWorkouts = [
  kPowerStandardUpperWorkout1,
  kPowerStandardLowerWorkout1,
  kPowerStandardUpperWorkout2,
  kPowerStandardLowerWorkout2,
  kMaxStrengthStandardUpperWorkout1,
  kMaxStrengthStandardLowerWorkout1,
  kMaxStrengthStandardUpperWorkout2,
  kMaxStrengthStandardLowerWorkout2,
  kStandardEnduranceUpperWorkout1,
  kStandardLowerWorkout1,
  kStandardUpperWorkout2,
  kStandardLowerWorkout2,
  kHypotrophyStandardUpperWorkout1,
  kHypotrophyStandardLowerWorkout1,
  kHypotrophyStandardUpperWorkout2,
  kHypotrophyStandardLowerWorkout2,
];
