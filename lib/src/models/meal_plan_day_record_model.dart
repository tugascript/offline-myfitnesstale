import 'package:equatable/equatable.dart';

import 'daily_nutrition_log_model.dart';
import 'enums.dart';
import 'meal_plan_day_model.dart';
import 'meal_plan_record_model.dart';
import 'meal_plan_week_record_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_day_records';

enum MealPlanDayRecordColumns with Columns {
  id("id"),
  mealPlanRecordId("meal_plan_record_id"),
  mealPlanWeekRecordId("meal_plan_week_record_id"),
  mealPlanDayId("meal_plan_day_id"),
  dailyLogId("daily_log_id"),
  week("week"),
  day("day"),
  status("status"),
  totalCalories("total_calories"),
  totalProtein("total_protein"),
  totalCarbs("total_carbs"),
  totalFat("total_fat"),
  totalFiber("total_fiber"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanDayRecordColumns(this.value);
}

class MealPlanDayRecord extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanRecordId;
  final int mealPlanWeekRecordId;
  final int mealPlanDayId;
  final int dailyLogId;
  final int week;
  final int day;
  final ProgressStatus status;
  final int? completedAt;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanDayRecord({
    this.id,
    required this.mealPlanRecordId,
    required this.mealPlanWeekRecordId,
    required this.mealPlanDayId,
    required this.dailyLogId,
    required this.week,
    required this.day,
    required this.status,
    this.completedAt,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(week >= 1 && week <= 52, 'week must be between 1 and 52'),
        assert(day >= 1 && day <= 7, 'day must be between 1 and 7');

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanDayRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanDayRecordColumns.mealPlanRecordId.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.mealPlanDayId.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.dailyLogId.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.week.value} INTEGER NOT NULL CHECK (${MealPlanDayRecordColumns.week.value} >= 1 AND ${MealPlanDayRecordColumns.week.value} <= 52),
    ${MealPlanDayRecordColumns.day.value} INTEGER NOT NULL CHECK (${MealPlanDayRecordColumns.day.value} >= 1 AND ${MealPlanDayRecordColumns.day.value} <= 7),
    ${MealPlanDayRecordColumns.status.value} TEXT NOT NULL,
    ${MealPlanDayRecordColumns.completedAt.value} INTEGER,
    ${MealPlanDayRecordColumns.totalCalories.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.totalProtein.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.totalCarbs.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.totalFat.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.totalFiber.value} INTEGER,
    ${MealPlanDayRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanDayRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanDayRecordColumns.mealPlanRecordId.value}) REFERENCES ${MealPlanRecord.table} (${MealPlanRecordColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanDayRecordColumns.mealPlanWeekRecordId.value}) REFERENCES ${MealPlanWeekRecord.table} (${MealPlanWeekRecordColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanDayRecordColumns.mealPlanDayId.value}) REFERENCES ${MealPlanDay.table} (${MealPlanDayColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanDayRecordColumns.dailyLogId.value}) REFERENCES ${DailyNutritionLog.table} (${DailyNutritionLogColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_day_records_record_id ON $_table (${MealPlanDayRecordColumns.mealPlanRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_day_records_week_record_id ON $_table (${MealPlanDayRecordColumns.mealPlanWeekRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_day_records_day_id ON $_table (${MealPlanDayRecordColumns.mealPlanDayId.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plan_day_records_day ON $_table (${MealPlanDayRecordColumns.mealPlanWeekRecordId.value}, ${MealPlanDayRecordColumns.day.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plan_day_records_daily_log ON $_table (${MealPlanDayRecordColumns.dailyLogId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanDayRecordColumns.id.value: id,
      MealPlanDayRecordColumns.mealPlanRecordId.value: mealPlanRecordId,
      MealPlanDayRecordColumns.mealPlanWeekRecordId.value: mealPlanWeekRecordId,
      MealPlanDayRecordColumns.mealPlanDayId.value: mealPlanDayId,
      MealPlanDayRecordColumns.dailyLogId.value: dailyLogId,
      MealPlanDayRecordColumns.week.value: week,
      MealPlanDayRecordColumns.day.value: day,
      MealPlanDayRecordColumns.status.value: status.value,
      MealPlanDayRecordColumns.completedAt.value: completedAt,
      MealPlanDayRecordColumns.totalCalories.value: totalCalories,
      MealPlanDayRecordColumns.totalProtein.value: totalProtein,
      MealPlanDayRecordColumns.totalCarbs.value: totalCarbs,
      MealPlanDayRecordColumns.totalFat.value: totalFat,
      MealPlanDayRecordColumns.totalFiber.value: totalFiber,
      MealPlanDayRecordColumns.createdAt.value: createdAt,
      MealPlanDayRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanDayRecord.fromMap(Map<String, Object?> map) {
    return MealPlanDayRecord(
      id: map[MealPlanDayRecordColumns.id.value] as int?,
      mealPlanRecordId:
          map[MealPlanDayRecordColumns.mealPlanRecordId.value] as int,
      mealPlanWeekRecordId:
          map[MealPlanDayRecordColumns.mealPlanWeekRecordId.value] as int,
      mealPlanDayId: map[MealPlanDayRecordColumns.mealPlanDayId.value] as int,
      dailyLogId: map[MealPlanDayRecordColumns.dailyLogId.value] as int,
      week: map[MealPlanDayRecordColumns.week.value] as int,
      day: map[MealPlanDayRecordColumns.day.value] as int,
      status: ProgressStatus.fromValue(
        map[MealPlanDayRecordColumns.status.value] as String,
      ),
      completedAt: map[MealPlanDayRecordColumns.completedAt.value] as int?,
      totalCalories: map[MealPlanDayRecordColumns.totalCalories.value] as int,
      totalProtein: map[MealPlanDayRecordColumns.totalProtein.value] as int,
      totalCarbs: map[MealPlanDayRecordColumns.totalCarbs.value] as int,
      totalFat: map[MealPlanDayRecordColumns.totalFat.value] as int,
      totalFiber: map[MealPlanDayRecordColumns.totalFiber.value] as int?,
      createdAt: map[MealPlanDayRecordColumns.createdAt.value] as int,
      updatedAt: map[MealPlanDayRecordColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanDayRecord.create({
    required int mealPlanRecordId,
    required int mealPlanWeekRecordId,
    required int mealPlanDayId,
    required int dailyLogId,
    required int week,
    required int day,
    required int totalCalories,
    required int totalProtein,
    required int totalCarbs,
    required int totalFat,
    int? totalFiber,
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanDayRecord(
      mealPlanRecordId: mealPlanRecordId,
      mealPlanWeekRecordId: mealPlanWeekRecordId,
      mealPlanDayId: mealPlanDayId,
      dailyLogId: dailyLogId,
      week: week,
      day: day,
      status: status,
      completedAt: completedAt,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanDayRecord copyWith({
    int? id,
    int? mealPlanRecordId,
    int? mealPlanWeekRecordId,
    int? mealPlanDayId,
    int? dailyLogId,
    int? week,
    int? day,
    ProgressStatus? status,
    int? completedAt,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    int? totalFiber,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanDayRecord(
      id: id ?? this.id,
      mealPlanRecordId: mealPlanRecordId ?? this.mealPlanRecordId,
      mealPlanWeekRecordId: mealPlanWeekRecordId ?? this.mealPlanWeekRecordId,
      mealPlanDayId: mealPlanDayId ?? this.mealPlanDayId,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      week: week ?? this.week,
      day: day ?? this.day,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealPlanRecordId,
        mealPlanWeekRecordId,
        mealPlanDayId,
        dailyLogId,
        week,
        day,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        totalFiber,
        status,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
