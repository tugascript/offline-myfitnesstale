import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../models/equipment_model.dart';
import 'dto.dart';
import 'picture_dto.dart';

class EquipmentDto extends Equatable implements Dto<Equipment> {
  @override
  final int id;
  final String name;
  final PictureDto? picture;
  final bool isFavorite;
  final CreatedBy createdBy;

  const EquipmentDto({
    required this.id,
    required this.name,
    this.picture,
    this.isFavorite = false,
    required this.createdBy,
  });

  factory EquipmentDto.fromModel(Equipment equipment) {
    return EquipmentDto(
      id: equipment.id!,
      name: equipment.name,
      picture: equipment.picture != null
          ? PictureDto.fromModel(equipment.picture!)
          : null,
      isFavorite: equipment.isFavorite,
      createdBy: equipment.createdBy,
    );
  }

  @override
  EquipmentDto copyWith({
    int? id,
    String? name,
    Nullable<PictureDto>? picture,
    bool? isFavorite,
    CreatedBy? createdBy,
  }) {
    return EquipmentDto(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture != null ? picture.value : this.picture,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [id, name, picture, isFavorite, createdBy];
}
