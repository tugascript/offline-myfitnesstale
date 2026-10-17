import '../../common/nullable.dart';
import '../../models/enums.dart';

class MacroGoalInput {
  final String name;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final Nullable<int> targetWaterIntakeMl;
  final WeightGoalPhase phase;
  final bool isActive;
  const MacroGoalInput({
    required this.name,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetWaterIntakeMl = const Nullable(null),
    required this.phase,
    this.isActive = true,
  });
}
