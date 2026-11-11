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

import 'package:sqflite/sqflite.dart';

import '../../models/sqlite/model.dart';
import '../../services/sqlite/dao.dart';

const int kMaxSqlVariables = 900;

/// Fetches a paginated slice of rows and its total matching count, skipping
/// the `COUNT(*)` query when the first page returns fewer rows than [limit].
Future<(List<T>, int)> fetchPaginatedWithTotal<T extends Model>({
  required Dao<T> dao,
  required int limit,
  required int offset,
  String? where,
  List<Object?>? whereArgs,
  List<String>? orderBy,
}) async {
  if (offset == 0 && limit > 0) {
    final rows = await dao.selectPaginated(
      limit: limit,
      offset: offset,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    if (rows.length < limit) {
      return (rows, rows.length);
    }
    final total = await dao.count(where: where, whereArgs: whereArgs);
    return (rows, total);
  }

  final results = await Future.wait([
    dao.selectPaginated(
      limit: limit,
      offset: offset,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    ),
    dao.count(where: where, whereArgs: whereArgs),
  ]);
  return (results[0] as List<T>, results[1] as int);
}

/// Queries rows matching [values] on [column] in chunks up to
/// [kMaxSqlVariables] so empty inputs and large ID lists stay safe for SQLite.
Future<List<T>> selectManyInChunks<T extends Model>({
  required Dao<T> dao,
  required Columns column,
  required Iterable<int> values,
  List<String>? orderBy,
  Transaction? trx,
}) async {
  final valueList = values.toSet().toList();
  if (valueList.isEmpty) {
    return <T>[];
  }

  final results = <T>[];
  for (int i = 0; i < valueList.length; i += kMaxSqlVariables) {
    final end = i + kMaxSqlVariables < valueList.length
        ? i + kMaxSqlVariables
        : valueList.length;
    final chunk = valueList.sublist(i, end);
    final rows = await dao.selectMany(
      where: column.inList(chunk.length),
      whereArgs: chunk,
      orderBy: orderBy,
      trx: trx,
    );
    results.addAll(rows);
  }
  return results;
}

/// Deletes rows matching [values] on [column] in chunks up to
/// [kMaxSqlVariables], returning the total number of deleted rows.
Future<int> deleteManyInChunks<T extends Model>({
  required Dao<T> dao,
  required Columns column,
  required Iterable<int> values,
  Transaction? trx,
}) async {
  final valueList = values.toSet().toList();
  if (valueList.isEmpty) {
    return 0;
  }

  int totalDeleted = 0;
  for (int i = 0; i < valueList.length; i += kMaxSqlVariables) {
    final end = i + kMaxSqlVariables < valueList.length
        ? i + kMaxSqlVariables
        : valueList.length;
    final chunk = valueList.sublist(i, end);
    totalDeleted += await dao.deleteMany(
      where: column.inList(chunk.length),
      whereArgs: chunk,
      trx: trx,
    );
  }
  return totalDeleted;
}
