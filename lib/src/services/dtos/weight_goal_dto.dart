import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/weight_goal_model.dart';
import 'dto.dart';

class WeightGoalDto extends Equatable implements Dto<WeightGoal> {
  @override
  final int id;
  final int targetWeight;
  final DateTime startDate;
  final DateTime? completedAt;
  final WeightGoalPhase phase;
  final ProgressStatus status;

  const WeightGoalDto({
    required this.id,
    required this.targetWeight,
    required this.startDate,
    this.completedAt,
    required this.status,
    required this.phase,
  });

  factory WeightGoalDto.fromModel(WeightGoal model) {
    return WeightGoalDto(
      id: model.id!,
      targetWeight: model.targetWeight,
      startDate: DateTime.fromMillisecondsSinceEpoch(model.startDate * 1000,
          isUtc: true),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000,
              isUtc: true)
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
    DateTime? completedAt,
    ProgressStatus? status,
    WeightGoalPhase? phase,
  }) {
    return WeightGoalDto(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      phase: phase ?? this.phase,
    );
  }

  @override
  List<Object?> get props => [
        id,
        targetWeight,
        startDate,
        completedAt,
        status,
        phase,
      ];
}
