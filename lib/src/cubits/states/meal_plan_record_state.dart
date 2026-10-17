import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../services/dtos/meal_plan_record_dto.dart';
import 'common_state.dart';

final class MealPlanRecordPagination extends Equatable {
  final int? mealPlanId;
  final ProgressStatus? status;
  final int total;
  final int limit;
  final int offset;
  const MealPlanRecordPagination({
    this.mealPlanId,
    this.status,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });
  factory MealPlanRecordPagination.initial() =>
      const MealPlanRecordPagination();
  MealPlanRecordPagination copyWith({
    Nullable<int>? mealPlanId,
    Nullable<ProgressStatus>? status,
    int? total,
    int? limit,
    int? offset,
  }) {
    return MealPlanRecordPagination(
      mealPlanId: mealPlanId != null ? mealPlanId.value : this.mealPlanId,
      status: status != null ? status.value : this.status,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [mealPlanId, status, total, limit, offset];
}

final class MealPlanRecordState extends Equatable {
  final List<MealPlanRecordDto> records;
  final MealPlanRecordDto? activeRecord;
  final MealPlanRecordPagination mealPlanRecordPagination;
  final bool isLoading;
  final ErrorState? error;
  const MealPlanRecordState({
    this.records = const [],
    this.activeRecord,
    this.mealPlanRecordPagination = const MealPlanRecordPagination(),
    this.isLoading = false,
    this.error,
  });
  factory MealPlanRecordState.initial() => const MealPlanRecordState();
  MealPlanRecordState copyWith({
    List<MealPlanRecordDto>? records,
    Nullable<MealPlanRecordDto>? activeRecord,
    MealPlanRecordPagination? mealPlanRecordPagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) => MealPlanRecordState(
    records: records ?? this.records,
    activeRecord: activeRecord != null ? activeRecord.value : this.activeRecord,
    mealPlanRecordPagination:
        mealPlanRecordPagination ?? this.mealPlanRecordPagination,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
  );
  @override
  List<Object?> get props => [
    records,
    activeRecord,
    mealPlanRecordPagination,
    isLoading,
    error,
  ];
}
