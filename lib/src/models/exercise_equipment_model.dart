import 'equipment_model.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'exercise_equipment';

enum ExerciseEquipmentColumns with Columns {
  exerciseId("exercise_id"),
  equipmentId("equipment_id"),
  createdAt("created_at");

  @override
  final String value;

  const ExerciseEquipmentColumns(this.value);
}

class ExerciseEquipment implements JoinModel {
  final int exerciseId;
  final int equipmentId;
  @override
  final int createdAt;

  const ExerciseEquipment({
    required this.exerciseId,
    required this.equipmentId,
    required this.createdAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${ExerciseEquipmentColumns.exerciseId.value} INTEGER NOT NULL,
    ${ExerciseEquipmentColumns.equipmentId.value} INTEGER NOT NULL,
    ${ExerciseEquipmentColumns.createdAt.value} INTEGER NOT NULL,
    PRIMARY KEY (${ExerciseEquipmentColumns.exerciseId.value}, ${ExerciseEquipmentColumns.equipmentId.value}),
    FOREIGN KEY (${ExerciseEquipmentColumns.exerciseId.value}) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${ExerciseEquipmentColumns.equipmentId.value}) REFERENCES ${Equipment.table} (id)
      ON DELETE CASCADE
  );
  ''';
  static final (String, String) primaryKeys = (
    ExerciseEquipmentColumns.exerciseId.value,
    ExerciseEquipmentColumns.equipmentId.value,
  );

  @override
  Map<String, Object?> toMap() {
    return {
      ExerciseEquipmentColumns.exerciseId.value: exerciseId,
      ExerciseEquipmentColumns.equipmentId.value: equipmentId,
      ExerciseEquipmentColumns.createdAt.value: createdAt,
    };
  }

  factory ExerciseEquipment.fromMap(Map<String, Object?> map) {
    return ExerciseEquipment(
      exerciseId: map[ExerciseEquipmentColumns.exerciseId.value] as int,
      equipmentId: map[ExerciseEquipmentColumns.equipmentId.value] as int,
      createdAt: map[ExerciseEquipmentColumns.createdAt.value] as int,
    );
  }

  factory ExerciseEquipment.create({
    required int exerciseId,
    required int equipmentId,
  }) {
    return ExerciseEquipment(
      exerciseId: exerciseId,
      equipmentId: equipmentId,
      createdAt: DateUtilities.getNowUtcUnix(),
    );
  }

  @override
  ExerciseEquipment copyWith({
    int? exerciseId,
    int? equipmentId,
    int? createdAt,
  }) {
    return ExerciseEquipment(
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ExerciseEquipment{exerciseId: $exerciseId, equipmentId: $equipmentId, createdAt: $createdAt}';
  }
}
