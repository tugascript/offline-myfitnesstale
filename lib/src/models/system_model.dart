import 'package:equatable/equatable.dart';
import 'package:myfitnesstale/src/models/utilities.dart';

import 'enums.dart';
import 'model.dart';
import 'profile_model.dart';

const String _table = 'systems';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profile_id INTEGER NOT NULL,
    theme TEXT NOT NULL,
    units TEXT NOT NULL,
    muscle_group_setup TEXT NOT NULL,
    muscle_setup TEXT NOT NULL,
    exercise_setup TEXT NOT NULL,
    workout_setup TEXT NOT NULL,
    workout_plan_setup TEXT NOT NULL,
    initial_setup TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES ${Profile.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_systems_profile_id ON $_table (profile_id);
  ''';

class System extends Equatable implements Model {
  @override
  final int? id;
  final int profileId;
  final ThemeType theme;
  final Units units;
  final SetUpStatus muscleGroupSetup;
  final SetUpStatus muscleSetup;
  final SetUpStatus exerciseSetup;
  final SetUpStatus workoutSetup;
  final SetUpStatus workoutPlanSetup;
  final SetUpStatus initialSetup;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const System({
    this.id,
    required this.profileId,
    required this.theme,
    required this.units,
    required this.muscleGroupSetup,
    required this.muscleSetup,
    required this.exerciseSetup,
    required this.workoutSetup,
    required this.workoutPlanSetup,
    required this.initialSetup,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'theme': theme.value,
      'units': units.value,
      'muscle_group_setup': muscleGroupSetup.value,
      'muscle_setup': muscleSetup.value,
      'exercise_setup': exerciseSetup.value,
      'workout_setup': workoutSetup.value,
      'workout_plan_setup': workoutPlanSetup.value,
      'initial_setup': initialSetup.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory System.fromMap(Map<String, Object?> map) {
    return System(
      id: map['id'] as int?,
      profileId: map['profile_id']! as int,
      theme: ThemeType.fromValue(map['theme']! as String),
      units: Units.fromValue(map['units']! as String),
      muscleGroupSetup:
          SetUpStatus.fromValue(map['muscle_group_setup']! as String),
      muscleSetup: SetUpStatus.fromValue(map['muscle_setup']! as String),
      exerciseSetup: SetUpStatus.fromValue(map['exercise_setup']! as String),
      workoutSetup: SetUpStatus.fromValue(map['workout_setup']! as String),
      workoutPlanSetup:
          SetUpStatus.fromValue(map['workout_plan_setup']! as String),
      initialSetup: SetUpStatus.fromValue(map['initial_setup']! as String),
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  @override
  factory System.create(
    int profileId,
    ThemeType theme,
    Units units,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return System(
      profileId: profileId,
      theme: theme,
      units: units,
      muscleGroupSetup: SetUpStatus.notStarted,
      muscleSetup: SetUpStatus.notStarted,
      exerciseSetup: SetUpStatus.notStarted,
      workoutSetup: SetUpStatus.notStarted,
      workoutPlanSetup: SetUpStatus.notStarted,
      initialSetup: SetUpStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  System copyWith({
    int? id,
    int? profileId,
    ThemeType? theme,
    Units? units,
    SetUpStatus? muscleGroupSetup,
    SetUpStatus? muscleSetup,
    SetUpStatus? exerciseSetup,
    SetUpStatus? workoutSetup,
    SetUpStatus? workoutPlanSetup,
    SetUpStatus? initialSetup,
    int? createdAt,
    int? updatedAt,
  }) {
    return System(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      theme: theme ?? this.theme,
      units: units ?? this.units,
      muscleGroupSetup: muscleGroupSetup ?? this.muscleGroupSetup,
      muscleSetup: muscleSetup ?? this.muscleSetup,
      exerciseSetup: exerciseSetup ?? this.exerciseSetup,
      workoutSetup: workoutSetup ?? this.workoutSetup,
      workoutPlanSetup: workoutPlanSetup ?? this.workoutPlanSetup,
      initialSetup: initialSetup ?? this.initialSetup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        theme,
        units,
        muscleGroupSetup,
        muscleSetup,
        exerciseSetup,
        workoutSetup,
        workoutPlanSetup,
        initialSetup,
        createdAt,
        updatedAt,
      ];
}
