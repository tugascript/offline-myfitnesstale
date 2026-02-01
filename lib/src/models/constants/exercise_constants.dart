import '../enums.dart';
import '../exercise_model.dart';
import 'equipment_constants.dart';

class ExerciseData {
  final String name;
  final MuscleGroup muscleGroup;
  final ExerciseMuscles muscles;
  final Set<String> equipments;

  const ExerciseData({
    required this.name,
    required this.muscleGroup,
    required this.muscles,
    required this.equipments,
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
const String kAssistedChinUpName = "Assisted Chin Up";
const String kSmithMachineSkullCrushersName = "Smith Machine Skull Crusher";
const String kInclineDumbbellChestFlysName = "Incline Dumbbell Chest Flys";
const String kWeightedPullUpName = "Weighted Pull-up";
const String kWeightedChinUpName = "Weighted Chin Up";
const String kPendlayRowsName = "Pendlay Rows";

const List<String> kExerciseNames = [
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
];

const Set<ExerciseData> kInitialExercises = <ExerciseData>{
  ExerciseData(
    name: kBarbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.shoulders,
        Muscle.frontDelts,
      },
    ),
    equipments: {kBarbellName, kBenchName},
  ),
  ExerciseData(
    name: kInclineBarbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kBarbellName, kBenchName},
  ),
  ExerciseData(
    name: kDumbbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kInclineDumbbellChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kInclineMachineChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.upperChest,
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kMachineChestPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
        Muscle.frontDelts,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kMachineChestFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kCableUnderhandFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.upperChest,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kCableFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kInclineCableFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.upperChest,
      },
      secondaryMuscles: {
        Muscle.chest,
      },
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kStandingBarbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
  ),
  ExerciseData(
    name: kSeatedBarbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kBarbellName, kPowerRackName, kBenchName},
  ),
  ExerciseData(
    name: kSmithMachineShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kSmithMachineName, kBenchName},
  ),
  ExerciseData(
    name: kMachineShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kStandingDumbbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kSeatedDumbbellShoulderPressName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.shoulders,
        Muscle.frontDelts,
      },
      secondaryMuscles: {
        Muscle.sideDelts,
        Muscle.triceps,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kDumbbellLateralRaisesName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.sideDelts,
        Muscle.shoulders,
      },
      secondaryMuscles: {},
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kCableLateralRaisesName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.sideDelts,
        Muscle.shoulders,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kLeaningCableLateralRaiseName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.sideDelts,
        Muscle.shoulders,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kCableOverheadTricepsExtensionName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.triceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kEZBarName},
  ),
  ExerciseData(
    name: kDumbbellOverheadTricepsExtensionName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.triceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kSkullCrushersName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.triceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kBarbellName, kBenchName},
  ),
  ExerciseData(
    name: kTricepsPushdownName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.triceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName, kEZBarName},
  ),
  ExerciseData(
    name: kDipsName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
      },
      secondaryMuscles: {
        Muscle.triceps,
      },
    ),
    equipments: {kDipStationName, kBodyweightName, kWeightBeltName},
  ),
  ExerciseData(
    name: kCableTricepKickbackName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.triceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName},
  ),
  ExerciseData(
    name: kPullUpsName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kPullUpBarName, kBodyweightName},
  ),
  ExerciseData(
    name: kChinUpsName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kPullUpBarName, kBodyweightName, kWeightBeltName},
  ),
  ExerciseData(
    name: kOverhandLatPulldownName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kLatPulldownBarName},
  ),
  ExerciseData(
    name: kUnderhandLatPulldownName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kLatPulldownBarName},
  ),
  ExerciseData(
    name: kPendlayRowsName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
        Muscle.lowerBack,
      },
    ),
    equipments: {kBarbellName},
  ),
  ExerciseData(
    name: kBarbellBentOverRowsName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
  ),
  ExerciseData(
    name: kSingleArmSupportedDumbbellRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kInclineDumbbellRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kTBarRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName, kDoubleDHandleName},
  ),
  ExerciseData(
    name: kChestSupportedTBarRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kChestSupportedRowMachineName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kSeatedCableRowName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rhomboids,
        Muscle.lats,
      },
      secondaryMuscles: {
        Muscle.traps,
        Muscle.rearDelts,
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kDoubleDHandleName, kWideLatBarName},
  ),
  ExerciseData(
    name: kFacePullsName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rearDelts,
        Muscle.rhomboids,
        Muscle.traps,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kTricepsRopeAttachmentName},
  ),
  ExerciseData(
    name: kMachineReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rearDelts,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kBentOverDumbbellReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rearDelts,
      },
      secondaryMuscles: {},
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kInclineDumbbellReverseFlysName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.rearDelts,
      },
      secondaryMuscles: {},
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kBarbellBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName, kEZBarName},
  ),
  ExerciseData(
    name: kDumbbellBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kHammerCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.brachialis,
      },
      secondaryMuscles: {
        Muscle.biceps,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kBarbellPreacherCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName, kBenchName},
  ),
  ExerciseData(
    name: kDumbbellPreacherCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kCableEZBarBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kEZBarName},
  ),
  ExerciseData(
    name: kCableDHandleBicepCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kBayesianCableCurlName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.biceps,
      },
      secondaryMuscles: {
        Muscle.forearms,
      },
    ),
    equipments: {kCableName, kDHandleName},
  ),
  ExerciseData(
    name: kBarbellBackSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
  ),
  ExerciseData(
    name: kBarbellFrontSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
        Muscle.adductors,
      },
    ),
    equipments: {kBarbellName, kPowerRackName},
  ),
  ExerciseData(
    name: kSmithMachineSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
      },
    ),
    equipments: {kSmithMachineName},
  ),
  ExerciseData(
    name: kHackSquatName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kLegPressName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
      },
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kBarbellDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
  ),
  ExerciseData(
    name: kBarbellSumoDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.quadriceps,
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
  ),
  ExerciseData(
    name: kBarbellRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kBarbellName},
  ),
  ExerciseData(
    name: kDumbbellRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kDumbbellsName},
  ),
  ExerciseData(
    name: kSmithMachineRomanianDeadliftName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
        Muscle.forearms,
      },
    ),
    equipments: {kSmithMachineName},
  ),
  ExerciseData(
    name: kSmithMachineGoodMorningName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.lowerBack,
      },
    ),
    equipments: {kSmithMachineName},
  ),
  ExerciseData(
    name: kWalkingLungesName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kDumbbellsName},
  ),
  ExerciseData(
    name: kLungeName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kDumbbellsName},
  ),
  ExerciseData(
    name: kSmithMachineElevatedLungeName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
        Muscle.glutes,
      },
      secondaryMuscles: {
        Muscle.adductors,
        Muscle.forearms,
      },
    ),
    equipments: {kSmithMachineName, kStepperName},
  ),
  ExerciseData(
    name: kSeatedLegCurlName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kLyingLegCurlName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.hamstrings,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kLegExtensionName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.quadriceps,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kStandingCalfRaisesName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.calves,
      },
      secondaryMuscles: {},
    ),
    equipments: {kBodyweightName, kMachineName, kStepperName},
  ),
  ExerciseData(
    name: kSeatedCalfMachineName,
    muscleGroup: MuscleGroup.legs,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.calves,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kCrunchesName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.abdominals,
        Muscle.upperAbs,
      },
      secondaryMuscles: {},
    ),
    equipments: {kBodyweightName},
  ),
  ExerciseData(
    name: kCableCrunchesName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.abdominals,
        Muscle.upperAbs,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName},
  ),
  ExerciseData(
    name: kCaptainsChairLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lowerAbs,
      },
      secondaryMuscles: {
        Muscle.abdominals,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
  ),
  ExerciseData(
    name: kHangingLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lowerAbs,
      },
      secondaryMuscles: {
        Muscle.abdominals,
        Muscle.forearms,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
  ),
  ExerciseData(
    name: kLyingLegRaisesName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lowerAbs,
      },
      secondaryMuscles: {
        Muscle.abdominals,
      },
    ),
    equipments: {kBodyweightName, kMachineName, kDumbbellsName},
  ),
  ExerciseData(
    name: kCableWoodchopperName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.obliques,
      },
      secondaryMuscles: {},
    ),
    equipments: {kCableName},
  ),
  ExerciseData(
    name: kBackExtensionName,
    muscleGroup: MuscleGroup.core,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.lowerBack,
      },
      secondaryMuscles: {},
    ),
    equipments: {kMachineName},
  ),
  ExerciseData(
    name: kBurpeesName,
    muscleGroup: MuscleGroup.full,
    muscles: ExerciseMuscles(
      primaryMuscles: {
        Muscle.chest,
        Muscle.quadriceps,
      },
      secondaryMuscles: {
        Muscle.frontDelts,
        Muscle.triceps,
        Muscle.glutes,
      },
    ),
    equipments: {kBodyweightName},
  ),
  ExerciseData(
    name: kAssistedPullUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.lats},
      secondaryMuscles: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kMachineName, kPullUpBarName},
  ),
  ExerciseData(
    name: kAssistedChinUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.lats},
      secondaryMuscles: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kMachineName, kPullUpBarName},
  ),
  ExerciseData(
    name: kSmithMachineSkullCrushersName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.triceps},
      secondaryMuscles: {},
    ),
    equipments: {kSmithMachineName, kBenchName},
  ),
  ExerciseData(
    name: kInclineDumbbellChestFlysName,
    muscleGroup: MuscleGroup.push,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.upperChest},
      secondaryMuscles: {Muscle.chest},
    ),
    equipments: {kDumbbellsName, kBenchName},
  ),
  ExerciseData(
    name: kWeightedPullUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.lats},
      secondaryMuscles: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName, kWeightBeltName},
  ),
  ExerciseData(
    name: kWeightedChinUpName,
    muscleGroup: MuscleGroup.pull,
    muscles: ExerciseMuscles(
      primaryMuscles: {Muscle.lats},
      secondaryMuscles: {Muscle.biceps, Muscle.forearms},
    ),
    equipments: {kPullUpBarName, kWeightBeltName},
  ),
};
