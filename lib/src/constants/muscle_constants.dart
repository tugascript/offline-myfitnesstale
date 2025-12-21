import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

import 'muscle_group_constants.dart';
import '../models/muscle_model.dart';

class MuscleData {
  final String name;
  final String? pictureUri;
  final String muscleGroupName;

  const MuscleData({
    required this.name,
    this.pictureUri,
    required this.muscleGroupName,
  });

  static final _logger = Logger('MuscleData');

  static Future<(List<Map<String, Object?>>, bool)> getMuscles(
    Database db,
    String tableName,
  ) async {
    _logger.info('Getting muscles');
    final placeholders = List.filled(_kInitialMuscles.length, '?').join(', ');
    final results = await db.query(
      tableName,
      where: 'name IN ($placeholders)',
      whereArgs: kMuscleNames,
    );
    return (results, results.length == _kInitialMuscles.length);
  }

  static Future<Map<String, int>> createMuscles(
    Database db,
    String tableName,
    String muscleGroupTableName,
    Map<String, int> muscleGroupMap,
  ) async {
    _logger.info('Creating muscles');
    final (results, allExist) = await getMuscles(db, tableName);

    _logger.info('Found ${results.length} muscles');

    final muscleMap = Map<String, int>.fromEntries(
      results.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
    if (allExist) {
      _logger.info('All muscles already exist');
      return muscleMap;
    }

    final nameMap = Set<String>.from(results.map((e) => e['name']));
    final missingMuscles = _kInitialMuscles.where(
      (e) => !nameMap.contains(e.name),
    );

    _logger.info('Inserting ${missingMuscles.length} muscles');
    await db.transaction((txn) async {
      for (final muscle in missingMuscles) {
        final muscleModel = Muscle.create(
          muscle.name,
          muscleGroupMap[muscle.muscleGroupName]!,
          muscle.pictureUri,
        );
        final id = await txn.insert(
          tableName,
          muscleModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        muscleMap[muscle.name] = id;
      }
    });

    _logger.info('Transaction committed');
    _logger.info('Muscles created');
    return muscleMap;
  }
}

const String kChestMuscleName = "Chest";
const String kUpperChestMuscleName = "Upper Chest";
const String kLowerChestMuscleName = "Lower Chest";
const String kInnerChestMuscleName = "Inner Chest";
const String kShouldersMuscleName = "Shoulders";
const String kFrontShouldersMuscleName = "Front Shoulders";
const String kSideShouldersMuscleName = "Side Shoulders";
const String kRearShouldersMuscleName = "Rear Shoulders";
const String kTricepsMuscleName = "Triceps";
const String kNeckMuscleName = "Neck";
const String kTrapsMuscleName = "Traps";
const String kUpperBackMuscleName = "Upper Back";
const String kLatsMuscleName = "Lats";
const String kBicepsMuscleName = "Biceps";
const String kBrachialisMuscleName = "Brachialis";
const String kForearmsMuscleName = "Forearms";
const String kQuadricepsMuscleName = "Quadriceps";
const String kHamstringsMuscleName = "Hamstrings";
const String kGlutesMuscleName = "Glutes";
const String kCalvesMuscleName = "Calves";
const String kAdductorsMuscleName = "Adductors";
const String kAbdominalsMuscleName = "Abdominals";
const String kUpperAbsMuscleName = "Upper Abs";
const String kLowerAbsMuscleName = "Lower Abs";
const String kObliquesMuscleName = "Obliques";
const String kLowerBackMuscleName = "Lower Back";

const List<String> kMuscleNames = [
  kChestMuscleName,
  kUpperChestMuscleName,
  kLowerChestMuscleName,
  kInnerChestMuscleName,
  kShouldersMuscleName,
  kFrontShouldersMuscleName,
  kSideShouldersMuscleName,
  kRearShouldersMuscleName,
  kTricepsMuscleName,
  kNeckMuscleName,
  kTrapsMuscleName,
  kUpperBackMuscleName,
  kLatsMuscleName,
  kBicepsMuscleName,
  kBrachialisMuscleName,
  kForearmsMuscleName,
  kQuadricepsMuscleName,
  kHamstringsMuscleName,
  kGlutesMuscleName,
  kCalvesMuscleName,
  kAdductorsMuscleName,
  kAbdominalsMuscleName,
  kUpperAbsMuscleName,
  kLowerAbsMuscleName,
  kObliquesMuscleName,
  kLowerBackMuscleName,
];

const Set<MuscleData> _kInitialMuscles = <MuscleData>{
  MuscleData(
    name: kChestMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kUpperChestMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kLowerChestMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kInnerChestMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kShouldersMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kFrontShouldersMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kSideShouldersMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kRearShouldersMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kTricepsMuscleName,
    muscleGroupName: kPushMuscleGroupName,
  ),
  MuscleData(
    name: kNeckMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kTrapsMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kUpperBackMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kLatsMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kBicepsMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kBrachialisMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kForearmsMuscleName,
    muscleGroupName: kPullMuscleGroupName,
  ),
  MuscleData(
    name: kQuadricepsMuscleName,
    muscleGroupName: kLegsMuscleGroupName,
  ),
  MuscleData(
    name: kHamstringsMuscleName,
    muscleGroupName: kLegsMuscleGroupName,
  ),
  MuscleData(
    name: kGlutesMuscleName,
    muscleGroupName: kLegsMuscleGroupName,
  ),
  MuscleData(
    name: kCalvesMuscleName,
    muscleGroupName: kLegsMuscleGroupName,
  ),
  MuscleData(
    name: kAdductorsMuscleName,
    muscleGroupName: kLegsMuscleGroupName,
  ),
  MuscleData(
    name: kAbdominalsMuscleName,
    muscleGroupName: kCoreMuscleGroupName,
  ),
  MuscleData(
    name: kUpperAbsMuscleName,
    muscleGroupName: kCoreMuscleGroupName,
  ),
  MuscleData(
    name: kLowerAbsMuscleName,
    muscleGroupName: kCoreMuscleGroupName,
  ),
  MuscleData(
    name: kObliquesMuscleName,
    muscleGroupName: kCoreMuscleGroupName,
  ),
  MuscleData(
    name: kLowerBackMuscleName,
    muscleGroupName: kCoreMuscleGroupName,
  ),
};
