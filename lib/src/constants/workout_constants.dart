import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

import 'exercise_constants.dart';
import '../models/enums.dart';
import '../models/workout_model.dart';
import '../models/workout_set_model.dart';
import '../models/workout_set_exercise_model.dart';

class WorkoutSetExerciseData {
  final String exerciseName;
  final int minReps;
  final int maxReps;
  final int rir;

  const WorkoutSetExerciseData({
    required this.exerciseName,
    required this.minReps,
    required this.maxReps,
    required this.rir,
  });
}

class WorkoutSetData {
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int maxRestSecs;
  final List<WorkoutSetExerciseData> exercises;

  const WorkoutSetData({
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.exercises,
  });
}

class WorkoutData {
  final String name;
  final String description;
  final Difficulty difficulty;
  final List<WorkoutSetData> sets;

  const WorkoutData({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.sets,
  });

  static final _logger = Logger('WorkoutData');

  static Future<(List<Map<String, Object?>>, bool)> getWorkouts(
    Database db,
    String tableName,
  ) async {
    _logger.info('Getting workouts');
    final placeholders = List.filled(_kInitialWorkouts.length, '?').join(', ');
    final results = await db.query(
      tableName,
      where: 'name IN ($placeholders)',
      whereArgs: kUpperLowerEnduranceWorkoutNames,
    );
    return (results, results.length == _kInitialWorkouts.length);
  }

