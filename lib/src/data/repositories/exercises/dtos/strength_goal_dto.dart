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
import '../../../models/strength_goal_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';

class StrengthGoalDto extends Equatable implements Dto<StrengthGoal> {
  @override
  final int id;
  final String name;
  final int targetReps;
  final int targetWeight;
  final int targetMaxStrength;
  final int exerciseId;
  final ProgressStatus status;
  final DateTime startDate;
  final DateTime? completedAt;

  const StrengthGoalDto({
    required this.id,
    required this.name,
    required this.targetReps,
    required this.targetWeight,
    required this.targetMaxStrength,
    required this.exerciseId,
    required this.status,
    required this.startDate,
    this.completedAt,
  });

  factory StrengthGoalDto.fromModel(StrengthGoal model) {
    return StrengthGoalDto(
      id: model.id!,
      name: model.name,
      targetReps: model.targetReps,
      targetWeight: model.targetWeight,
      targetMaxStrength: model.targetMaxStrength,
      exerciseId: model.exerciseId,
      status: model.status,
      startDate: DateUtilities.getDateFromUnix(model.startDate),
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
    );
  }

  @override
  StrengthGoalDto copyWith({
    int? id,
    String? name,
    int? targetReps,
    int? targetWeight,
    int? targetMaxStrength,
    int? exerciseId,
    ProgressStatus? status,
    DateTime? startDate,
    Nullable<DateTime>? completedAt,
  }) {
    return StrengthGoalDto(
      id: id ?? this.id,
      name: name ?? this.name,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetMaxStrength: targetMaxStrength ?? this.targetMaxStrength,
      exerciseId: exerciseId ?? this.exerciseId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    targetReps,
    targetWeight,
    targetMaxStrength,
    exerciseId,
    status,
    startDate,
    completedAt,
  ];
}
