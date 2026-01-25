import 'package:equatable/equatable.dart';

import '../../models/weight_record_model.dart';
import 'dto.dart';

class WeightRecordDto extends Equatable implements Dto<WeightRecord> {
  @override
  final int id;
  final int weight;
  final int? fatPercentage;
  final String? pictureUri;
  final DateTime recordDate;

  const WeightRecordDto({
    required this.id,
    required this.weight,
    this.fatPercentage,
    this.pictureUri,
    required this.recordDate,
  });

  @override
  factory WeightRecordDto.fromModel(WeightRecord model) {
    return WeightRecordDto(
      id: model.id!,
      weight: model.weight,
      fatPercentage: model.fatPercentage,
      pictureUri: model.pictureUri,
      recordDate: DateTime.fromMillisecondsSinceEpoch(
        model.recordDate * 1000,
        isUtc: true,
      ),
    );
  }

  @override
  WeightRecordDto copyWith({
    int? id,
    int? weight,
    int? fatPercentage,
    String? pictureUri,
    DateTime? recordDate,
  }) {
    return WeightRecordDto(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      pictureUri: pictureUri ?? this.pictureUri,
      recordDate: recordDate ?? this.recordDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        weight,
        fatPercentage,
        pictureUri,
        recordDate,
      ];
}
