import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../models/strength_goal_model.dart';
import '../../models/utilities.dart';

class StrengthGoalDto extends Equatable {
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
