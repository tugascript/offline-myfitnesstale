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

const String _table = 'migrations';

enum MigrationColumns with Columns {
  id("id"),
  version("version"),
  name("name"),
  status("status"),
  direction("direction"),
  appliedAt("applied_at"),
  rolledBackAt("rolled_back_at"),
  failedAt("failed_at"),
  failure("failure"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MigrationColumns(this.value);
}

final class Migration extends Equatable implements Model {
  @override
  final int? id;
  final int version;
  final String name;
  final MigrationStatus status;
  final MigrationDirection direction;
  final int? appliedAt;
  final int? rolledBackAt;
  final int? failedAt;
  final String? failure;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Migration({
    this.id,
    required this.version,
    required this.name,
    required this.status,
    required this.direction,
    this.appliedAt,
    this.rolledBackAt,
    this.failedAt,
    this.failure,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
    CREATE TABLE IF NOT EXISTS $_table (
      ${MigrationColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${MigrationColumns.version.value} INTEGER NOT NULL,
      ${MigrationColumns.name.value} TEXT NOT NULL,
      ${MigrationColumns.status.value} TEXT NOT NULL,
      ${MigrationColumns.direction.value} TEXT NOT NULL,
      ${MigrationColumns.appliedAt.value} INTEGER,
      ${MigrationColumns.rolledBackAt.value} INTEGER,
      ${MigrationColumns.failedAt.value} INTEGER,
      ${MigrationColumns.failure.value} TEXT,
      ${MigrationColumns.createdAt.value} INTEGER NOT NULL,
      ${MigrationColumns.updatedAt.value} INTEGER NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_migrations_version ON $_table (${MigrationColumns.version.value});
    CREATE INDEX IF NOT EXISTS idx_migrations_status ON $_table (${MigrationColumns.status.value});
    ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MigrationColumns.id.value: id,
      MigrationColumns.version.value: version,
      MigrationColumns.name.value: name,
      MigrationColumns.status.value: status.value,
      MigrationColumns.direction.value: direction.value,
      MigrationColumns.appliedAt.value: appliedAt,
      MigrationColumns.rolledBackAt.value: rolledBackAt,
      MigrationColumns.failedAt.value: failedAt,
      MigrationColumns.failure.value: failure,
      MigrationColumns.createdAt.value: createdAt,
      MigrationColumns.updatedAt.value: updatedAt,
    };
  }

  factory Migration.fromMap(Map<String, Object?> map) {
    return Migration(
      id: map[MigrationColumns.id.value] as int?,
      version: map[MigrationColumns.version.value]! as int,
      name: map[MigrationColumns.name.value]! as String,
      status: MigrationStatus.fromValue(
        map[MigrationColumns.status.value]! as String,
      ),
      direction: MigrationDirection.fromValue(
        map[MigrationColumns.direction.value]! as String,
      ),
      appliedAt: map[MigrationColumns.appliedAt.value] as int?,
      rolledBackAt: map[MigrationColumns.rolledBackAt.value] as int?,
      failedAt: map[MigrationColumns.failedAt.value] as int?,
      failure: map[MigrationColumns.failure.value] as String?,
      createdAt: map[MigrationColumns.createdAt.value]! as int,
      updatedAt: map[MigrationColumns.updatedAt.value]! as int,
    );
  }

  factory Migration.create({
    required int version,
    required String name,
    required MigrationStatus status,
    required MigrationDirection direction,
    int? appliedAt,
    int? rolledBackAt,
    int? failedAt,
    String? failure,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Migration(
      version: version,
      name: name,
      status: status,
      direction: direction,
      appliedAt: appliedAt,
      rolledBackAt: rolledBackAt,
      failedAt: failedAt,
      failure: failure,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Migration copyWith({
    Nullable<int>? id,
    int? version,
    String? name,
    MigrationStatus? status,
    MigrationDirection? direction,
    Nullable<int>? appliedAt,
    Nullable<int>? rolledBackAt,
    Nullable<int>? failedAt,
    Nullable<String>? failure,
    int? createdAt,
    int? updatedAt,
  }) {
    return Migration(
      id: id != null ? id.value : this.id,
      version: version ?? this.version,
      name: name ?? this.name,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      appliedAt: appliedAt != null ? appliedAt.value : this.appliedAt,
      rolledBackAt: rolledBackAt != null
          ? rolledBackAt.value
          : this.rolledBackAt,
      failedAt: failedAt != null ? failedAt.value : this.failedAt,
      failure: failure != null ? failure.value : this.failure,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    version,
    name,
    status,
    direction,
    appliedAt,
    rolledBackAt,
    failedAt,
    failure,
    createdAt,
    updatedAt,
  ];
}
