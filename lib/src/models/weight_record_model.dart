import 'model.dart';
import 'utilities.dart';

const String _table = 'weight_records';

enum WeightRecordColumns with Columns {
  id("id"),
  weight("weight"),
  fatPercentage("fat_percentage"),
  pictureUri("picture_uri"),
  recordDate("record_date"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WeightRecordColumns(this.value);
}

class WeightRecord implements Model {
  @override
  final int? id;
  final int weight;
  final int? fatPercentage;
  final int recordDate;
  final String? pictureUri;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WeightRecord({
    this.id,
    required this.weight,
    this.fatPercentage,
    this.pictureUri,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE $_table (
    ${WeightRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WeightRecordColumns.weight.value} INTEGER NOT NULL,
    ${WeightRecordColumns.fatPercentage.value} INTEGER,
    ${WeightRecordColumns.pictureUri.value} TEXT,
    ${WeightRecordColumns.recordDate.value} INTEGER NOT NULL,
    ${WeightRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WeightRecordColumns.updatedAt.value} INTEGER NOT NULL
  );
''';

  @override
  Map<String, Object?> toMap() {
    return {
      WeightRecordColumns.id.value: id,
      WeightRecordColumns.weight.value: weight,
      WeightRecordColumns.fatPercentage.value: fatPercentage,
      WeightRecordColumns.pictureUri.value: pictureUri,
      WeightRecordColumns.recordDate.value: recordDate,
      WeightRecordColumns.createdAt.value: createdAt,
      WeightRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WeightRecord.fromMap(Map<String, Object?> map) {
    return WeightRecord(
      id: map[WeightRecordColumns.id.value] as int?,
      weight: map[WeightRecordColumns.weight.value] as int,
      fatPercentage: map[WeightRecordColumns.fatPercentage.value] as int?,
      pictureUri: map[WeightRecordColumns.pictureUri.value] as String?,
      recordDate: map[WeightRecordColumns.recordDate.value] as int,
      createdAt: map[WeightRecordColumns.createdAt.value] as int,
      updatedAt: map[WeightRecordColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WeightRecord.create(
    int weight,
    int recordDate,
    int? fatPercentage,
    String? pictureUri,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WeightRecord(
      weight: weight,
      fatPercentage: fatPercentage,
      recordDate: recordDate,
      pictureUri: pictureUri,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WeightRecord copyWith({
    int? id,
    int? weight,
    int? fatPercentage,
    int? recordDate,
    String? pictureUri,
    int? createdAt,
    int? updatedAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      recordDate: recordDate ?? this.recordDate,
      pictureUri: pictureUri ?? this.pictureUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
