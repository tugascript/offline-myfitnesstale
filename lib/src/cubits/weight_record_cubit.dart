import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/weight_record_service.dart';
import 'states/weight_record_state.dart';

class WeightRecordCubit extends Cubit<WeightRecordState> {
  final WeightRecordService _weightRecordService = WeightRecordService();
  final Logger _logger = Logger("WeightRecordCubit");

  WeightRecordCubit() : super(WeightRecordState.initial());

  Future<void> getWeightRecords({
    required int limit,
    required int offset,
  }) async {
    _logger.info("Getting weight records", {"function": "getWeightRecords"});
    if (state.isLoading) {
      _logger.info("Already loading");
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info("Fetching paginated weight records");
      final weightRecords = await _weightRecordService.getWeightRecords(
        limit: limit,
        offset: offset,
      );
      final weightTotal =
          await _weightRecordService.getWeightRecordTotalCount();

      emit(state.copyWith(
        weightRecords: offset >= state.pagination.offset + limit
            ? [...state.weightRecords, ...weightRecords]
            : weightRecords,
        pagination: state.pagination.copyWith(
          limit: limit,
          offset: offset,
        ),
        weightTotal: weightTotal,
        isLoading: false,
      ));
    } catch (e) {
      _logger.severe("Error getting weight records", e);
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getLatestRecordedWeightRecord() async {
    _logger.info(
        "Getting latest weight record", {"function": "getLatestWeightRecord"});
    if (state.isLoading) {
      _logger.info("Already loading");
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info("Fetching latest weight record");
      final latestWeightRecord = await _weightRecordService.getLatestRecorded();
      emit(state.copyWith(
        latestWeightRecord: latestWeightRecord,
        isLoading: false,
      ));
    } catch (e) {
      _logger.severe("Error getting latest weight record", e);
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getWeightTotal() async {
    final weightTotal = await _weightRecordService.getWeightRecordTotalCount();
    emit(state.copyWith(weightTotal: weightTotal));
  }

  Future<void> createWeightRecord({
    required int weight,
    required DateTime date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final weightRecord = await _weightRecordService.createWeightRecord(
        weight: weight,
        date: date,
        fatPercentage: fatPercentage,
        pictureUri: pictureUri,
      );
      emit(state.copyWith(
        weightRecords: [weightRecord, ...state.weightRecords],
        selectedWeightRecord: weightRecord,
        weightTotal: state.weightTotal + 1,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWeightRecord({
    required int id,
    int? weight,
    DateTime? date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final weightRecord = await _weightRecordService.updateWeightRecord(
        id: id,
        weight: weight,
        date: date,
        fatPercentage: fatPercentage,
        pictureUri: pictureUri,
      );

      emit(state.copyWith(
        weightRecords: state.weightRecords
            .map((w) => w.id == weightRecord.id ? weightRecord : w)
            .toList(),
        selectedWeightRecord: weightRecord,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> deleteWeightRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = await _weightRecordService.deleteWeightRecord(id);

      if (success) {
        emit(state.copyWith(
          weightRecords: state.weightRecords.where((w) => w.id != id).toList(),
          selectedWeightRecord: state.selectedWeightRecord?.id == id
              ? null
              : state.selectedWeightRecord,
          weightTotal: state.weightTotal - 1,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Failed to delete weight record',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
