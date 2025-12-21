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
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  ''';

class Profile extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final int height;
  final Gender gender;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Profile({
    this.id,
    required this.name,
    required this.height,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'gender': gender.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory Profile.fromMap(Map<String, Object?> map) {
    return Profile(
      id: map['id'] as int?,
      name: map['name'] as String,
      height: map['height'] as int,
      gender: Gender.fromValue(map['gender']! as String),
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory Profile.create(
    String name,
    int height,
    Gender gender,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return Profile(
      name: name,
      height: height,
      gender: gender,
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
    int? createdAt,
    int? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      height: height ?? this.height,
      gender: gender ?? this.gender,
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
