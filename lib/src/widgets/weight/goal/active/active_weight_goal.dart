import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/nullable.dart';
import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../services/inputs/weight_goal_input.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../editor/update_weight_goal_card.dart';
import 'current_weight_goal.dart';
import 'empty_weight_goal.dart';

class ActiveWeightGoal extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActiveWeightGoal({super.key, required this.sizes, required this.theme});

  @override
  State<ActiveWeightGoal> createState() => _ActiveWeightGoalState();
}

class _ActiveWeightGoalState extends State<ActiveWeightGoal> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    context.read<WeightRecordCubit>().getActiveWeightGoal();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeightRecordCubit, WeightRecordState>(
      builder: (context, state) {
        if (state.activeWeightGoal == null) {
          return EmptyWeightGoal(theme: widget.theme, sizes: widget.sizes);
        }

        if (_isUpdating && state.activeWeightGoal != null) {
          final activeGoal = state.activeWeightGoal!;
          return UpdateWeightGoalCard(
            theme: widget.theme,
            sizes: widget.sizes,
            weightGoal: activeGoal,
            isLoading: state.isLoading,
            submitLabel: "Update",
            initialWeight: activeGoal.targetWeight,
            initialPhase: activeGoal.phase,
            initialFatPercentage: activeGoal.targetFatPercentage,
            onSubmit: ({required weight, required phase, fatPercentage}) {
              context.read<WeightRecordCubit>().updateWeightGoal(
                activeGoal.id,
                WeightGoalInput(
                  targetWeight: weight,
                  phase: phase,
                  targetFatPercentage: Nullable(fatPercentage),
                  startDate: activeGoal.startDate,
                  status: activeGoal.status,
                  completedAt: Nullable(activeGoal.completedAt),
                ),
              );
              setState(() {
                _isUpdating = false;
              });
            },
            onClose: () {
              setState(() {
                _isUpdating = false;
              });
            },
          );
        }

        return CurrentWeightGoal(
          theme: widget.theme,
          sizes: widget.sizes,
          weightGoal: state.activeWeightGoal,
          isLoading: state.isLoading,
          onEdit: () {
            if (!state.isLoading && state.activeWeightGoal != null) {
              setState(() {
                _isUpdating = true;
              });
            }
          },
        );
      },
    );
  }
}
