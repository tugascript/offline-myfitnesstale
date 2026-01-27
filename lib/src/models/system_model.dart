import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'systems';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    theme TEXT NOT NULL,
    units TEXT NOT NULL,
    initial_setup TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  ''';

enum SystemColumns {
  id("id"),
  theme("theme"),
  units("units"),
  initialSetup("initial_setup"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const SystemColumns(this.value);
}

class System extends Equatable implements Model {
  @override
  final int? id;
  final ThemeType theme;
  final Units units;
  final SetUpStatus initialSetup;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const System({
    this.id,
    required this.theme,
    required this.units,
    required this.initialSetup,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      SystemColumns.id.value: id,
      SystemColumns.theme.value: theme.value,
      SystemColumns.units.value: units.value,
      SystemColumns.initialSetup.value: initialSetup.value,
      SystemColumns.createdAt.value: createdAt,
      SystemColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory System.fromMap(Map<String, Object?> map) {
    return System(
      id: map[SystemColumns.id.value] as int?,
      theme: ThemeType.fromValue(map[SystemColumns.theme.value]! as String),
      units: Units.fromValue(map[SystemColumns.units.value]! as String),
      initialSetup: SetUpStatus.fromValue(
          map[SystemColumns.initialSetup.value]! as String),
      createdAt: map[SystemColumns.createdAt.value]! as int,
      updatedAt: map[SystemColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory System.create({
    required ThemeType theme,
    required Units units,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return System(
      theme: theme,
      units: units,
      initialSetup: SetUpStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  System copyWith({
    int? id,
    ThemeType? theme,
    Units? units,
    SetUpStatus? initialSetup,
    int? createdAt,
    int? updatedAt,
  }) {
    return System(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      units: units ?? this.units,
      initialSetup: initialSetup ?? this.initialSetup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        theme,
        units,
        initialSetup,
        createdAt,
        updatedAt,
      ];
}
