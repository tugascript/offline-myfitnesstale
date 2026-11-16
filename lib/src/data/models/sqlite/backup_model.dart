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

import '../../../utils/nullable.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import 'model.dart';

const String _table = 'backups';

enum BackupColumns with Columns {
  id("id"),
  provider("provider"),
  startedAt("started_at"),
  finishedAt("finished_at"),
  path("path"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const BackupColumns(this.value);
}

final class Backup extends Equatable implements Model {
  @override
  final int? id;
  final BackupProvider provider;
  final int startedAt;
  final int? finishedAt;
  final String path;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Backup({
    this.id,
    required this.provider,
    required this.startedAt,
    this.finishedAt,
    required this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
    CREATE TABLE IF NOT EXISTS $_table (
      ${BackupColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${BackupColumns.provider.value} TEXT NOT NULL,
      ${BackupColumns.startedAt.value} INTEGER NOT NULL,
      ${BackupColumns.finishedAt.value} INTEGER,
      ${BackupColumns.path.value} TEXT NOT NULL,
      ${BackupColumns.createdAt.value} INTEGER NOT NULL,
      ${BackupColumns.updatedAt.value} INTEGER NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_backups_provider ON $_table (${BackupColumns.provider.value});
    CREATE INDEX IF NOT EXISTS idx_backups_started_at ON $_table (${BackupColumns.startedAt.value});
    ''';

  @override
  Map<String, Object?> toMap() {
    return {
      BackupColumns.id.value: id,
      BackupColumns.provider.value: provider.value,
      BackupColumns.startedAt.value: startedAt,
      BackupColumns.finishedAt.value: finishedAt,
      BackupColumns.path.value: path,
      BackupColumns.createdAt.value: createdAt,
      BackupColumns.updatedAt.value: updatedAt,
    };
  }

  factory Backup.fromMap(Map<String, Object?> map) {
    return Backup(
      id: map[BackupColumns.id.value] as int?,
      provider: BackupProvider.fromValue(
        map[BackupColumns.provider.value]! as String,
      ),
      startedAt: map[BackupColumns.startedAt.value]! as int,
      finishedAt: map[BackupColumns.finishedAt.value] as int?,
      path: map[BackupColumns.path.value]! as String,
      createdAt: map[BackupColumns.createdAt.value]! as int,
      updatedAt: map[BackupColumns.updatedAt.value]! as int,
    );
  }

  factory Backup.create({
    required BackupProvider provider,
    required String path,
    int? startedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Backup(
      provider: provider,
      startedAt: startedAt ?? now,
      path: path,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Backup copyWith({
    int? id,
    BackupProvider? provider,
    int? startedAt,
    Nullable<int>? finishedAt,
    String? path,
    int? createdAt,
    int? updatedAt,
  }) {
    return Backup(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt != null ? finishedAt.value : this.finishedAt,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    provider,
    startedAt,
    finishedAt,
    path,
    createdAt,
    updatedAt,
  ];
}
