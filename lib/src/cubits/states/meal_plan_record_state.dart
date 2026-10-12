import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/meal_plan_record_dto.dart';
import 'common_state.dart';

final class MealPlanRecordState extends Equatable {
  final MealPlanRecordDto? activeRecord;
  final List<MealPlanRecordDto> records;
  final int total;
  final int limit;
  final int offset;
  final bool isLoading;
  final ErrorState? error;

  const MealPlanRecordState({
    this.activeRecord,
    this.records = const [],
    required this.total,
    required this.limit,
    required this.offset,
    required this.isLoading,
    this.error,
  });

  factory MealPlanRecordState.initial() {
    return const MealPlanRecordState(
      records: [],
      total: 0,
      limit: 20,
      offset: 0,
      isLoading: false,
    );
  }

  MealPlanRecordState copyWith({
    Nullable<MealPlanRecordDto>? activeRecord,
    List<MealPlanRecordDto>? records,
    int? total,
    int? limit,
    int? offset,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return MealPlanRecordState(
      activeRecord:
          activeRecord != null ? activeRecord.value : this.activeRecord,
      records: records ?? this.records,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        activeRecord,
        records,
        total,
        limit,
        offset,
        isLoading,
        error,
      ];
}
