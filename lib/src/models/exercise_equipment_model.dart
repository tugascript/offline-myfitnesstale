import 'equipment_model.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'exercise_equipment';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    exercise_id INTEGER NOT NULL,
    equipment_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    PRIMARY KEY (exercise_id, equipment_id),
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES ${Equipment.table} (id)
      ON DELETE CASCADE
  );
  ''';

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
  static const String tableCreate = _tableCreate;
  static const (String, String) primaryKeys = ('exercise_id', 'equipment_id');

  @override
  Map<String, Object?> toMap() {
    return {
      'exercise_id': exerciseId,
      'equipment_id': equipmentId,
      'created_at': createdAt,
    };
  }

  @override
  factory ExerciseEquipment.fromMap(Map<String, Object?> map) {
    return ExerciseEquipment(
      exerciseId: map['exercise_id'] as int,
      equipmentId: map['equipment_id'] as int,
      createdAt: map['created_at'] as int,
    );
  }

  @override
  factory ExerciseEquipment.create(
    int exerciseId,
    int equipmentId,
  ) {
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

