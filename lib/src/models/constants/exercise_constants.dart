import '../common.dart';
import '../enums.dart';
import 'equipment_constants.dart';

class ExerciseData {
  final String name;
  final MuscleGroup muscleGroup;
  final TargetMuscles muscles;
  final Set<String> equipments;
  final Difficulty difficulty;

  const ExerciseData({
    required this.name,
    required this.muscleGroup,
    required this.muscles,
    required this.equipments,
    required this.difficulty,
  });
}

const String kBarbellChestPressName = "Barbell Chest Press";
const String kInclineBarbellChestPressName = "Incline Barbell Chest Press";
const String kDumbbellChestPressName = "Dumbbell Chest Press";
const String kInclineDumbbellChestPressName = "Incline Dumbbell Chest Press";
const String kInclineMachineChestPressName = "Incline Machine Chest Press";
const String kMachineChestPressName = "Machine Chest Press";
const String kMachineChestFlysName = "Machine Chest Flys";
const String kCableUnderhandFlysName = "Cable Underhand Flys";
const String kCableFlysName = "Cable Flys";
const String kInclineCableFlysName = "Incline Cable Flys";
const String kStandingBarbellShoulderPressName =
    "Standing Barbell Shoulder Press";
const String kSeatedBarbellShoulderPressName = "Seated Barbell Shoulder Press";
const String kSmithMachineShoulderPressName = "Smith Machine Shoulder Press";
const String kMachineShoulderPressName = "Machine Shoulder Press";
const String kStandingDumbbellShoulderPressName =
    "Standing Dumbbell Shoulder Press";
const String kSeatedDumbbellShoulderPressName =
    "Seated Dumbbell Shoulder Press";
const String kDumbbellLateralRaisesName = "Dumbbell Lateral Raises";
const String kCableLateralRaisesName = "Cable Lateral Raises";
const String kLeaningCableLateralRaiseName = "Leaning Cable Lateral Raise";
const String kCableOverheadTricepsExtensionName =
    "Cable Overhead Triceps Extension";
const String kDumbbellOverheadTricepsExtensionName =
    "Dumbbell Overhead Triceps Extension";
const String kEZBarOverheadTricepsExtensionName =
    "EZ Bar Overhead Triceps Extension";
const String kSkullCrushersName = "Skull Crushers";
const String kTricepsPushdownName = "Triceps Pushdown";
const String kCableTricepKickbackName = "Cable Tricep Kickback";
const String kDipsName = "Dips";
const String kPullUpsName = "Pull ups";
const String kChinUpsName = "Chin ups";
const String kOverhandLatPulldownName = "Overhand Lat Pulldown";
const String kUnderhandLatPulldownName = "Underhand Lat Pulldown";
const String kBarbellBentOverRowsName = "Barbell Bent Over Rows";
const String kSingleArmSupportedDumbbellRowName =
    "Single Arm Supported Dumbbell Row";
const String kInclineDumbbellRowName = "Incline Dumbbell Row";
const String kTBarRowName = "T-Bar Row";
const String kChestSupportedTBarRowName = "Chest Supported T-Bar Row";
const String kChestSupportedRowMachineName = "Chest Supported Row Machine";
const String kSeatedCableRowName = "Seated Cable Row";
const String kFacePullsName = "Face Pulls";
const String kMachineReverseFlysName = "Machine Reverse Flys";
const String kBentOverDumbbellReverseFlysName =
    "Bent Over Dumbbell Reverse Flys";
const String kInclineDumbbellReverseFlysName = "Incline Dumbbell Reverse Flys";
const String kBentOverCableReverseFlysName = "Bent Over Cable Reverse Flys";
const String kBarbellBicepCurlName = "Barbell Bicep Curl";
const String kDumbbellBicepCurlName = "Dumbbell Bicep Curl";
const String kHammerCurlName = "Hammer Curl";
const String kBarbellPreacherCurlName = "Barbell Preacher Curl";
const String kDumbbellPreacherCurlName = "Dumbbell Preacher Curl";
const String kCableEZBarBicepCurlName = "Cable EZ Bar Bicep Curl";
const String kCableDHandleBicepCurlName = "Cable D-Handle Bicep Curl";
const String kBayesianCableCurlName = "Bayesian Cable Curl";
const String kBarbellBackSquatName = "Barbell Back Squat";
const String kBarbellFrontSquatName = "Barbell Front Squat";
const String kSmithMachineSquatName = "Smith Machine Squat";
const String kHackSquatName = "Hack Squat";
const String kLegPressName = "Leg Press";
const String kBarbellDeadliftName = "Barbell Deadlift";
const String kBarbellSumoDeadliftName = "Barbell Sumo Deadlift";
const String kBarbellRomanianDeadliftName = "Barbell Romanian Deadlift";
const String kDumbbellRomanianDeadliftName = "Dumbbell Romanian Deadlift";
const String kSmithMachineRomanianDeadliftName =
    "Smith Machine Romanian Deadlift";
