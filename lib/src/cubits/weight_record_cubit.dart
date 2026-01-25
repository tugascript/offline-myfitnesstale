import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
import '../services/weight_record_service.dart';
import 'states/common_state.dart';
import 'states/weight_record_state.dart';

class WeightRecordCubit extends Cubit<WeightRecordState> {
  final WeightRecordService _weightRecordService = WeightRecordService();
  final Logger _logger = Logger("WeightRecordCubit");

  WeightRecordCubit() : super(WeightRecordState.initial());

  Future<void> getWeightRecords({
    required int limit,
    required int offset,
  }) async {
    _logger.info("Getting weight records");
    emit(state.copyWith(isLoading: true));
    _logger.info("Fetching paginated weight records");
    final result = await _weightRecordService.getWeightRecords(
      limit: limit,
      offset: offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get weight records", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get weight records",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final paginatedData = result.value;
    final weightRecords = paginatedData.data;

    emit(state.copyWith(
      weightRecords: offset >= state.recordPagination.offset + limit
          ? [...state.weightRecords, ...weightRecords]
          : weightRecords,
      recordPagination: state.recordPagination.copyWith(
        limit: limit,
        offset: offset,
        total: paginatedData.total,
      ),
      isLoading: false,
    ));
  }

  Future<void> getLatestRecordedWeightRecord() async {
    _logger.info("Getting latest weight record");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.getLatestRecorded();
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch latest weight record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            latestWeightRecord: null,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get latest weight record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      latestWeightRecord: result.value,
      isLoading: false,
    ));
  }

  Future<void> createWeightRecord({
    required int weight,
    required DateTime date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightRecord(
      weight: weight,
      date: date,
      fatPercentage: fatPercentage,
      pictureUri: pictureUri,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create weight record", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create weight record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final weightRecord = result.value;
    emit(state.copyWith(
      weightRecords: [weightRecord, ...state.weightRecords],
      selectedWeightRecord: weightRecord,
      recordPagination: state.recordPagination.copyWith(
        total: state.recordPagination.total + 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> updateWeightRecord({
    required int id,
    int? weight,
    DateTime? date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightRecord(
      id: id,
      weight: weight,
      date: date,
      fatPercentage: fatPercentage,
      pictureUri: pictureUri,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update weight record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to update weight record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Weight record updated successfully");
    final weightRecord = result.value;
    emit(state.copyWith(
      weightRecords: state.weightRecords
          .map((w) => w.id == weightRecord.id ? weightRecord : w)
          .toList(),
      selectedWeightRecord: weightRecord,
      isLoading: false,
    ));
  }

  Future<void> deleteWeightRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightRecord(id);
    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to delete weight record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      weightRecords: state.weightRecords.where((w) => w.id != id).toList(),
      selectedWeightRecord: state.selectedWeightRecord?.id == id
          ? null
          : state.selectedWeightRecord,
      recordPagination: state.recordPagination.copyWith(
        total: state.recordPagination.total - 1,
      ),
      isLoading: false,
    ));
  }
}
