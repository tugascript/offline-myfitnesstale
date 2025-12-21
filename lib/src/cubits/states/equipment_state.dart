import 'package:equatable/equatable.dart';

import '../../models/equipment_model.dart';

final class EquipmentPagination extends Equatable {
  final String? name;
  final int limit;
  final int offset;

  const EquipmentPagination({
    this.name,
    required this.limit,
    required this.offset,
  });

  factory EquipmentPagination.initial() {
    return const EquipmentPagination(
      limit: 10,
      offset: 0,
    );
  }

  EquipmentPagination copyWith({
    String? name,
    int? limit,
    int? offset,
  }) {
    return EquipmentPagination(
      name: name ?? this.name,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, limit, offset];
}

final class EquipmentState extends Equatable {
  final List<Equipment> equipments;
  final EquipmentPagination pagination;
  final Equipment? selectedEquipment;
  final bool isLoading;
  final String? error;

  const EquipmentState({
    required this.equipments,
    required this.pagination,
    this.selectedEquipment,
    required this.isLoading,
    this.error,
  });

  factory EquipmentState.initial() {
    return EquipmentState(
      equipments: const [],
      pagination: EquipmentPagination.initial(),
      isLoading: false,
    );
  }

  EquipmentState copyWith({
    List<Equipment>? equipments,
    EquipmentPagination? pagination,
    Equipment? selectedEquipment,
    bool? isLoading,
    String? error,
  }) {
    return EquipmentState(
      equipments: equipments ?? this.equipments,
      pagination: pagination ?? this.pagination,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        equipments.length,
        pagination,
        selectedEquipment,
        isLoading,
        error,
      ];
}