const String kSmithMachineGoodMorningName = "Smith Machine Good Morning";
const String kWalkingLungesName = "Walking Lunges";
const String kLungeName = "Lunge";
const String kSmithMachineElevatedLungeName = "Smith Machine Elevated Lunge";
const String kSeatedLegCurlName = "Seated Leg Curl";
const String kLyingLegCurlName = "Lying Leg Curl";
const String kLegExtensionName = "Leg Extension";
const String kStandingCalfRaisesName = "Standing Calf Raises";
const String kSeatedCalfMachineName = "Seated Calf Machine";
const String kCrunchesName = "Crunches";
const String kCableCrunchesName = "Cable Crunches";
const String kCaptainsChairLegRaisesName = "Captain's Chair Leg Raises";
const String kHangingLegRaisesName = "Hanging Leg Raises";
const String kLyingLegRaisesName = "Lying Leg Raises";
const String kCableWoodchopperName = "Cable Woodchopper";
const String kBackExtensionName = "Back Extension";
const String kBurpeesName = "Burpees";
const String kHipThrustName = "Hip Thrust";
const String kCrunchMachineName = "Crunch Machine";
const String kAssistedPullUpName = "Assisted Pull-up";
const String kAssistedChinUpName = "Assisted Chin-up";
const String kSmithMachineSkullCrushersName = "Smith Machine Skull Crusher";
const String kInclineDumbbellChestFlysName = "Incline Dumbbell Chest Flys";
const String kPullUpName = "Pull-up";
const String kChinUpName = "Chin-up";
const String kWeightedPullUpName = "Weighted Pull-up";
const String kWeightedChinUpName = "Weighted Chin-up";
const String kMuscleUpName = "Muscle-up";
const String kDragonflyName = "Dragonfly";
const String kPlankName = "Plank";
const String kPendlayRowsName = "Pendlay Rows";

const Set<String> kExerciseNames = {
  kBarbellChestPressName,
  kInclineBarbellChestPressName,
  kDumbbellChestPressName,
  kInclineDumbbellChestPressName,
  kInclineMachineChestPressName,
  kMachineChestPressName,
  kMachineChestFlysName,
  kCableUnderhandFlysName,
  kCableFlysName,
  kInclineCableFlysName,
  kStandingBarbellShoulderPressName,
  kSeatedBarbellShoulderPressName,
  kSmithMachineShoulderPressName,
  kMachineShoulderPressName,
  kStandingDumbbellShoulderPressName,
  kSeatedDumbbellShoulderPressName,
  kDumbbellLateralRaisesName,
  kCableLateralRaisesName,
  kLeaningCableLateralRaiseName,
  kCableOverheadTricepsExtensionName,
  kDumbbellOverheadTricepsExtensionName,
  kEZBarOverheadTricepsExtensionName,
  kSkullCrushersName,
  kTricepsPushdownName,
  kCableTricepKickbackName,
  kDipsName,
  kPullUpsName,
  kChinUpsName,
  kOverhandLatPulldownName,
  kUnderhandLatPulldownName,
  kPendlayRowsName,
  kBarbellBentOverRowsName,
  kSingleArmSupportedDumbbellRowName,
  kInclineDumbbellRowName,
  kTBarRowName,
  kChestSupportedTBarRowName,
  kChestSupportedRowMachineName,
  kSeatedCableRowName,
  kFacePullsName,
  kMachineReverseFlysName,
  kBentOverDumbbellReverseFlysName,
  kInclineDumbbellReverseFlysName,
  kBentOverCableReverseFlysName,
  kBarbellBicepCurlName,
  kDumbbellBicepCurlName,
  kHammerCurlName,
  kBarbellPreacherCurlName,
  kDumbbellPreacherCurlName,
  kCableEZBarBicepCurlName,
  kCableDHandleBicepCurlName,
  kBayesianCableCurlName,
  kBarbellBackSquatName,
  kBarbellFrontSquatName,
  kSmithMachineSquatName,
  kHackSquatName,
  kLegPressName,
  kBarbellDeadliftName,
  kBarbellSumoDeadliftName,
  kBarbellRomanianDeadliftName,
  kDumbbellRomanianDeadliftName,
  kSmithMachineRomanianDeadliftName,
  kSmithMachineGoodMorningName,
  kWalkingLungesName,
  kLungeName,
  kSmithMachineElevatedLungeName,
  kSeatedLegCurlName,
  kLyingLegCurlName,
  kLegExtensionName,
  kStandingCalfRaisesName,
  kSeatedCalfMachineName,
  kCrunchesName,
  kCableCrunchesName,
  kCaptainsChairLegRaisesName,
  kHangingLegRaisesName,
  kLyingLegRaisesName,
  kCableWoodchopperName,
  kBackExtensionName,
  kBurpeesName,
  kHipThrustName,
  kCrunchMachineName,
  kAssistedPullUpName,
  kAssistedChinUpName,
  kSmithMachineSkullCrushersName,
  kInclineDumbbellChestFlysName,
  kWeightedPullUpName,
  kWeightedChinUpName,
};

