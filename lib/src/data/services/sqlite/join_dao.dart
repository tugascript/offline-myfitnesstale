import 'package:sqflite/sqflite.dart';

import '../../models/model.dart';
import '../../utils/where_builder.dart';
import '../common.dart';
import 'database_helper.dart';

final class JoinDao<T extends JoinModel, J extends Model, R extends Model> {
  final DatabaseHelper databaseHelper;
  final String tableName;
  final (String, String) primaryKeys;
  final FromMap<T> fromMap;
  final String joinTableName;
  final FromMap<J> joinFromMap;
  final String reverseTableName;
  final FromMap<R> reverseFromMap;

  const JoinDao({
    required this.databaseHelper,
    required this.tableName,
    required this.primaryKeys,
    required this.fromMap,
    required this.joinTableName,
    required this.joinFromMap,
    required this.reverseTableName,
    required this.reverseFromMap,
  });

  Future<int> insert(T model, [Transaction? trx]) async {
    final DatabaseExecutor db = trx ?? await databaseHelper.db;
    return await db.insert(
      tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertMany(List<T> models, [Transaction? trx]) async {
    final DatabaseExecutor db = trx ?? await databaseHelper.db;
    final Batch batch = db.batch();

    for (T model in models) {
      batch.insert(
        tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> deleteOne(int pk1, int pk2, [Transaction? trx]) async {
    final WhereBuilder whereBuilder = WhereBuilder();
    final (String key1, String key2) = primaryKeys;
    whereBuilder.and('$key1 = ?', pk1);
    whereBuilder.and('$key2 = ?', pk2);

    final DatabaseExecutor db = trx ?? await databaseHelper.db;
    final int rowsAffected = await db.delete(
      tableName,
      where: whereBuilder.where,
      whereArgs: whereBuilder.args,
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteAllByPk1(int pk1, [Transaction? trx]) async {
    final (String key1, _) = primaryKeys;
    final DatabaseExecutor db = trx ?? await databaseHelper.db;
    final int rowsAffected = await db.delete(
      tableName,
      where: '$key1 = ?',
      whereArgs: [pk1],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteAllByPk2(int pk2, [Transaction? trx]) async {
    final (_, String key2) = primaryKeys;
    final DatabaseExecutor db = trx ?? await databaseHelper.db;
    final int rowsAffected = await db.delete(
      tableName,
      where: '$key2 = ?',
      whereArgs: [pk2],
    );
    return rowsAffected > 0;
  }

  Future<T?> selectOne(int pk1, int pk2) async {
    final WhereBuilder whereBuilder = WhereBuilder();
    final (String key1, String key2) = primaryKeys;

    whereBuilder.and('$key1 = ?', pk1);
    whereBuilder.and('$key2 = ?', pk2);

    final DatabaseExecutor db = await databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereBuilder.where,
      whereArgs: whereBuilder.args,
    );
    if (maps.isEmpty) {
      return null;
    }

    return fromMap(maps.first);
  }

  Future<List<J>> selectJoined(int pk1, [List<String>? orderBy]) async {
    final (String key1, String key2) = primaryKeys;

    final DatabaseExecutor db = await databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT j.* FROM $tableName m
      LEFT JOIN $joinTableName j ON j.id = m.$key2
      WHERE $key1 = ?${orderBy != null ? ' ORDER BY j.${orderBy.join(", j.")}' : ''};
      """,
      [pk1],
    );

    return maps.map((map) => joinFromMap(map)).toList();
  }

  Future<List<R>> selectReverseJoined(int pk2, [List<String>? orderBy]) async {
    final (String key1, String key2) = primaryKeys;

    final DatabaseExecutor db = await databaseHelper.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT r.* FROM $tableName m
      LEFT JOIN $reverseTableName r ON r.id = m.$key1
      WHERE $key2 = ?${orderBy != null ? ' ORDER BY r.${orderBy.join(", r.")}' : ''};
      """,
      [pk2],
    );

    return maps.map((map) => reverseFromMap(map)).toList();
  }

  Future<List<T>> selectAllByPk1(int pk1) async {
    final String key1 = primaryKeys.$1;

    final DatabaseExecutor db = await databaseHelper.db;
    final List<Map<String, Object?>> maps = await db.query(
      tableName,
      where: '$key1 = ?',
      whereArgs: [pk1],
    );

    return maps.map((map) => fromMap(map)).toList();
  }
}
