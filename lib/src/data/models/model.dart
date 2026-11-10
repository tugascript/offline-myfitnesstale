mixin Columns {
  String get value;

  String get equal => "$value = ?";

  String get like => "$value LIKE ?";

  String get notEqual => "$value <> ?";

  String get notNull => "$value IS NOT NULL";

  String get isNull => "$value IS NULL";

  String get greaterThan => "$value > ?";

  String get lessThan => "$value < ?";

  String get greaterThanOrEqual => "$value >= ?";

  String get lessThanOrEqual => "$value <= ?";

  String inList(int length) =>
      "$value IN (${List.filled(length, "?").join(", ")})";

  String get orderAsc => "$value ASC";

  String get orderDesc => "$value DESC";

  String get orderCaseInsensitiveAsc => "$value COLLATE NOCASE ASC";

  String get orderCaseInsensitiveDesc => "$value COLLATE NOCASE DESC";
}

/// SQLite entity contract.
///
/// Concrete models should also declare:
/// - `static const String table`
/// - `static final String tableCreate`
/// - `factory Foo.fromMap(Map<String, Object?> map)`
/// - `factory Foo.create({...})`
abstract interface class Model {
  final int? id;
  final int createdAt;
  final int updatedAt;

  const Model({this.id, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toMap();

  static const String table = "table";
  static const String tableCreate = "tableCreate";

  Model copyWith();
}

/// SQLite join-table (many-to-many) entity contract.
///
/// Concrete join models should also declare:
/// - `static const String table`
/// - `static final String tableCreate`
/// - `static const (String, String) primaryKeys`
/// - `factory Foo.fromMap(Map<String, Object?> map)`
/// - `factory Foo.create({...})`
abstract interface class JoinModel {
  final int createdAt;

  const JoinModel({required this.createdAt});

  Map<String, dynamic> toMap();

  JoinModel copyWith();
}