const Set<ExerciseData> kInitialExercises = <ExerciseData>{
  ExerciseData(
    name: kBarbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.shoulders,
        Muscle.frontDelts,
      },
    ),
    equipments: {kBarbellName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kInclineBarbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kBarbellName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kDumbbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kInclineDumbbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kInclineMachineChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kMachineChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kMachineChestFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCableUnderhandFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.upperChest,
      },
      secondary: {},
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kCableFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {},
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kInclineCableFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.upperChest,
      },
      secondary: {
        Muscle.chest,
      },
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kStandingBarbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kSeatedBarbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kBarbellName, kPowerRackName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kSmithMachineShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kSmithMachineName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kMachineShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kStandingDumbbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSeatedDumbbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondary: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kDumbbellLateralRaisesName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.sideDelts,
      },
      secondary: {
        Muscle.shoulders,
      },
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCableLateralRaisesName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.sideDelts,
      },
      secondary: {
        Muscle.shoulders,
      },
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kLeaningCableLateralRaiseName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.sideDelts,
      },
      secondary: {
        Muscle.shoulders,
      },
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kCableOverheadTricepsExtensionName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {
      kCableName,
      kEZBarAttachmentName,
      kTricepsRopeAttachmentName,
    },
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kDumbbellOverheadTricepsExtensionName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kEZBarOverheadTricepsExtensionName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {kEZBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSkullCrushersName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {kBarbellName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kTricepsPushdownName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {
      kCableName,
      kEZBarAttachmentName,
      kTricepsRopeAttachmentName,
    },
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kDipsName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
      },
      secondary: {
        Muscle.triceps,
      },
    ),
    equipments: {kDipStationName, kBodyweightName, kWeightBeltName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kCableTricepKickbackName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {
        Muscle.triceps,
      },
      secondary: {},
    ),
    equipments: {kCableName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kPullUpsName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.lats,
      },
      secondary: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kPullUpBarName, kBodyweightName},
    difficulty: Difficulty.intermediateAdvanced,
  ),
  ExerciseData(
    name: kChinUpsName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.lats,
      },
      secondary: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kPullUpBarName, kBodyweightName, kWeightBeltName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kOverhandLatPulldownName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.lats,
      },
      secondary: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kLatPulldownBarName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kUnderhandLatPulldownName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.lats,
      },
      secondary: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kLatPulldownBarName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kPendlayRowsName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lowerBack,
        Muscle.lats,
      },
    ),
    equipments: {kBarbellName},
    difficulty: Difficulty.intermediateAdvanced,
  ),
  ExerciseData(
    name: kBarbellBentOverRowsName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lowerBack,
        Muscle.lats,
      },
    ),
    equipments: {kBarbellName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kSingleArmSupportedDumbbellRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kInclineDumbbellRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.lats,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kTBarRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lowerBack,
        Muscle.lats,
      },
    ),
    equipments: {kBarbellName, kDoubleDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kChestSupportedTBarRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lowerBack,
        Muscle.lats,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kChestSupportedRowMachineName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lats,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kSeatedCableRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rhomboids,
        Muscle.middleTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lats,
      },
    ),
    equipments: {kCableName, kDoubleDHandleName, kWideLatBarName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kFacePullsName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rearDelts,
        Muscle.upperTrapezius,
      },
      secondary: {
        Muscle.trapezius,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kTricepsRopeAttachmentName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kMachineReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rearDelts,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBentOverDumbbellReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rearDelts,
      },
      secondary: {},
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kInclineDumbbellReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rearDelts,
      },
      secondary: {},
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kBentOverCableReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.rearDelts,
      },
      secondary: {},
    ),
    equipments: {kCableName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBarbellBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName, kEZBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kDumbbellBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kHammerCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.brachialis,
      },
      secondary: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBarbellPreacherCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kDumbbellPreacherCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kCableEZBarBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {
      kCableName,
      kEZBarAttachmentName,
    },
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCableDHandleBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBayesianCableCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {
        Muscle.biceps,
      },
      secondary: {},
    ),
    equipments: {kCableName, kDHandleName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kBarbellBackSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kBarbellFrontSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
        Muscle.adductors,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
    difficulty: Difficulty.intermediateAdvanced,
  ),
  ExerciseData(
    name: kSmithMachineSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
      },
    ),
    equipments: {kSmithMachineName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kHackSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kLegPressName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
      },
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBarbellDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kBarbellSumoDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.quadriceps,
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kBarbellRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
    difficulty: Difficulty.intermediate,
  ),
  ExerciseData(
    name: kDumbbellRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSmithMachineRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kSmithMachineName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSmithMachineGoodMorningName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondary: {
        Muscle.lowerBack,
      },
    ),
    equipments: {kSmithMachineName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kWalkingLungesName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kLungeName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kSmithMachineElevatedLungeName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondary: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kSmithMachineName, kStepperName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSeatedLegCurlName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kLyingLegCurlName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.hamstrings,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kLegExtensionName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.quadriceps,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kStandingCalfRaisesName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.calves,
      },
      secondary: {},
    ),
    equipments: {kBodyweightName, kMachineName, kStepperName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSeatedCalfMachineName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.calves,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCrunchesName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.abdominals,
        Muscle.upperAbs,
      },
      secondary: {},
    ),
    equipments: {kBodyweightName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCableCrunchesName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.abdominals,
        Muscle.upperAbs,
      },
      secondary: {},
    ),
    equipments: {kCableName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kCaptainsChairLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.lowerAbs,
      },
      secondary: {
        Muscle.abdominals,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kHangingLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.lowerAbs,
      },
      secondary: {
        Muscle.abdominals,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kLyingLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.lowerAbs,
      },
      secondary: {
        Muscle.abdominals,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kCableWoodchopperName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.obliques,
      },
      secondary: {},
    ),
    equipments: {kCableName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kBackExtensionName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.lowerBack,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kBurpeesName,
    muscleGroup: MuscleGroup.full,
    muscles: TargetMuscles(
      primary: {
        Muscle.chest,
        Muscle.quadriceps,
      },
      secondary: {
        Muscle.frontDelts,
        Muscle.triceps,
        Muscle.glutes,
      },
    ),
    equipments: {kBodyweightName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kAssistedPullUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kMachineName, kPullUpBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kAssistedChinUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kMachineName, kPullUpBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kSmithMachineSkullCrushersName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {Muscle.triceps},
      secondary: {},
    ),
    equipments: {kSmithMachineName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kInclineDumbbellChestFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(
      primary: {Muscle.upperChest},
      secondary: {Muscle.chest},
    ),
    equipments: {kDumbbellsName, kBenchName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kWeightedPullUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName, kWeightBeltName},
    difficulty: Difficulty.intermediateAdvanced,
  ),
  ExerciseData(
    name: kWeightedChinUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName, kWeightBeltName},
    difficulty: Difficulty.intermediateAdvanced,
  ),
  ExerciseData(
    name: kHipThrustName,
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(
      primary: {
        Muscle.glutes,
      },
      secondary: {
        Muscle.hamstrings,
        Muscle.quadriceps,
      },
    ),
    equipments: {kBarbellName, kBenchName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kCrunchMachineName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {
        Muscle.abdominals,
      },
      secondary: {},
    ),
    equipments: {kMachineName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kPlankName,
    muscleGroup: MuscleGroup.core,
    muscles: TargetMuscles(
      primary: {Muscle.abdominals},
      secondary: {},
    ),
    equipments: {kBodyweightName},
    difficulty: Difficulty.beginner,
  ),
  ExerciseData(
    name: kMuscleUpName,
    muscleGroup: MuscleGroup.full,
    muscles: TargetMuscles(
      primary: {
        Muscle.lats,
        Muscle.chest,
      },
      secondary: {
        Muscle.forearms,
        Muscle.biceps,
        Muscle.triceps,
      },
    ),
    equipments: {kBodyweightName},
    difficulty: Difficulty.advanced,
  ),
  ExerciseData(
    name: kPullUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kChinUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(
      primary: {Muscle.lats},
      secondary: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
  ExerciseData(
    name: kDragonflyName,
    muscleGroup: MuscleGroup.full,
    muscles: TargetMuscles(
      primary: {Muscle.obliques},
      secondary: {Muscle.abdominals},
    ),
    equipments: {kBodyweightName},
    difficulty: Difficulty.beginnerIntermediate,
  ),
};
