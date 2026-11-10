// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../utils/dates.dart';
import 'model.dart';
import 'profile_model.dart';

const String _table = 'reminders_configs';

enum RemindersConfigColumns with Columns {
  id("id"),
  workoutsOn("workouts_on"),
  workoutsReminderTime("workouts_reminder_time"),
  weightRecordsOn("weight_records_on"),
  weightRecordsReminderTime("weight_records_reminder_time"),
  macroTrackingOn("macro_tracking_on"),
  macroTrackingReminderTime("macro_tracking_reminder_time"),
  profileId("profile_id"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const RemindersConfigColumns(this.value);
}

final class RemindersConfig extends Equatable implements Model {
  @override
  final int? id;
  final bool workoutsOn;
  final int workoutsReminderTime;
  final bool weightRecordsOn;
  final int weightRecordsReminderTime;
  final bool macroTrackingOn;
  final int macroTrackingReminderTime;
  final int profileId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const RemindersConfig({
    this.id,
    required this.workoutsOn,
    required this.workoutsReminderTime,
    required this.weightRecordsOn,
    required this.weightRecordsReminderTime,
    required this.macroTrackingOn,
    required this.macroTrackingReminderTime,
    required this.profileId,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
    CREATE TABLE IF NOT EXISTS $_table (
      ${RemindersConfigColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${RemindersConfigColumns.workoutsOn.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.workoutsReminderTime.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.weightRecordsOn.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.weightRecordsReminderTime.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.macroTrackingOn.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.macroTrackingReminderTime.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.profileId.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.createdAt.value} INTEGER NOT NULL,
      ${RemindersConfigColumns.updatedAt.value} INTEGER NOT NULL,
      FOREIGN KEY (${RemindersConfigColumns.profileId.value}) REFERENCES ${Profile.table} (${ProfileColumns.id.value})
        ON DELETE CASCADE
    );

    CREATE UNIQUE INDEX IF NOT EXISTS uidx_reminders_configs_profile_id ON $_table (${RemindersConfigColumns.profileId.value});
    ''';

  @override
  Map<String, Object?> toMap() {
    return {
      RemindersConfigColumns.id.value: id,
      RemindersConfigColumns.workoutsOn.value: workoutsOn ? 1 : 0,
      RemindersConfigColumns.workoutsReminderTime.value: workoutsReminderTime,
      RemindersConfigColumns.weightRecordsOn.value: weightRecordsOn ? 1 : 0,
      RemindersConfigColumns.weightRecordsReminderTime.value:
          weightRecordsReminderTime,
      RemindersConfigColumns.macroTrackingOn.value: macroTrackingOn ? 1 : 0,
      RemindersConfigColumns.macroTrackingReminderTime.value:
          macroTrackingReminderTime,
      RemindersConfigColumns.profileId.value: profileId,
      RemindersConfigColumns.createdAt.value: createdAt,
      RemindersConfigColumns.updatedAt.value: updatedAt,
    };
  }

  factory RemindersConfig.fromMap(Map<String, Object?> map) {
    return RemindersConfig(
      id: map[RemindersConfigColumns.id.value] as int?,
      workoutsOn: map[RemindersConfigColumns.workoutsOn.value]! as int == 1,
      workoutsReminderTime:
          map[RemindersConfigColumns.workoutsReminderTime.value]! as int,
      weightRecordsOn:
          map[RemindersConfigColumns.weightRecordsOn.value]! as int == 1,
      weightRecordsReminderTime:
          map[RemindersConfigColumns.weightRecordsReminderTime.value]! as int,
      macroTrackingOn:
          map[RemindersConfigColumns.macroTrackingOn.value]! as int == 1,
      macroTrackingReminderTime:
          map[RemindersConfigColumns.macroTrackingReminderTime.value]! as int,
      profileId: map[RemindersConfigColumns.profileId.value]! as int,
      createdAt: map[RemindersConfigColumns.createdAt.value]! as int,
      updatedAt: map[RemindersConfigColumns.updatedAt.value]! as int,
    );
  }

  @override
  RemindersConfig copyWith({
    int? id,
    bool? workoutsOn,
    bool? weightRecordsOn,
    int? workoutsReminderTime,
    int? weightRecordsReminderTime,
    bool? macroTrackingOn,
    int? macroTrackingReminderTime,
    int? profileId,
    int? createdAt,
    int? updatedAt,
  }) {
    return RemindersConfig(
      id: id ?? this.id,
      workoutsOn: workoutsOn ?? this.workoutsOn,
      workoutsReminderTime: workoutsReminderTime ?? this.workoutsReminderTime,
      weightRecordsOn: weightRecordsOn ?? this.weightRecordsOn,
      weightRecordsReminderTime:
          weightRecordsReminderTime ?? this.weightRecordsReminderTime,
      macroTrackingOn: macroTrackingOn ?? this.macroTrackingOn,
      macroTrackingReminderTime:
          macroTrackingReminderTime ?? this.macroTrackingReminderTime,
      profileId: profileId ?? this.profileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory RemindersConfig.create({
    required int profileId,
    required bool workoutsOn,
    required DateTime workoutsReminderTime,
    required bool weightRecordsOn,
    required DateTime weightRecordsReminderTime,
    required bool macroTrackingOn,
    required DateTime macroTrackingReminderTime,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return RemindersConfig(
      profileId: profileId,
      workoutsOn: workoutsOn,
      workoutsReminderTime: DateUtilities.getDateUnix(workoutsReminderTime),
      weightRecordsOn: weightRecordsOn,
      weightRecordsReminderTime: DateUtilities.getDateUnix(
        weightRecordsReminderTime,
      ),
      macroTrackingOn: macroTrackingOn,
      macroTrackingReminderTime: DateUtilities.getDateUnix(
        macroTrackingReminderTime,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutsOn,
    workoutsReminderTime,
    weightRecordsOn,
    weightRecordsReminderTime,
    macroTrackingOn,
    macroTrackingReminderTime,
    profileId,
    createdAt,
    updatedAt,
  ];
}
