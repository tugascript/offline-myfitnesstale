import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'profiles';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    height INTEGER NOT NULL,
    gender TEXT NOT NULL,
    birthdate INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  ''';

enum ProfileColumns {
  id("id"),
  name("name"),
  height("height"),
  gender("gender"),
  birthdate("birthdate"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const ProfileColumns(this.value);
}

class Profile extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final int height;
  final Gender gender;
  final int birthdate;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Profile({
    this.id,
    required this.name,
    required this.height,
    required this.gender,
    required this.birthdate,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      ProfileColumns.id.value: id,
      ProfileColumns.name.value: name,
      ProfileColumns.height.value: height,
      ProfileColumns.gender.value: gender.value,
      ProfileColumns.birthdate.value: birthdate,
      ProfileColumns.createdAt.value: createdAt,
      ProfileColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory Profile.fromMap(Map<String, Object?> map) {
    return Profile(
      id: map[ProfileColumns.id.value] as int?,
      name: map[ProfileColumns.name.value] as String,
      height: map[ProfileColumns.height.value] as int,
      gender: Gender.fromValue(map[ProfileColumns.gender.value]! as String),
      birthdate: map[ProfileColumns.birthdate.value] as int,
      createdAt: map[ProfileColumns.createdAt.value] as int,
      updatedAt: map[ProfileColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Profile.create(
    String name,
    int height,
    Gender gender,
    DateTime birthdate,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return Profile(
      name: name,
      height: height,
      gender: gender,
      birthdate: DateUtilities.getNumericDate(birthdate),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Profile copyWith({
    int? id,
    String? name,
    int? height,
    Gender? gender,
    int? birthdate,
    int? createdAt,
    int? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        height,
        gender,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Profile{id: $id, name: $name, height: $height, gender: $gender, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
