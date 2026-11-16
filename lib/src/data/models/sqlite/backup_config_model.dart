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
import '../../utils/enums.dart';
import 'model.dart';

const String _table = 'backup_configs';

enum BackupConfigColumns with Columns {
  id("id"),
  provider("provider"),
  schedule("schedule"),
  encrypted("encrypted"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const BackupConfigColumns(this.value);
}

final class BackupConfig extends Equatable implements Model {
  @override
  final int? id;
  final BackupProvider provider;
  final BackupSchedule schedule;
  final bool encrypted;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const BackupConfig({
    this.id,
    required this.provider,
    required this.schedule,
    required this.encrypted,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
    CREATE TABLE IF NOT EXISTS $_table (
      ${BackupConfigColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${BackupConfigColumns.provider.value} TEXT NOT NULL,
      ${BackupConfigColumns.schedule.value} TEXT NOT NULL,
      ${BackupConfigColumns.encrypted.value} INTEGER NOT NULL DEFAULT 0,
      ${BackupConfigColumns.createdAt.value} INTEGER NOT NULL,
      ${BackupConfigColumns.updatedAt.value} INTEGER NOT NULL
    );
    ''';

  @override
  Map<String, Object?> toMap() {
    return {
      BackupConfigColumns.id.value: id,
      BackupConfigColumns.provider.value: provider.value,
      BackupConfigColumns.schedule.value: schedule.value,
      BackupConfigColumns.encrypted.value: encrypted ? 1 : 0,
      BackupConfigColumns.createdAt.value: createdAt,
      BackupConfigColumns.updatedAt.value: updatedAt,
    };
  }

  factory BackupConfig.fromMap(Map<String, Object?> map) {
    return BackupConfig(
      id: map[BackupConfigColumns.id.value] as int?,
      provider: BackupProvider.fromValue(
        map[BackupConfigColumns.provider.value]! as String,
      ),
      schedule: BackupSchedule.fromValue(
        map[BackupConfigColumns.schedule.value]! as String,
      ),
      encrypted: map[BackupConfigColumns.encrypted.value]! as int == 1,
      createdAt: map[BackupConfigColumns.createdAt.value]! as int,
      updatedAt: map[BackupConfigColumns.updatedAt.value]! as int,
    );
  }

  factory BackupConfig.create({
    required BackupProvider provider,
    required BackupSchedule schedule,
    required bool encrypted,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return BackupConfig(
      provider: provider,
      schedule: schedule,
      encrypted: encrypted,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  BackupConfig copyWith({
    int? id,
    BackupProvider? provider,
    BackupSchedule? schedule,
    bool? encrypted,
    int? createdAt,
    int? updatedAt,
  }) {
    return BackupConfig(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      schedule: schedule ?? this.schedule,
      encrypted: encrypted ?? this.encrypted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    provider,
    schedule,
    encrypted,
    createdAt,
    updatedAt,
  ];
}
