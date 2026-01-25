import 'package:equatable/equatable.dart';

import '../../models/equipment_model.dart';
import 'dto.dart';

class EquipmentDto extends Equatable implements Dto<Equipment> {
  @override
  final int id;
  final String name;
  final String? pictureUri;

  const EquipmentDto({
    required this.id,
    required this.name,
    this.pictureUri,
  });

  @override
  factory EquipmentDto.mapData(Equipment equipment) {
    return EquipmentDto(
      id: equipment.id!,
      name: equipment.name,
      pictureUri: equipment.pictureUri,
    );
  }

  @override
  EquipmentDto copyWith({
    int? id,
    String? name,
    String? pictureUri,
  }) {
    return EquipmentDto(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUri: pictureUri ?? this.pictureUri,
    );
  }

  @override
  List<Object?> get props => [id, name, pictureUri];
}
