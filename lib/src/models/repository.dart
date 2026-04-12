import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';
import 'model.dart';
import 'utilities.dart';

typedef FromMap<T> = T Function(Map<String, Object?> map);

const int kDefaultLimit = 25;
const int kDefaultOffset = 0;

class Repository<T extends Model> {
  final DatabaseHelper _databaseHelper;
  final String _tableName;
  final FromMap<T> _fromMap;
  final Logger _logger;

  static const String _baseCountQuery = "SELECT COUNT(*) as count FROM";

  Repository({
    required DatabaseHelper databaseHelper,
    required String tableName,
    required T Function(Map<String, Object?>) fromMap,
  })  : _fromMap = fromMap,
        _tableName = tableName,
        _databaseHelper = databaseHelper,
        _logger = Logger("$tableName Repository");

  Future<List<T>> selectPaginated({
    required int limit,
    required int offset,
    String? where,
    List<Object?>? whereArgs,
    List<String>? orderBy,
  }) async {
    _logger
        .info("selectPaginated: $limit, $offset, $where, $whereArgs, $orderBy");
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
    final List<Map<String, dynamic>> maps =
        await db.rawQuery(countQuery, whereArgs);
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

  Future<T?> selectLatest() async {
    _logger.info("selectLatest");
    final db = await _databaseHelper.db;
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

  Future<T?> selectFirst() async {
    _logger.info("selectFirst");
    final db = await _databaseHelper.db;
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

class JoinRepository<T extends JoinModel, J extends Model, R extends Model> {
  final DatabaseHelper databaseHelper;
  final String tableName;
  final (String, String) primaryKeys;
  final FromMap<T> fromMap;
  final String joinTableName;
  final FromMap<J> joinFromMap;
  final String reverseTableName;
  final FromMap<R> reverseFromMap;

  const JoinRepository({
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
