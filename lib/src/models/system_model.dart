import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'profile_model.dart';
import 'utilities.dart';

const String _table = 'systems';

enum SystemColumns {
  id("id"),
  theme("theme"),
  units("units"),
  initialSetup("initial_setup"),
  notificationsOn("notifications_on"),
  profileId("profile_id"),
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
  final bool notificationsOn;
  final int profileId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const System({
    this.id,
    required this.theme,
    required this.units,
    required this.initialSetup,
    required this.notificationsOn,
    required this.profileId,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = """
  CREATE TABLE IF NOT EXISTS $_table (
    ${SystemColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${SystemColumns.theme.value} TEXT NOT NULL,
    ${SystemColumns.units.value} TEXT NOT NULL,
    ${SystemColumns.initialSetup.value} TEXT NOT NULL,
    ${SystemColumns.notificationsOn.value} BOOLEAN NOT NULL,
    ${SystemColumns.profileId.value} INTEGER NOT NULL,
    ${SystemColumns.createdAt.value} INTEGER NOT NULL,
    ${SystemColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${SystemColumns.profileId.value}) REFERENCES ${Profile.table} (${ProfileColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE UNIQUE INDEX IF NOT EXISTS uidx_system_profile_id ON $_table (${SystemColumns.profileId.value});
  """;

  @override
  Map<String, Object?> toMap() {
    return {
      SystemColumns.id.value: id,
      SystemColumns.theme.value: theme.value,
      SystemColumns.units.value: units.value,
      SystemColumns.initialSetup.value: initialSetup.value,
      SystemColumns.notificationsOn.value: notificationsOn,
      SystemColumns.profileId.value: profileId,
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
      notificationsOn:
          map[SystemColumns.notificationsOn.value]! as int == 1 ? true : false,
      profileId: map[SystemColumns.profileId.value]! as int,
      createdAt: map[SystemColumns.createdAt.value]! as int,
      updatedAt: map[SystemColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory System.create({
    required ThemeType theme,
    required Units units,
    required int profileId,
    required bool notificationsOn,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return System(
      theme: theme,
      units: units,
      initialSetup: SetUpStatus.notStarted,
      notificationsOn: notificationsOn,
      profileId: profileId,
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
    int? profileId,
    bool? notificationsOn,
    int? createdAt,
    int? updatedAt,
  }) {
    return System(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      units: units ?? this.units,
      initialSetup: initialSetup ?? this.initialSetup,
      profileId: profileId ?? this.profileId,
      notificationsOn: notificationsOn ?? this.notificationsOn,
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
        profileId,
        notificationsOn,
        createdAt,
        updatedAt,
      ];
}
