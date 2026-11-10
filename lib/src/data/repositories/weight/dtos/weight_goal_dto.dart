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
import '../../../utils/enums.dart';
import '../../../models/sqlite/weight_goal_model.dart';
import '../../core/dtos/dto.dart';

class WeightGoalDto extends Equatable implements Dto<WeightGoal> {
  @override
  final int id;
  final int targetWeight;
  final int? targetFatPercentage;
  final DateTime startDate;
  final DateTime? completedAt;
  final WeightGoalPhase phase;
  final ProgressStatus status;

  const WeightGoalDto({
    required this.id,
    required this.targetWeight,
    this.targetFatPercentage,
    required this.startDate,
    this.completedAt,
    required this.status,
    required this.phase,
  });

  factory WeightGoalDto.fromModel(WeightGoal model) {
    return WeightGoalDto(
      id: model.id!,
      targetWeight: model.targetWeight,
      targetFatPercentage: model.targetFatPercentage,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        model.startDate * 1000,
        isUtc: true,
      ),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      status: model.status,
      phase: model.phase,
    );
  }

  factory WeightGoalDto.empty() {
    return WeightGoalDto(
      id: 0,
      targetWeight: 0,
      startDate: DateTime.now(),
      completedAt: null,
      status: ProgressStatus.inProgress,
      phase: WeightGoalPhase.maintain,
    );
  }

  @override
  WeightGoalDto copyWith({
    int? id,
    int? targetWeight,
    DateTime? startDate,
    Nullable<DateTime>? completedAt,
    ProgressStatus? status,
    Nullable<int>? targetFatPercentage,
    WeightGoalPhase? phase,
  }) {
    return WeightGoalDto(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      status: status ?? this.status,
      targetFatPercentage: targetFatPercentage != null
          ? targetFatPercentage.value
          : this.targetFatPercentage,
      phase: phase ?? this.phase,
    );
  }

  @override
  List<Object?> get props => [
    id,
    targetWeight,
    targetFatPercentage,
    startDate,
    completedAt,
    status,
    phase,
  ];
}
