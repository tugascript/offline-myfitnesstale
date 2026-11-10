import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';

import '../../../utils/enums.dart';
import '../../../models/meal_plan_day_record_model.dart';
import '../../../models/meal_plan_record_model.dart';
import '../../../models/meal_plan_week_record_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';

class MealPlanDayRecordDto extends Equatable implements Dto<MealPlanDayRecord> {
  @override
  final int id;
  final int mealPlanRecordId;
  final int mealPlanWeekRecordId;
  final int mealPlanDayId;
  final int dailyLogId;
  final int week;
  final int day;
  final ProgressStatus status;
  final DateTime? completedAt;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;

  const MealPlanDayRecordDto({
    required this.id,
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
  });

  factory MealPlanDayRecordDto.fromModel(MealPlanDayRecord model) {
    return MealPlanDayRecordDto(
      id: model.id!,
      mealPlanRecordId: model.mealPlanRecordId,
      mealPlanWeekRecordId: model.mealPlanWeekRecordId,
      mealPlanDayId: model.mealPlanDayId,
      dailyLogId: model.dailyLogId,
      week: model.week,
      day: model.day,
      status: model.status,
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      totalCalories: model.totalCalories,
      totalProtein: model.totalProtein,
      totalCarbs: model.totalCarbs,
      totalFat: model.totalFat,
      totalFiber: model.totalFiber,
    );
  }

  @override
  MealPlanDayRecordDto copyWith({
    int? id,
    int? mealPlanRecordId,
    int? mealPlanWeekRecordId,
    int? mealPlanDayId,
    int? dailyLogId,
    int? week,
    int? day,
    ProgressStatus? status,
    Nullable<DateTime>? completedAt,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
  }) {
    return MealPlanDayRecordDto(
      id: id ?? this.id,
      mealPlanRecordId: mealPlanRecordId ?? this.mealPlanRecordId,
      mealPlanWeekRecordId: mealPlanWeekRecordId ?? this.mealPlanWeekRecordId,
      mealPlanDayId: mealPlanDayId ?? this.mealPlanDayId,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      week: week ?? this.week,
      day: day ?? this.day,
      status: status ?? this.status,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
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
    status,
    completedAt,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
  ];
}

class MealPlanWeekRecordDto extends Equatable
    implements Dto<MealPlanWeekRecord> {
  @override
  final int id;
  final int mealPlanRecordId;
  final int mealPlanWeekId;
  final int week;
  final ProgressStatus status;
  final int currentDay;
  final DateTime? completedAt;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  final List<MealPlanDayRecordDto> days;

  const MealPlanWeekRecordDto({
    required this.id,
    required this.mealPlanRecordId,
    required this.mealPlanWeekId,
    required this.week,
    required this.status,
    required this.currentDay,
    this.completedAt,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    this.days = const [],
  });

  factory MealPlanWeekRecordDto.fromModel(
    MealPlanWeekRecord model, {
    List<MealPlanDayRecordDto> days = const [],
  }) {
    return MealPlanWeekRecordDto(
      id: model.id!,
      mealPlanRecordId: model.mealPlanRecordId,
      mealPlanWeekId: model.mealPlanWeekId,
      week: model.week,
      status: model.status,
      currentDay: model.currentDay,
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      totalCalories: model.totalCalories,
      totalProtein: model.totalProtein,
      totalCarbs: model.totalCarbs,
      totalFat: model.totalFat,
      totalFiber: model.totalFiber,
      days: days,
    );
  }

  @override
  MealPlanWeekRecordDto copyWith({
    int? id,
    int? mealPlanRecordId,
    int? mealPlanWeekId,
    int? week,
    ProgressStatus? status,
    int? currentDay,
    Nullable<DateTime>? completedAt,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    List<MealPlanDayRecordDto>? days,
  }) {
    return MealPlanWeekRecordDto(
      id: id ?? this.id,
      mealPlanRecordId: mealPlanRecordId ?? this.mealPlanRecordId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      week: week ?? this.week,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
    id,
    mealPlanRecordId,
    mealPlanWeekId,
    week,
    status,
    currentDay,
    completedAt,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    days,
  ];
}

class MealPlanRecordDto extends Equatable implements Dto<MealPlanRecord> {
  @override
  final int id;
  final int mealPlanId;
  final int mealPlanVersion;
  final ProgressStatus status;
  final DateTime startedAt;
  final int currentWeek;
  final int currentDay;
  final DateTime? completedAt;
  final String? planName;
  final int totalWeeks;
  final int totalDays;
  final List<MealPlanWeekRecordDto> weeks;

  const MealPlanRecordDto({
    required this.id,
    required this.mealPlanId,
    required this.mealPlanVersion,
    required this.status,
    required this.startedAt,
    required this.currentWeek,
    required this.currentDay,
    this.completedAt,
    this.planName,
    this.totalWeeks = 1,
    this.totalDays = 7,
    this.weeks = const [],
  });

  factory MealPlanRecordDto.fromModel(
    MealPlanRecord model, {
    String? planName,
    int totalWeeks = 1,
    int totalDays = 7,
    List<MealPlanWeekRecordDto> weeks = const [],
  }) {
    return MealPlanRecordDto(
      id: model.id!,
      mealPlanId: model.mealPlanId,
      mealPlanVersion: model.mealPlanVersion,
      status: model.status,
      startedAt: DateUtilities.getDateFromUnix(model.startedAt),
      currentWeek: model.currentWeek,
      currentDay: model.currentDay,
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      planName: planName,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      weeks: weeks,
    );
  }

  @override
  MealPlanRecordDto copyWith({
    int? id,
    int? mealPlanId,
    int? mealPlanVersion,
    ProgressStatus? status,
    DateTime? startedAt,
    int? currentWeek,
    int? currentDay,
    Nullable<DateTime>? completedAt,
    Nullable<String>? planName,
    int? totalWeeks,
    int? totalDays,
    List<MealPlanWeekRecordDto>? weeks,
  }) {
    return MealPlanRecordDto(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanVersion: mealPlanVersion ?? this.mealPlanVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      planName: planName != null ? planName.value : this.planName,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      totalDays: totalDays ?? this.totalDays,
      weeks: weeks ?? this.weeks,
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
    planName,
    totalWeeks,
    totalDays,
    weeks,
  ];
}
