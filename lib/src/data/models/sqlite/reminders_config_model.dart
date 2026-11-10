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

import 'model.dart';
import 'profile_model.dart';
import '../../utils/dates.dart';

const String _table = 'reminders_configs';

enum RemindersConfigColumns {
  id("id"),
  workoutsOn("workouts_on"),
  weightRecordsOn("weight_records_on"),
  profileId("profile_id"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const RemindersConfigColumns(this.value);
}

class RemindersConfig extends Equatable implements Model {
  @override
  final int? id;
  final bool workoutsOn;
  final bool weightRecordsOn;
  final int profileId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const RemindersConfig({
    this.id,
    required this.workoutsOn,
    required this.weightRecordsOn,
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
      ${RemindersConfigColumns.weightRecordsOn.value} INTEGER NOT NULL,
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
      RemindersConfigColumns.weightRecordsOn.value: weightRecordsOn ? 1 : 0,
      RemindersConfigColumns.profileId.value: profileId,
      RemindersConfigColumns.createdAt.value: createdAt,
      RemindersConfigColumns.updatedAt.value: updatedAt,
    };
  }

  factory RemindersConfig.fromMap(Map<String, Object?> map) {
    return RemindersConfig(
      id: map[RemindersConfigColumns.id.value] as int?,
      workoutsOn: map[RemindersConfigColumns.workoutsOn.value]! as int == 1,
      weightRecordsOn:
          map[RemindersConfigColumns.weightRecordsOn.value]! as int == 1,
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
    int? profileId,
    int? createdAt,
    int? updatedAt,
  }) {
    return RemindersConfig(
      id: id ?? this.id,
      workoutsOn: workoutsOn ?? this.workoutsOn,
      weightRecordsOn: weightRecordsOn ?? this.weightRecordsOn,
      profileId: profileId ?? this.profileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory RemindersConfig.create({
    required int profileId,
    required bool workoutsOn,
    required bool weightRecordsOn,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return RemindersConfig(
      workoutsOn: workoutsOn,
      weightRecordsOn: weightRecordsOn,
      profileId: profileId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutsOn,
    weightRecordsOn,
    profileId,
    createdAt,
    updatedAt,
  ];
}
