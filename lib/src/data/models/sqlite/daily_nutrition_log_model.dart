// Copyright (C) 2026 afonsobarracha
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

import 'model.dart';
import '../../utils/dates.dart';

const String _table = 'daily_nutrition_logs';

enum DailyNutritionLogColumns with Columns {
  id("id"),
  date("date"),
  waterIntakeMl("water_intake_ml"),
  notes("notes"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const DailyNutritionLogColumns(this.value);
}

class DailyNutritionLog extends Equatable implements Model {
  @override
  final int? id;

  /// Numeric date in YYYYMMDD format (e.g. 20261007) for timezone-aware daily lookups.
  final int date;
  final int waterIntakeMl;
  final String? notes;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const DailyNutritionLog({
    this.id,
    required this.date,
    this.waterIntakeMl = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${DailyNutritionLogColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DailyNutritionLogColumns.date.value} INTEGER NOT NULL,
    ${DailyNutritionLogColumns.waterIntakeMl.value} INTEGER NOT NULL DEFAULT 0,
    ${DailyNutritionLogColumns.notes.value} TEXT,
    ${DailyNutritionLogColumns.createdAt.value} INTEGER NOT NULL,
    ${DailyNutritionLogColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_nutrition_logs_date ON $_table (${DailyNutritionLogColumns.date.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      DailyNutritionLogColumns.id.value: id,
      DailyNutritionLogColumns.date.value: date,
      DailyNutritionLogColumns.waterIntakeMl.value: waterIntakeMl,
      DailyNutritionLogColumns.notes.value: notes,
      DailyNutritionLogColumns.createdAt.value: createdAt,
      DailyNutritionLogColumns.updatedAt.value: updatedAt,
    };
  }

  factory DailyNutritionLog.fromMap(Map<String, Object?> map) {
    return DailyNutritionLog(
      id: map[DailyNutritionLogColumns.id.value] as int?,
      date: map[DailyNutritionLogColumns.date.value] as int,
      waterIntakeMl:
          map[DailyNutritionLogColumns.waterIntakeMl.value] as int? ?? 0,
      notes: map[DailyNutritionLogColumns.notes.value] as String?,
      createdAt: map[DailyNutritionLogColumns.createdAt.value] as int,
      updatedAt: map[DailyNutritionLogColumns.updatedAt.value] as int,
    );
  }

  factory DailyNutritionLog.create({
    int? date,
    int waterIntakeMl = 0,
    String? notes,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return DailyNutritionLog(
      date: date ?? DateUtilities.getNumericDate(DateTime.now()),
      waterIntakeMl: waterIntakeMl,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  DailyNutritionLog copyWith({
    Nullable<int>? id,
    int? date,
    int? waterIntakeMl,
    Nullable<String>? notes,
    int? createdAt,
    int? updatedAt,
  }) {
    return DailyNutritionLog(
      id: id != null ? id.value : this.id,
      date: date ?? this.date,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      notes: notes != null ? notes.value : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    waterIntakeMl,
    notes,
    createdAt,
    updatedAt,
  ];
}
