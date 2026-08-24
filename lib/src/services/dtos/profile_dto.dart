import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/profile_model.dart';
import '../../models/utilities.dart';
import 'dto.dart';

class ProfileDto extends Equatable implements Dto<Profile> {
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
