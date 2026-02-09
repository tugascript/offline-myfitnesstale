import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/equipment_model.dart';
import 'dto.dart';
import 'picture_dto.dart';

class EquipmentDto extends Equatable implements Dto<Equipment> {
  @override
  final int id;
  final String name;
  final PictureDto? picture;
  final CreatedBy createdBy;

  const EquipmentDto({
    required this.id,
    required this.name,
    this.picture,
    required this.createdBy,
  });

  @override
  factory EquipmentDto.fromModel(Equipment equipment) {
    return EquipmentDto(
      id: equipment.id!,
      name: equipment.name,
      picture: equipment.picture != null
          ? PictureDto.fromModel(equipment.picture!)
          : null,
      createdBy: equipment.createdBy,
    );
  }

  @override
  EquipmentDto copyWith({
    int? id,
    String? name,
    PictureDto? picture,
    CreatedBy? createdBy,
  }) {
    return EquipmentDto(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [id, name, picture, createdBy];
}
