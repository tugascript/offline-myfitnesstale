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
import 'package:myfitnesstale/src/data/models/sqlite/equipment_model.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/utils/result.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();
  late Dao<Equipment> dao;

  setUp(() async {
    await database.initialize();
    dao = Dao<Equipment>(
      databaseHelper: DatabaseHelper(),
      tableName: Equipment.table,
      fromMap: Equipment.fromMap,
    );
  });
  tearDown(database.destroy);

  test('commits writes and preserves callback state on the caller', () async {
    final insertedIds = <int>[];
    final result = await dao.startTransaction((txn) async {
      final id = await dao.insert(Equipment.create(name: 'Barbell'), txn);
      insertedIds.add(id);
      expect(await dao.selectOne(id, txn), isNotNull);
      return ok<int, String>(id);
    }, exclusive: true);

    expect(result.isOk(), isTrue);
    expect(insertedIds, [result.value]);
    expect((await dao.selectOne(result.value))?.name, 'Barbell');
  });

  test(
    'rolls back writes on Err and allows a subsequent transaction',
    () async {
      final failure = err<int, String>('Rejected after writes');
      final result = await dao.startTransaction((txn) async {
        await dao.insert(Equipment.create(name: 'Barbell'), txn);
        await dao.insert(Equipment.create(name: 'Dumbbell'), txn);
        return failure;
      });

      expect(result, same(failure));
      expect(await dao.count(), 0);
      final id = await dao.startTransaction(
        (txn) => dao.insert(Equipment.create(name: 'Retry'), txn),
      );
      expect((await dao.selectOne(id))?.name, 'Retry');
    },
  );

  test('rolls back writes and propagates callback exceptions', () async {
    final failure = StateError('Transaction failed');
    await expectLater(
      dao.startTransaction<int>((txn) async {
        await dao.insert(Equipment.create(name: 'Barbell'), txn);
        throw failure;
      }),
      throwsA(same(failure)),
    );
    expect(await dao.count(), 0);
  });
}
