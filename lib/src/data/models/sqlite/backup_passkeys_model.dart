// Copyright (C) 2026 Afonso Barracha
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

import '../../../utils/nullable.dart';
import '../../utils/dates.dart';
import 'model.dart';

const String _table = 'backup_passkeys';

enum BackupPasskeysColumns with Columns {
  id("id"),

  /// bcrypt hash of the plaintext passkey (never store plaintext here).
  passkey("passkey"),

  /// Base64-encoded PBKDF2 salt used to derive the AES backup key.
  salt("salt"),
  lastUsedAt("last_used_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const BackupPasskeysColumns(this.value);
}

final class BackupPasskeys extends Equatable implements Model {
  @override
  final int? id;

  /// bcrypt hash of the plaintext passkey.
  final String passkey;

  /// Base64-encoded PBKDF2 salt for AES key derivation.
  final String salt;
  final int? lastUsedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const BackupPasskeys({
    this.id,
    required this.passkey,
    required this.salt,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate =
      '''
    CREATE TABLE IF NOT EXISTS $_table (
      ${BackupPasskeysColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${BackupPasskeysColumns.passkey.value} TEXT NOT NULL,
      ${BackupPasskeysColumns.salt.value} TEXT NOT NULL,
      ${BackupPasskeysColumns.lastUsedAt.value} INTEGER,
      ${BackupPasskeysColumns.createdAt.value} INTEGER NOT NULL,
      ${BackupPasskeysColumns.updatedAt.value} INTEGER NOT NULL
    );

    CREATE UNIQUE INDEX IF NOT EXISTS uidx_backup_passkeys_passkey ON $_table (${BackupPasskeysColumns.passkey.value});
    ''';

  @override
  Map<String, Object?> toMap() {
    return {
      BackupPasskeysColumns.id.value: id,
      BackupPasskeysColumns.passkey.value: passkey,
      BackupPasskeysColumns.salt.value: salt,
      BackupPasskeysColumns.lastUsedAt.value: lastUsedAt,
      BackupPasskeysColumns.createdAt.value: createdAt,
      BackupPasskeysColumns.updatedAt.value: updatedAt,
    };
  }

  factory BackupPasskeys.fromMap(Map<String, Object?> map) {
    return BackupPasskeys(
      id: map[BackupPasskeysColumns.id.value] as int?,
      passkey: map[BackupPasskeysColumns.passkey.value]! as String,
      salt: map[BackupPasskeysColumns.salt.value]! as String,
      lastUsedAt: map[BackupPasskeysColumns.lastUsedAt.value] as int?,
      createdAt: map[BackupPasskeysColumns.createdAt.value]! as int,
      updatedAt: map[BackupPasskeysColumns.updatedAt.value]! as int,
    );
  }

  /// [passkey] must already be a bcrypt hash; [salt] must be base64.
  factory BackupPasskeys.create({
    required String passkey,
    required String salt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return BackupPasskeys(
      passkey: passkey,
      salt: salt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  BackupPasskeys copyWith({
    int? id,
    String? passkey,
    String? salt,
    Nullable<int>? lastUsedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return BackupPasskeys(
      id: id ?? this.id,
      passkey: passkey ?? this.passkey,
      salt: salt ?? this.salt,
      lastUsedAt: lastUsedAt != null ? lastUsedAt.value : this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    passkey,
    salt,
    lastUsedAt,
    createdAt,
    updatedAt,
  ];
}