  static Future<Map<String, int>> createWorkouts(
    Database db,
    String tableName,
    String workoutSetTableName,
    String workoutSetExerciseTableName,
    Map<String, int> exerciseMap,
  ) async {
    _logger.info('Creating workouts');
    final (results, allExist) = await getWorkouts(db, tableName);
    _logger.info('Found ${results.length} workouts');

    final workoutMap = Map<String, int>.fromEntries(
      results.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
    if (allExist) {
      _logger.info('All workouts already exist');
      return workoutMap;
    }

    final nameSet = Set<String>.from(results.map((e) => e['name']));
    final missingWorkouts = _kInitialWorkouts.where(
      (e) => !nameSet.contains(e.name),
    );

    _logger.info('Inserting ${missingWorkouts.length} workouts');
    _logger.info('Starting transaction');
    await db.transaction((txn) async {
      for (final workout in missingWorkouts) {
        final workoutModel = Workout.create(
          workout.name,
          workout.difficulty,
          workout.description,
          null,
          null,
        );
        final workoutId = await txn.insert(
          tableName,
          workoutModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (int i = 0; i < workout.sets.length; i++) {
          final workoutSet = workout.sets[i];
          final workoutSetModel = WorkoutSet.create(
            i + 1,
            workoutId,
            workoutSet.minSets,
            workoutSet.recommendedRestSecs,
            workoutSet.maxSets,
            workoutSet.maxRestSecs,
          );
          final workoutSetId = await txn.insert(
            workoutSetTableName,
            workoutSetModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          for (int j = 0; j < workoutSet.exercises.length; j++) {
            final workoutSetExercise = workoutSet.exercises[j];
            final workoutSetExerciseModel = WorkoutSetExercise.create(
              j + 1,
              workoutId,
              workoutSetId,
              exerciseMap[workoutSetExercise.exerciseName]!,
              workoutSetExercise.minReps,
              workoutSetExercise.maxReps,
              (
                WorkoutSetExerciseDifficulty.rir,
                workoutSetExercise.rir,
              ),
            );
            await txn.insert(
              workoutSetExerciseTableName,
              workoutSetExerciseModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        workoutMap[workout.name] = workoutId;
      }
    });
    _logger.info('Committed transaction');
    _logger.info('Workouts created');
    return workoutMap;
  }
}

const String kUpperLowerEndurance1Name =
    "Upper-Lower Muscular Endurance Push Focused";
const String kUpperLowerEndurance2Name =
    "Upper-Lower Muscular Endurance Hamstrings Focused";
const String kUpperLowerEndurance3Name =
    "Upper-Lower Muscular Endurance Pull Focused";
const String kUpperLowerEndurance4Name =
    "Upper-Lower Muscular Endurance Quads Focused";
const String kUpperLowerHypertrophy1Name =
    "Upper-Lower Hypertrophy Push Focused";
const String kUpperLowerHypertrophy2Name =
    "Upper-Lower Hypertrophy Hamstrings Focused";
const String kUpperLowerHypertrophy3Name =
    "Upper-Lower Hypertrophy Pull Focused";
const String kUpperLowerHypertrophy4Name =
    "Upper-Lower Hypertrophy Quads Focused";

const List<String> kUpperLowerEnduranceWorkoutNames = [
  kUpperLowerEndurance1Name,
  kUpperLowerEndurance2Name,
  kUpperLowerEndurance3Name,
  kUpperLowerEndurance4Name,
  kUpperLowerHypertrophy1Name,
  kUpperLowerHypertrophy2Name,
  kUpperLowerHypertrophy3Name,
  kUpperLowerHypertrophy4Name,
];

const Set<WorkoutData> _kInitialWorkouts = <WorkoutData>{
  WorkoutData(
    name: kUpperLowerEndurance1Name,
    description:
        "Basic upper-lower split upper body workout for the muscular endurance phase.\nThis workout is designed for beginner lifters focusing on Push exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kInclineMachineChestPressName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kUnderhandLatPulldownName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 45,
        maxRestSecs: 60,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCableOverheadTricepsExtensionName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 45,
        maxRestSecs: 60,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kMachineReverseFlyName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 30,
        maxRestSecs: 45,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCableLateralRaisesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerEndurance2Name,
    description:
        "Basic upper-lower split upper body workout for the muscular endurance phase.\nThis workout is designed for beginner lifters focusing on Hamstrings exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kDumbbellRomanianDeadliftName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegExtensionName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kStandingCalfRaisesName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCrunchesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegRaisesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerEndurance3Name,
    description:
        "Basic upper-lower split lower body workout for the muscular endurance phase.\nThis workout is designed for beginner lifters focusing on Pull exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kSeatedCableRowName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kMachineShoulderPressName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kOverhandLatPulldownName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kDipsName,
            minReps: 12,
            maxReps: 15,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 45,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCableEZBarBicepCurlName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerEndurance4Name,
    description:
        "Basic upper-lower split lower body workout for the muscular endurance phase.\nThis workout is designed for beginner lifters focusing on Quad exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kHackSquatName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegCurlName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kStandingCalfRaisesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCrunchesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegRaisesName,
            minReps: 15,
            maxReps: 20,
            rir: 3,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerHypertrophy1Name,
    description:
        "Basic upper-lower split upper body workout for the hypertrophy phase.\nThis workout is designed for beginner lifters focusing on Push exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kInclineDumbbellChestPressName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kUnderhandLatPulldownName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 150,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kTricepsPushdownName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 150,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kFacePullsName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 150,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLeaningCableLateralRaiseName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerHypertrophy2Name,
    description:
        "Basic upper-lower split upper body workout for the hypertrophy phase.\nThis workout is designed for beginner lifters focusing on Hamstrings exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 240,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kSmithMachineRomanianDeadliftName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegExtensionName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kStandingCalfRaisesName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kCableCrunchesName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 60,
        maxRestSecs: 120,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kLegRaisesName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerHypertrophy3Name,
    description:
        "Basic upper-lower split upper body workout for the hypertrophy phase.\nThis workout is designed for beginner lifters focusing on Pull exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kTBarRowName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kSeatedDumbbellShoulderPressName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 150,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kOverhandLatPulldownName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 240,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kDipsName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 150,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kDumbbellBicepCurlName,
            minReps: 10,
            maxReps: 12,
            rir: 2,
          ),
        ],
      ),
    ],
  ),
  WorkoutData(
    name: kUpperLowerHypertrophy4Name,
    description:
        "Basic upper-lower split lower body workout for the hypertrophy phase.\nThis workout is designed for beginner lifters focusing on Quad exercises.\nEither 3 or 4 sets for each exercise depending on your fitness level and time.",
    difficulty: Difficulty.beginner,
    sets: [
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 240,
        exercises: [
          WorkoutSetExerciseData(
            exerciseName: kSmithMachineSquatName,
            minReps: 8,
            maxReps: 10,
            rir: 2,
          ),
        ],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [],
      ),
      WorkoutSetData(
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 120,
        maxRestSecs: 180,
        exercises: [],
      ),
    ],
  ),
};
