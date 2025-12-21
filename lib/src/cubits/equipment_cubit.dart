import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/equipment_model.dart';
import '../services/equipment_service.dart';
import 'states/equipment_state.dart';

class EquipmentCubit extends Cubit<EquipmentState> {
  final EquipmentService _equipmentService = EquipmentService();

  EquipmentCubit() : super(EquipmentState.initial());

  Future<void> getEquipments({
    String? name,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<Equipment> equipments = await _equipmentService.getEquipments(
        name: name,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        equipments: equipments,
        pagination: state.pagination.copyWith(
          name: name,
          limit: limit,
          offset: offset,
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getEquipment(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Equipment? equipment = await _equipmentService.getEquipment(id);

      emit(state.copyWith(
        selectedEquipment: equipment,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}

