// Copyright (C) 2026 afonsobarracha
// 
// This file is part of My Fitness Tale.
// 
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../utils/enums.dart';
import '../../../models/equipment_model.dart';
import '../../core/dtos/dto.dart';
import '../../core/dtos/picture_dto.dart';

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
