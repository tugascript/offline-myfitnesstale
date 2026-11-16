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

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/backup_passkeys_model.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

void main() {
  test('create sets timestamps and leaves id/lastUsedAt null', () {
    final model = BackupPasskeys.create(
      passkey: r'$2b$10$hashed',
      salt: 'c2FsdA==',
    );

    expect(model.id, isNull);
    expect(model.passkey, r'$2b$10$hashed');
    expect(model.salt, 'c2FsdA==');
    expect(model.lastUsedAt, isNull);
    expect(model.createdAt, model.updatedAt);
    expect(model.createdAt, greaterThan(0));
  });

  test('toMap and fromMap round-trip', () {
    final original = BackupPasskeys(
      id: 3,
      passkey: r'$2b$10$hashed',
      salt: 'c2FsdA==',
      lastUsedAt: 1_700_000_000,
      createdAt: 1_700_000_100,
      updatedAt: 1_700_000_200,
    );

    final restored = BackupPasskeys.fromMap(original.toMap());

    expect(restored, original);
  });

  test('copyWith updates fields and can clear lastUsedAt', () {
    final original = BackupPasskeys.create(
      passkey: r'$2b$10$hashed',
      salt: 'c2FsdA==',
    ).copyWith(id: 1, lastUsedAt: const Nullable(42));

    final updated = original.copyWith(
      passkey: r'$2b$10$other',
      salt: 'b3RoZXI=',
      lastUsedAt: const Nullable(null),
      updatedAt: original.updatedAt + 10,
    );

    expect(updated.id, 1);
    expect(updated.passkey, r'$2b$10$other');
    expect(updated.salt, 'b3RoZXI=');
    expect(updated.lastUsedAt, isNull);
    expect(updated.createdAt, original.createdAt);
    expect(updated.updatedAt, original.updatedAt + 10);
  });

  test('tableCreate includes salt column', () {
    expect(BackupPasskeys.tableCreate, contains('salt'));
    expect(BackupPasskeys.table, 'backup_passkeys');
  });
}
