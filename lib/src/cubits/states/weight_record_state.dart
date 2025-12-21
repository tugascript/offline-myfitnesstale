import 'package:equatable/equatable.dart';

import '../../models/weight_record_model.dart';

final class WeightRecordPagination extends Equatable {
  final int limit;
  final int offset;

  const WeightRecordPagination({
    required this.limit,
    required this.offset,
  });

  factory WeightRecordPagination.initial() {
    return const WeightRecordPagination(
      limit: 7,
      offset: 0,
    );
  }

  WeightRecordPagination copyWith({int? limit, int? offset}) {
    return WeightRecordPagination(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        limit,
        offset,
      ];
}

final class WeightRecordState extends Equatable {
  final List<WeightRecord> weightRecords;
  final WeightRecord? selectedWeightRecord;
  final WeightRecord? latestWeightRecord;
  final WeightRecordPagination pagination;
  final int weightTotal;
  final bool isLoading;
  final String? error;

  const WeightRecordState({
    required this.weightRecords,
    this.selectedWeightRecord,
    this.latestWeightRecord,
    required this.pagination,
    required this.isLoading,
    required this.weightTotal,
    this.error,
  });

  factory WeightRecordState.initial() {
    return WeightRecordState(
      weightRecords: [],
      pagination: WeightRecordPagination.initial(),
      isLoading: false,
      weightTotal: 0,
    );
  }

  WeightRecordState copyWith({
    List<WeightRecord>? weightRecords,
    WeightRecord? selectedWeightRecord,
    WeightRecord? latestWeightRecord,
    WeightRecordPagination? pagination,
    bool? isLoading,
    String? error,
    int? weightTotal,
  }) {
    return WeightRecordState(
      weightRecords: weightRecords ?? this.weightRecords,
      selectedWeightRecord: selectedWeightRecord ?? this.selectedWeightRecord,
      latestWeightRecord: latestWeightRecord ?? this.latestWeightRecord,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      weightTotal: weightTotal ?? this.weightTotal,
    );
  }

  @override
  List<Object?> get props => [
        weightRecords,
        selectedWeightRecord,
        latestWeightRecord,
        pagination,
        weightTotal,
        isLoading,
        error,
      ];
}
