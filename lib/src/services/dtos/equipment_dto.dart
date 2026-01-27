import 'package:equatable/equatable.dart';

import '../../models/equipment_model.dart';
import 'dto.dart';
import 'picture_dto.dart';

class EquipmentDto extends Equatable implements Dto<Equipment> {
  @override
  final int id;
  final String name;
  final PictureDto? picture;

  const EquipmentDto({
    required this.id,
    required this.name,
    this.picture,
  });

  @override
  factory EquipmentDto.fromModel(Equipment equipment) {
    return EquipmentDto(
      id: equipment.id!,
      name: equipment.name,
      picture: equipment.picture != null
          ? PictureDto.fromModel(equipment.picture!)
          : null,
    );
  }

  @override
  EquipmentDto copyWith({
    int? id,
    String? name,
    PictureDto? picture,
  }) {
    return EquipmentDto(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture ?? this.picture,
    );
  }

  @override
  List<Object?> get props => [id, name, picture];
}
