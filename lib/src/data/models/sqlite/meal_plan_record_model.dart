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

import '../../../utils/nullable.dart';

import 'package:equatable/equatable.dart';

import '../../utils/enums.dart';
import 'meal_plan_model.dart';
import 'model.dart';
import '../../utils/dates.dart';

const String _table = 'meal_plan_records';

enum MealPlanRecordColumns with Columns {
  id("id"),
  mealPlanId("meal_plan_id"),
  mealPlanVersion("meal_plan_version"),
  status("status"),
  startedAt("started_at"),
  currentWeek("current_week"),
  currentDay("current_day"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanRecordColumns(this.value);
}

class MealPlanRecord extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanId;
  final int mealPlanVersion;
  final ProgressStatus status;
  final int startedAt;
  final int currentWeek;
  final int currentDay;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanRecord({
    this.id,
    required this.mealPlanId,
    this.mealPlanVersion = 1,
    required this.status,
    required this.startedAt,
    this.currentWeek = 1,
    this.currentDay = 1,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanRecordColumns.mealPlanId.value} INTEGER NOT NULL,
    ${MealPlanRecordColumns.mealPlanVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanRecordColumns.status.value} TEXT NOT NULL,
    ${MealPlanRecordColumns.startedAt.value} INTEGER NOT NULL,
    ${MealPlanRecordColumns.currentWeek.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanRecordColumns.currentDay.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanRecordColumns.completedAt.value} INTEGER,
    ${MealPlanRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanRecordColumns.mealPlanId.value}) REFERENCES ${MealPlan.table} (${MealPlanColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_records_status ON $_table (${MealPlanRecordColumns.status.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_records_meal_plan_id ON $_table (${MealPlanRecordColumns.mealPlanId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanRecordColumns.id.value: id,
      MealPlanRecordColumns.mealPlanId.value: mealPlanId,
      MealPlanRecordColumns.mealPlanVersion.value: mealPlanVersion,
      MealPlanRecordColumns.status.value: status.value,
      MealPlanRecordColumns.startedAt.value: startedAt,
      MealPlanRecordColumns.currentWeek.value: currentWeek,
      MealPlanRecordColumns.currentDay.value: currentDay,
      MealPlanRecordColumns.completedAt.value: completedAt,
      MealPlanRecordColumns.createdAt.value: createdAt,
      MealPlanRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanRecord.fromMap(Map<String, Object?> map) {
    return MealPlanRecord(
      id: map[MealPlanRecordColumns.id.value] as int?,
      mealPlanId: map[MealPlanRecordColumns.mealPlanId.value] as int,
      mealPlanVersion:
          map[MealPlanRecordColumns.mealPlanVersion.value] as int? ?? 1,
      status: ProgressStatus.fromValue(
        map[MealPlanRecordColumns.status.value] as String,
      ),
      startedAt: map[MealPlanRecordColumns.startedAt.value] as int,
      currentWeek: map[MealPlanRecordColumns.currentWeek.value] as int? ?? 1,
      currentDay: map[MealPlanRecordColumns.currentDay.value] as int? ?? 1,
      completedAt: map[MealPlanRecordColumns.completedAt.value] as int?,
      createdAt: map[MealPlanRecordColumns.createdAt.value] as int,
      updatedAt: map[MealPlanRecordColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanRecord.create({
    required int mealPlanId,
    int mealPlanVersion = 1,
    ProgressStatus status = ProgressStatus.inProgress,
    int? startedAt,
    int currentWeek = 1,
    int currentDay = 1,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanRecord(
      mealPlanId: mealPlanId,
      mealPlanVersion: mealPlanVersion,
      status: status,
      startedAt: startedAt ?? now,
      currentWeek: currentWeek,
      currentDay: currentDay,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanRecord copyWith({
    Nullable<int>? id,
    int? mealPlanId,
    int? mealPlanVersion,
    ProgressStatus? status,
    int? startedAt,
    int? currentWeek,
    int? currentDay,
    Nullable<int>? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanRecord(
      id: id != null ? id.value : this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanVersion: mealPlanVersion ?? this.mealPlanVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    mealPlanId,
    mealPlanVersion,
    status,
    startedAt,
    currentWeek,
    currentDay,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
