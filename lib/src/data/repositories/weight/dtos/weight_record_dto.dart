// Copyright (C) 2026 afonsobarracha
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

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../models/sqlite/weight_record_model.dart';
import '../../core/dtos/dto.dart';

class WeightRecordDto extends Equatable implements ModelDto<WeightRecord> {
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

  factory WeightRecordDto.empty() {
    return WeightRecordDto(id: 0, weight: 0, recordDate: DateTime.now());
  }

  @override
  WeightRecordDto copyWith({
    int? id,
    int? weight,
    Nullable<int>? fatPercentage,
    Nullable<String>? pictureUri,
    DateTime? recordDate,
  }) {
    return WeightRecordDto(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage != null
          ? fatPercentage.value
          : this.fatPercentage,
      pictureUri: pictureUri != null ? pictureUri.value : this.pictureUri,
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
