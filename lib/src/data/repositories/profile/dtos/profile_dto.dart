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

import '../../../models/sqlite/profile_model.dart';
import '../../../utils/dates.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';

class ProfileDto extends Equatable implements ModelDto<Profile> {
  @override
  final int id;
  final String name;
  final int height;
  final Gender gender;
  final DateTime birthdate;

  const ProfileDto({
    required this.id,
    required this.name,
    required this.height,
    required this.gender,
    required this.birthdate,
  });

  factory ProfileDto.fromModel(Profile model) {
    return ProfileDto(
      id: model.id!,
      name: model.name,
      height: model.height,
      gender: model.gender,
      birthdate: DateUtilities.convertNumericDate(model.birthdate),
    );
  }

  @override
  ProfileDto copyWith({
    int? id,
    String? name,
    int? height,
    Gender? gender,
    DateTime? birthdate,
  }) {
    return ProfileDto(
      id: id ?? this.id,
      name: name ?? this.name,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
    );
  }

  @override
  List<Object?> get props => [id, name, height, gender, birthdate];
}
