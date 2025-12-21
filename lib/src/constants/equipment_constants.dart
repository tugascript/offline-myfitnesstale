import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/equipment_model.dart';

// Equipment name constants
const String kBarbellName = "Barbell";
const String kDumbbellsName = "Dumbbells";
const String kMachineName = "Machine";
const String kCableName = "Cable";
const String kBodyweightName = "Bodyweight";
const String kKettlebellName = "Kettlebell";
const String kResistanceBandName = "Resistance Band";
const String kSmithMachineName = "Smith Machine";
const String kEZBarName = "EZ Bar";
const String kTRXName = "TRX";
const String kMedicineBallName = "Medicine Ball";
const String kPullUpBarName = "Pull-up Bar";
const String kDipStationName = "Dip Station";
const String kBenchName = "Bench";
const String kPlateName = "Plate";
const String kDHandleName = "D-Handle";
const String kStraightBarName = "Straight Bar";
const String kTricepsRopeAttachmentName = "Triceps Rope Attachment";
const String kLatPulldownBarName = "Lat Pulldown Bar";
const String kWideLatBarName = "Wide Lat Bar";
const String kDoubleDHandleName = "Double D-Handle";
const String kPowerRackName = "Power Rack";
const String kWeightBeltName = "Weight Belt";
const String kStepperName = "Stepper";

const List<String> kEquipmentNames = [
  kBarbellName,
  kDumbbellsName,
  kMachineName,
  kCableName,
  kBodyweightName,
  kKettlebellName,
  kResistanceBandName,
  kSmithMachineName,
  kEZBarName,
  kTRXName,
  kMedicineBallName,
  kPullUpBarName,
  kDipStationName,
  kBenchName,
  kPlateName,
  kDHandleName,
  kStraightBarName,
  kTricepsRopeAttachmentName,
  kLatPulldownBarName,
  kWideLatBarName,
  kDoubleDHandleName,
  kPowerRackName,
  kWeightBeltName,
];

class EquipmentData {
  final String name;
  final String? pictureUri;

  const EquipmentData({
    required this.name,
    this.pictureUri,
  });

  static final _logger = Logger('EquipmentData');

  static Future<(List<Map<String, Object?>>, bool)> getEquipments(
    Database db,
    String tableName,
  ) async {
    _logger.info('Getting equipment');
    final placeholders =
        List.filled(_kInitialEquipments.length, '?').join(', ');
    final results = await db.query(
      tableName,
      where: 'name IN ($placeholders)',
      whereArgs: kEquipmentNames,
    );
    return (results, results.length == _kInitialEquipments.length);
  }

  static Future<Map<String, int>> createEquipments(
    Database db,
    String tableName,
  ) async {
    _logger.info('Creating equipment');
    final (results, allExist) = await getEquipments(db, tableName);

    _logger.info('Found ${results.length} equipment');

    final equipmentMap = Map<String, int>.fromEntries(
      results.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
    if (allExist) {
      _logger.info('All equipment already exist');
      return equipmentMap;
    }

    final batch = db.batch();
    for (final equipmentData in _kInitialEquipments) {
      if (!equipmentMap.containsKey(equipmentData.name)) {
        final equipment = Equipment.create(
          equipmentData.name,
          equipmentData.pictureUri,
        );
        batch.insert(
          tableName,
          equipment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    await batch.commit(noResult: true);

    // Re-fetch to get IDs
    final (newResults, _) = await getEquipments(db, tableName);
    return Map<String, int>.fromEntries(
      newResults.map((e) => MapEntry(e['name'] as String, e['id'] as int)),
    );
  }
}

const Set<EquipmentData> _kInitialEquipments = <EquipmentData>{
  EquipmentData(name: kBarbellName),
  EquipmentData(name: kDumbbellsName),
  EquipmentData(name: kMachineName),
  EquipmentData(name: kCableName),
  EquipmentData(name: kBodyweightName),
  EquipmentData(name: kKettlebellName),
  EquipmentData(name: kResistanceBandName),
  EquipmentData(name: kSmithMachineName),
  EquipmentData(name: kEZBarName),
  EquipmentData(name: kTRXName),
  EquipmentData(name: kMedicineBallName),
  EquipmentData(name: kPullUpBarName),
  EquipmentData(name: kDipStationName),
  EquipmentData(name: kBenchName),
  EquipmentData(name: kPlateName),
  EquipmentData(name: kDHandleName),
  EquipmentData(name: kStraightBarName),
  EquipmentData(name: kTricepsRopeAttachmentName),
  EquipmentData(name: kLatPulldownBarName),
  EquipmentData(name: kWideLatBarName),
  EquipmentData(name: kDoubleDHandleName),
  EquipmentData(name: kPowerRackName),
  EquipmentData(name: kWeightBeltName),
  EquipmentData(name: kStepperName),
};
