import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/exercise_muscle_model.dart';
import '../models/exercise_equipment_model.dart';
import 'equipment_constants.dart';
import 'muscle_constants.dart';
import 'muscle_group_constants.dart';

class ExerciseMuscleData {
  final String name;
  final ExerciseMuscleCategory category;

  const ExerciseMuscleData({
    required this.name,
    required this.category,
  });
}

class ExerciseData {
  final String name;
  final String muscleGroupName;
  final List<ExerciseMuscleData> muscles;
  final List<String> equipments;

  const ExerciseData({
    required this.name,
    required this.muscleGroupName,
    required this.muscles,
    required this.equipments,
  });

  static final _logger = Logger('ExerciseData');

  static Future<(List<Map<String, Object?>>, bool)> getExercises(
    Database db,
    String tableName,
  ) async {
    _logger.info('Getting exercises');
    final placeholders = List.filled(_kInitialExercises.length, '?').join(', ');
    final results = await db.query(
      tableName,
      where: 'name IN ($placeholders)',
      whereArgs: kExerciseNames,
    );
    return (results, results.length == _kInitialExercises.length);
  }

  static Future<Map<String, int>> createExercises(
    Database db,
    String tableName,
    String exerciseMuscleTableName,
    String muscleTableName,
    String muscleGroupTableName,
    String exerciseEquipmentTableName,
    Map<String, int> muscleGroupMap,
    Map<String, int> muscleMap,
    Map<String, int> equipmentMap,
  ) async {
    _logger.info('Creating exercises');
    final (results, allExist) = await getExercises(db, tableName);
    _logger.info('Found ${results.length} exercises');

    final exerciseMap = Map<String, int>.fromEntries(
      results.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
    if (allExist) {
      _logger.info('All exercises already exist');
      return exerciseMap;
    }

    final nameSet = Set<String>.from(results.map((e) => e['name']));
    final missingExercises = _kInitialExercises.where(
      (e) => !nameSet.contains(e.name),
    );

    _logger.info('Inserting ${missingExercises.length} exercises');
    _logger.info('Starting transaction');
    await db.transaction((txn) async {
      for (final exercise in missingExercises) {
        final exerciseModel = Exercise.create(
          name: exercise.name,
          muscleGroupId: muscleGroupMap[exercise.muscleGroupName]!,
        );
        final exerciseId = await txn.insert(
          tableName,
          exerciseModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        for (final muscle in exercise.muscles) {
          final exerciseMuscleModel = ExerciseMuscle.create(
            exerciseId,
            muscleMap[muscle.name]!,
            muscle.category,
          );
          await txn.insert(
            exerciseMuscleTableName,
            exerciseMuscleModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        for (final equipment in exercise.equipments) {
          final exerciseEquipmentModel = ExerciseEquipment.create(
            exerciseId,
            equipmentMap[equipment]!,
          );
          await txn.insert(
            exerciseEquipmentTableName,
            exerciseEquipmentModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        exerciseMap[exercise.name] = exerciseId;
      }
    });
    _logger.info('Committing transaction');
    _logger.info('Exercises created');
    return exerciseMap;
  }
}

const String kBarbellChestPressName = "Barbell Chest Press";
const String kInclineBarbellChestPressName = "Incline Barbell Chest Press";
const String kDumbbellChestPressName = "Dumbbell Chest Press";
const String kInclineDumbbellChestPressName = "Incline Dumbbell Chest Press";
const String kInclineMachineChestPressName = "Incline Machine Chest Press";
const String kMachineChestPressName = "Machine Chest Press";
const String kMachineChestFlyName = "Machine Chest Fly";
const String kCableUnderhandFlyName = "Cable Underhand Fly";
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
const String kSeatedCableRowName = "Seated Cable Row";
const String kFacePullsName = "Face Pulls";
const String kMachineReverseFlyName = "Machine Reverse Fly";
const String kBentOverDumbbellReverseFlyName = "Bent Over Dumbbell Reverse Fly";
const String kInclineDumbbellReverseFlyName = "Incline Dumbbell Reverse Fly";
const String kBarbellBicepCurlName = "Barbell Bicep Curl";
const String kDumbbellBicepCurlName = "Dumbbell Bicep Curl";
const String kHammerCurlName = "Hammer Curl";
const String kBarbellPreacherCurlName = "Barbell Preacher Curl";
const String kDumbbellPreacherCurlName = "Dumbbell Preacher Curl";
const String kCableEZBarBicepCurlName = "Cable EZ Bar Bicep Curl";
const String kCableDHandleBicepCurlName = "Cable D-Handle Bicep Curl";
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
const String kLegCurlName = "Leg Curl";
const String kLegExtensionName = "Leg Extension";
const String kStandingCalfRaisesName = "Standing Calf Raises";
const String kCrunchesName = "Crunches";
const String kCableCrunchesName = "Cable Crunches";
const String kLegRaisesName = "Leg Raises";
const String kCableWoodchopperName = "Cable Woodchopper";
const String kBackExtensionName = "Back Extension";
const String kBurpeesName = "Burpees";

const List<String> kExerciseNames = [
  kBarbellChestPressName,
  kInclineBarbellChestPressName,
  kDumbbellChestPressName,
  kInclineDumbbellChestPressName,
  kInclineMachineChestPressName,
  kMachineChestPressName,
  kMachineChestFlyName,
  kCableUnderhandFlyName,
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
  kDipsName,
  kPullUpsName,
  kChinUpsName,
  kOverhandLatPulldownName,
  kUnderhandLatPulldownName,
  kBarbellBentOverRowsName,
  kSingleArmSupportedDumbbellRowName,
  kInclineDumbbellRowName,
  kTBarRowName,
  kChestSupportedTBarRowName,
  kSeatedCableRowName,
  kFacePullsName,
  kMachineReverseFlyName,
  kBentOverDumbbellReverseFlyName,
  kInclineDumbbellReverseFlyName,
  kBarbellBicepCurlName,
  kDumbbellBicepCurlName,
  kHammerCurlName,
  kBarbellPreacherCurlName,
  kDumbbellPreacherCurlName,
  kCableEZBarBicepCurlName,
  kCableDHandleBicepCurlName,
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
  kLegCurlName,
  kLegExtensionName,
  kStandingCalfRaisesName,
  kCrunchesName,
  kCableCrunchesName,
  kLegRaisesName,
  kCableWoodchopperName,
  kBackExtensionName,
  kBurpeesName,
];

const Set<ExerciseData> _kInitialExercises = <ExerciseData>{
  ExerciseData(
    name: kBarbellChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kBenchName],
  ),
  ExerciseData(
    name: kInclineBarbellChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kBenchName],
  ),
  ExerciseData(
    name: kDumbbellChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kInclineDumbbellChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kInclineMachineChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kUpperChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kMachineChestPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kMachineChestFlyName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kCableUnderhandFlyName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kUpperChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kDHandleName],
  ),
  ExerciseData(
    name: kStandingBarbellShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kPowerRackName],
  ),
  ExerciseData(
    name: kSeatedBarbellShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kPowerRackName, kBenchName],
  ),
  ExerciseData(
    name: kSmithMachineShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kSmithMachineName, kBenchName],
  ),
  ExerciseData(
    name: kMachineShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kStandingDumbbellShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kSeatedDumbbellShoulderPressName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kDumbbellLateralRaisesName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kSideShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kCableLateralRaisesName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kSideShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kDHandleName],
  ),
  ExerciseData(
    name: kLeaningCableLateralRaiseName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kSideShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kDHandleName],
  ),
  ExerciseData(
    name: kCableOverheadTricepsExtensionName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kCableName, kEZBarName],
  ),
  ExerciseData(
    name: kDumbbellOverheadTricepsExtensionName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kSkullCrushersName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBarbellName, kBenchName],
  ),
  ExerciseData(
    name: kTricepsPushdownName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kCableName, kEZBarName],
  ),
  ExerciseData(
    name: kDipsName,
    muscleGroupName: kPushMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDipStationName, kBodyweightName, kWeightBeltName],
  ),
  ExerciseData(
    name: kPullUpsName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kPullUpBarName, kBodyweightName, kWeightBeltName],
  ),
  ExerciseData(
    name: kChinUpsName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kPullUpBarName, kBodyweightName, kWeightBeltName],
  ),
  ExerciseData(
    name: kOverhandLatPulldownName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kLatPulldownBarName],
  ),
  ExerciseData(
    name: kUnderhandLatPulldownName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kLatPulldownBarName],
  ),
  ExerciseData(
    name: kBarbellBentOverRowsName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName],
  ),
  ExerciseData(
    name: kSingleArmSupportedDumbbellRowName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kInclineDumbbellRowName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kTBarRowName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kDoubleDHandleName],
  ),
  ExerciseData(
    name: kChestSupportedTBarRowName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kSeatedCableRowName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kDoubleDHandleName, kWideLatBarName],
  ),
  ExerciseData(
    name: kFacePullsName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kNeckMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kTricepsRopeAttachmentName],
  ),
  ExerciseData(
    name: kMachineReverseFlyName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kNeckMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kBentOverDumbbellReverseFlyName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kNeckMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kInclineDumbbellReverseFlyName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kRearShouldersMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kNeckMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kBarbellBicepCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kEZBarName],
  ),
  ExerciseData(
    name: kDumbbellBicepCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kHammerCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBrachialisMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kBarbellPreacherCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kBenchName],
  ),
  ExerciseData(
    name: kDumbbellPreacherCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName, kBenchName],
  ),
  ExerciseData(
    name: kCableEZBarBicepCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kEZBarName],
  ),
  ExerciseData(
    name: kCableDHandleBicepCurlName,
    muscleGroupName: kPullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kBicepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kCableName, kDHandleName],
  ),
  ExerciseData(
    name: kBarbellBackSquatName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kAdductorsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kPowerRackName],
  ),
  ExerciseData(
    name: kBarbellFrontSquatName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kUpperBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kAdductorsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName, kPowerRackName],
  ),
  ExerciseData(
    name: kSmithMachineSquatName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kAdductorsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kSmithMachineName],
  ),
  ExerciseData(
    name: kHackSquatName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kAdductorsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kLegPressName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kAdductorsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kBarbellDeadliftName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName],
  ),
  ExerciseData(
    name: kBarbellSumoDeadliftName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName],
  ),
  ExerciseData(
    name: kBarbellRomanianDeadliftName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBarbellName],
  ),
  ExerciseData(
    name: kDumbbellRomanianDeadliftName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kDumbbellsName],
  ),
  ExerciseData(
    name: kSmithMachineRomanianDeadliftName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kForearmsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kLatsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kSmithMachineName],
  ),
  ExerciseData(
    name: kSmithMachineGoodMorningName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kSmithMachineName],
  ),
  ExerciseData(
    name: kWalkingLungesName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBodyweightName, kDumbbellsName],
  ),
  ExerciseData(
    name: kLungeName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBodyweightName, kDumbbellsName],
  ),
  ExerciseData(
    name: kSmithMachineElevatedLungeName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kSmithMachineName, kStepperName],
  ),
  ExerciseData(
    name: kLegCurlName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kHamstringsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kLegExtensionName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kStandingCalfRaisesName,
    muscleGroupName: kLegsMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kCalvesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBodyweightName, kMachineName, kStepperName],
  ),
  ExerciseData(
    name: kCrunchesName,
    muscleGroupName: kCoreMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kAbdominalsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperAbsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBodyweightName],
  ),
  ExerciseData(
    name: kCableCrunchesName,
    muscleGroupName: kCoreMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kAbdominalsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kUpperAbsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kCableName],
  ),
  ExerciseData(
    name: kLegRaisesName,
    muscleGroupName: kCoreMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kAbdominalsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kLowerAbsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kBodyweightName, kMachineName, kDumbbellsName],
  ),
  ExerciseData(
    name: kCableWoodchopperName,
    muscleGroupName: kCoreMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kObliquesMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kCableName],
  ),
  ExerciseData(
    name: kBackExtensionName,
    muscleGroupName: kCoreMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kLowerBackMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
    ],
    equipments: [kMachineName],
  ),
  ExerciseData(
    name: kBurpeesName,
    muscleGroupName: kFullMuscleGroupName,
    muscles: [
      ExerciseMuscleData(
        name: kChestMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kQuadricepsMuscleName,
        category: ExerciseMuscleCategory.primary,
      ),
      ExerciseMuscleData(
        name: kFrontShouldersMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kTricepsMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
      ExerciseMuscleData(
        name: kGlutesMuscleName,
        category: ExerciseMuscleCategory.secondary,
      ),
    ],
    equipments: [kBodyweightName],
  ),
};
