import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/muscle_group_model.dart';

class MuscleGroupData {
  final String name;
  final String? pictureUri;

  const MuscleGroupData({
    required this.name,
    this.pictureUri,
  });

  static final _logger = Logger('MuscleGroupData');

  static Future<(List<Map<String, Object?>>, bool)> getMuscleGroups(
    Database db,
    String tableName,
  ) async {
    _logger.info('Getting muscle groups');
    final placeholders =
        List.filled(_kInitialMuscleGroups.length, '?').join(', ');
    final results = await db.query(
      tableName,
      where: 'name IN ($placeholders)',
      whereArgs: kMuscleGroupNames,
    );
    return (results, results.length == kMuscleGroupNames.length);
  }

  static Future<Map<String, int>> createMusclesGroups(
    Database db,
    String tableName,
  ) async {
    _logger.info('Creating muscle groups');
    final (results, allExist) = await getMuscleGroups(db, tableName);

    _logger.info('Found ${results.length} muscle groups');

    final muscleGroupMap = Map<String, int>.fromEntries(
      results.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
    if (allExist) {
      _logger.info('All muscle groups already exist');
      return muscleGroupMap;
    }

    final nameSet = Set<String>.from(results.map((e) => e['name']));
    final missingMuscleGroups = _kInitialMuscleGroups.where(
      (e) => !nameSet.contains(e.name),
    );

    _logger.info('Inserting ${missingMuscleGroups.length} muscle groups');
    final batch = db.batch();
    for (final muscleGroup in missingMuscleGroups) {
      _logger.info('Inserting ${muscleGroup.name}...');
      final muscleGroupModel = MuscleGroup.create(
        muscleGroup.name,
        muscleGroup.pictureUri,
      );
      batch.insert(
        tableName,
        muscleGroupModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('Inserted muscle group ${muscleGroup.name}');
    }
    final result = await batch.commit();

    // TODO fix me

    _logger.info('Transaction committed');
    _logger.info('Muscle groups created');
    return muscleGroupMap;
  }
}

const String kFullMuscleGroupName = "Full";
const String kPushMuscleGroupName = "Push";
const String kPullMuscleGroupName = "Pull";
const String kLegsMuscleGroupName = "Legs";
const String kCoreMuscleGroupName = "Core";

const List<String> kMuscleGroupNames = [
  kFullMuscleGroupName,
  kPushMuscleGroupName,
  kPullMuscleGroupName,
  kLegsMuscleGroupName,
  kCoreMuscleGroupName,
];

const Set<MuscleGroupData> _kInitialMuscleGroups = <MuscleGroupData>{
  MuscleGroupData(name: "Full"),
  MuscleGroupData(name: "Push"),
  MuscleGroupData(name: "Pull"),
  MuscleGroupData(name: "Legs"),
  MuscleGroupData(name: "Core"),
};
