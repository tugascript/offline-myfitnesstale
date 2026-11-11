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

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/errors.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/model.dart';
import '../../services/sqlite/dao.dart';

const int kMaxSqlVariables = 900;
final _logger = Logger('Repository Helpers');

/// Fetches a paginated slice of rows and its total matching count, skipping
/// the `COUNT(*)` query when the first page returns fewer rows than [limit].
Future<Result<(List<T>, int), ServiceError<E>>>
fetchPaginatedWithTotal<T extends Model, E extends ErrorTypes>({
  required E failureType,
  required Dao<T> dao,
  required int limit,
  required int offset,
  String? where,
  List<Object?>? whereArgs,
  List<String>? orderBy,
}) async {
  try {
    if (offset == 0 && limit > 0) {
      final rows = await dao.selectPaginated(
        limit: limit,
        offset: offset,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
      if (rows.length < limit) {
        return ok((rows, rows.length));
      }
      final total = await dao.count(where: where, whereArgs: whereArgs);
      return ok((rows, total));
    }

    final page = await (
      dao.selectPaginated(
        limit: limit,
        offset: offset,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      ),
      dao.count(where: where, whereArgs: whereArgs),
    ).wait;
    return ok(page);
  } catch (error, stackTrace) {
    _logger.severe('Failed to fetch page', error, stackTrace);
    return err(
      ServiceError(type: failureType, description: 'Failed to fetch page'),
    );
  }
}

/// Queries rows matching [values] on [column] in chunks up to
/// [kMaxSqlVariables] so empty inputs and large ID lists stay safe for SQLite.
Future<Result<List<T>, ServiceError<E>>>
selectManyInChunks<T extends Model, E extends ErrorTypes>({
  required E failureType,
  required Dao<T> dao,
  required Columns column,
  required Iterable<int> values,
  List<String>? orderBy,
  Transaction? trx,
}) async {
  try {
    final valueList = values.toSet().toList();
    if (valueList.isEmpty) {
      return ok(<T>[]);
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
    return ok(results);
  } catch (error, stackTrace) {
    _logger.severe('Failed to load matching rows', error, stackTrace);
    return err(
      ServiceError(
        type: failureType,
        description: 'Failed to load matching rows',
      ),
    );
  }
}

/// Deletes rows matching [values] on [column] in chunks up to
/// [kMaxSqlVariables], returning the total number of deleted rows.
Future<Result<int, ServiceError<E>>>
deleteManyInChunks<T extends Model, E extends ErrorTypes>({
  required E failureType,
  required Dao<T> dao,
  required Columns column,
  required Iterable<int> values,
  required Transaction trx,
}) async {
  try {
    final valueList = values.toSet().toList();
    if (valueList.isEmpty) {
      return ok(0);
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
    return ok(totalDeleted);
  } catch (error, stackTrace) {
    _logger.severe('Failed to delete matching rows', error, stackTrace);
    return err(
      ServiceError(
        type: failureType,
        description: 'Failed to delete matching rows',
      ),
    );
  }
}
