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
import '../../utils/where_builder.dart';
import '../common.dart';
import 'database_helper.dart';

final class JoinDao<T extends JoinModel, J extends Model, R extends Model> {
  final DatabaseHelper _databaseHelper;
  final String _tableName;
  final (String, String) _primaryKeys;
  final FromMap<T> _fromMap;
  final String _joinTableName;
  final FromMap<J> _joinFromMap;
  final String _reverseTableName;
  final FromMap<R> _reverseFromMap;
  final Logger _logger;

  JoinDao({
    required this._databaseHelper,
    required String tableName,
    required this._primaryKeys,
    required this._fromMap,
    required this._joinTableName,
    required this._joinFromMap,
    required this._reverseTableName,
    required this._reverseFromMap,
  }) : _tableName = tableName,
       _logger = Logger('$tableName join DAO');

  Future<int> insert(T model, [Transaction? trx]) async {
    final modelMap = model.toMap();
    _logger.info('insert: $modelMap');
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
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
      _logger.info('insertMany: $modelMap');
      batch.insert(
        _tableName,
        modelMap,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> deleteOne(int pk1, int pk2, [Transaction? trx]) async {
    _logger.info('deleteOne: $pk1, $pk2');
    final WhereBuilder whereBuilder = WhereBuilder();
    final (String key1, String key2) = _primaryKeys;
    whereBuilder.and('$key1 = ?', pk1);
    whereBuilder.and('$key2 = ?', pk2);

    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final int rowsAffected = await db.delete(
      _tableName,
      where: whereBuilder.where,
      whereArgs: whereBuilder.args,
    );
    _logger.info('deleteOne: $rowsAffected');
    return rowsAffected > 0;
  }

  Future<bool> deleteAllByPk1(int pk1, [Transaction? trx]) async {
    _logger.info('deleteAllByPk1: $pk1');
    final (String key1, _) = _primaryKeys;
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final int rowsAffected = await db.delete(
      _tableName,
      where: '$key1 = ?',
      whereArgs: [pk1],
    );
    _logger.info('deleteAllByPk1: $rowsAffected');
    return rowsAffected > 0;
  }

  Future<bool> deleteAllByPk2(int pk2, [Transaction? trx]) async {
    _logger.info('deleteAllByPk2: $pk2');
    final (_, String key2) = _primaryKeys;
    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final int rowsAffected = await db.delete(
      _tableName,
      where: '$key2 = ?',
      whereArgs: [pk2],
    );
    _logger.info('deleteAllByPk2: $rowsAffected');
    return rowsAffected > 0;
  }

  Future<T?> selectOne(int pk1, int pk2) async {
    _logger.info('selectOne: $pk1, $pk2');
    final WhereBuilder whereBuilder = WhereBuilder();
    final (String key1, String key2) = _primaryKeys;

    whereBuilder.and('$key1 = ?', pk1);
    whereBuilder.and('$key2 = ?', pk2);

    final DatabaseExecutor db = await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: whereBuilder.where,
      whereArgs: whereBuilder.args,
    );
    if (maps.isEmpty) {
      _logger.info('selectOne: null');
      return null;
    }

    _logger.info('selectOne: ${maps.first}');
    return _fromMap(maps.first);
  }

  Future<List<J>> selectJoined(
    int pk1, [
    List<String>? orderBy,
    Transaction? trx,
  ]) async {
    _logger.info('selectJoined: $pk1, $orderBy');
    final (String key1, String key2) = _primaryKeys;

    final DatabaseExecutor db = trx ?? await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT j.* FROM $_tableName m
      LEFT JOIN $_joinTableName j ON j.id = m.$key2
      WHERE $key1 = ?${orderBy != null ? ' ORDER BY j.${orderBy.join(", j.")}' : ''};
      """,
      [pk1],
    );

    _logger.info('selectJoined: ${maps.length}');
    return maps.map((map) => _joinFromMap(map)).toList();
  }

  Future<List<R>> selectReverseJoined(int pk2, [List<String>? orderBy]) async {
    _logger.info('selectReverseJoined: $pk2, $orderBy');
    final (String key1, String key2) = _primaryKeys;

    final DatabaseExecutor db = await _databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT r.* FROM $_tableName m
      LEFT JOIN $_reverseTableName r ON r.id = m.$key1
      WHERE $key2 = ?${orderBy != null ? ' ORDER BY r.${orderBy.join(", r.")}' : ''};
      """,
      [pk2],
    );

    _logger.info('selectReverseJoined: ${maps.length}');
    return maps.map((map) => _reverseFromMap(map)).toList();
  }

  Future<List<T>> selectAllByPk1(int pk1) async {
    _logger.info('selectAllByPk1: $pk1');
    final String key1 = _primaryKeys.$1;

    final DatabaseExecutor db = await _databaseHelper.db;
    final List<Map<String, Object?>> maps = await db.query(
      _tableName,
      where: '$key1 = ?',
      whereArgs: [pk1],
    );

    _logger.info('selectAllByPk1: ${maps.length}');
    return maps.map((map) => _fromMap(map)).toList();
  }
}
