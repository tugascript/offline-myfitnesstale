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

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/sqlite/model.dart';
import '../common.dart';
import './database_helper.dart';

final class Dao<T extends Model> {
  final DatabaseHelper _databaseHelper;
  final String _tableName;
  final FromMap<T> _fromMap;
  final Logger _logger;

  static const String _baseCountQuery = "SELECT COUNT(*) as count FROM";

  Dao({
    required this._databaseHelper,
    required String tableName,
    required this._fromMap,
  }) : _tableName = tableName,
       _logger = Logger("$tableName DAO");

  Future<List<T>> selectPaginated({
    required int limit,
    required int offset,
    String? where,
    List<Object?>? whereArgs,
    List<String>? orderBy,
  }) async {
    _logger.info(
      "selectPaginated: $limit, $offset, $where, $whereArgs, $orderBy",
    );
    final db = await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      limit: limit,
      offset: offset,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy?.join(", "),
    );

    _logger.info("selectPaginated: ${maps.length}");
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<T>> selectMany({
    String? where,
    List<Object?>? whereArgs,
    List<String>? orderBy,
    int? limit,
    Transaction? trx,
  }) async {
    _logger.info("selectAll: $where, $whereArgs, $orderBy");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy?.join(", "),
      limit: limit,
    );

    _logger.info("selectMany: ${maps.length}");
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<T?> selectOne(int id, [Transaction? trx]) async {
    _logger.info("selectOne: $id");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      limit: 1,
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      _logger.info("selectOne: ${maps.first}");
      return _fromMap(maps.first);
    }
    return null;
  }

  Future<int> count({
    String? where,
    List<Object?>? whereArgs,
    Transaction? trx,
  }) async {
    _logger.info("count: $where, $whereArgs");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final String countQuery = where != null
        ? "$_baseCountQuery $_tableName WHERE $where"
        : "$_baseCountQuery $_tableName";
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      countQuery,
      whereArgs,
    );
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  /// Executes an integer aggregate query such as a joined `COUNT(*)` against
  /// this DAO's configured database helper or active transaction.
  Future<int> rawCount(
    String query, [
    List<Object?>? arguments,
    Transaction? trx,
  ]) async {
    _logger.info("rawCount: $query, $arguments");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future<int> insert(T model, [Transaction? trx]) async {
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final modelMap = model.toMap();
    _logger.info("insert: $modelMap");
    return await db.insert(
      _tableName,
      modelMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertMany(List<T> models, [Transaction? trx]) async {
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final Batch batch = db.batch();

    for (T model in models) {
      final modelMap = model.toMap();
      _logger.info("insertMany: $modelMap");
      batch.insert(
        _tableName,
        modelMap,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> update(T model, [Transaction? trx]) async {
    _logger.info("update: ${model.toMap()}");
    if (model.id == null) {
      _logger.info("update: model.id is null");
      return false;
    }

    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final modelMap = model.toMap();
    _logger.info("update: $modelMap");
    final int rowsAffected = await db.update(
      _tableName,
      modelMap,
      where: 'id = ?',
      whereArgs: [model.id],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteOne(int id, [Transaction? trx]) async {
    _logger.info("deleteOne: $id");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final int rowsAffected = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    _logger.info("deleteOne: $rowsAffected");
    return rowsAffected > 0;
  }

  Future<int> deleteMany({
    required String where,
    required List<Object?> whereArgs,
    Transaction? trx,
  }) async {
    _logger.info("deleteMany: $where, $whereArgs");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final int rowsAffected = await db.delete(
      _tableName,
      where: where,
      whereArgs: whereArgs,
    );
    _logger.info("deleteMany: $rowsAffected");
    return rowsAffected;
  }

  Future<T?> selectLatest([Transaction? trx]) async {
    _logger.info("selectLatest");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      _logger.info("selectLatest: ${maps.first}");
      return _fromMap(maps.first);
    }
    return null;
  }

  Future<T?> selectFirst([Transaction? trx]) async {
    _logger.info("selectFirst");
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'id ASC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      _logger.info("selectFirst: ${maps.first}");
      return _fromMap(maps.first);
    }

    _logger.info("selectFirst: null");
    return null;
  }

  Future<R> startTransaction<R>(
    Future<R> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    _logger.info("startTransaction");
    final db = await _databaseHelper.db;
    return await db.transaction(action, exclusive: exclusive);
  }
}
