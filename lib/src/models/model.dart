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

abstract class Model {
  final int? id;
  final int createdAt;
  final int updatedAt;

  const Model({
    this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap();

  factory Model.fromMap(Map<String, dynamic> map) {
    throw UnimplementedError();
  }

  factory Model.create() {
    throw UnimplementedError();
  }

  static const String table = "table";
  static const String tableCreate = "tableCreate";

  Model copyWith();
}

abstract class JoinModel {
  final int createdAt;

  const JoinModel({
    required this.createdAt,
  });

  Map<String, dynamic> toMap();

  factory JoinModel.fromMap(Map<String, dynamic> map) {
    throw UnimplementedError();
  }

  factory JoinModel.create() {
    throw UnimplementedError();
  }

  static const (String, String) primaryKeys = ("id", "id");
  static const String table = "table";
  static const String tableCreate = "tableCreate";

  JoinModel copyWith();
}
