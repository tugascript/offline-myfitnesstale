import 'model.dart';
import 'utilities.dart';

const String _table = 'weight_records';
const String _tableCreate = '''
  CREATE TABLE $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    weight INTEGER NOT NULL,
    fat_percentage INTEGER,
    picture_uri TEXT,
    record_date INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';

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
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'weight': weight,
      'fat_percentage': fatPercentage,
      'picture_uri': pictureUri,
      'record_date': recordDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WeightRecord.fromMap(Map<String, Object?> map) {
    return WeightRecord(
      id: map['id'] as int?,
      weight: map['weight'] as int,
      fatPercentage: map['fat_percentage'] as int?,
      pictureUri: map['picture_uri'] as String?,
      recordDate: map['record_date'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
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
