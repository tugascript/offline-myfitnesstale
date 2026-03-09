import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../editor/update_weight_goal_card.dart';
import 'current_weight_goal.dart';
import 'empty_weight_goal.dart';

class ActiveWeightGoal extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActiveWeightGoal({
    super.key,
    required this.sizes,
    required this.theme,
  });

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
          return EmptyWeightGoal(
            theme: widget.theme,
            sizes: widget.sizes,
          );
        }

        if (_isUpdating && state.activeWeightGoal != null) {
          return UpdateWeightGoalCard(
            theme: widget.theme,
            sizes: widget.sizes,
            weightGoal: state.activeWeightGoal!,
            isLoading: state.isLoading,
            submitLabel: "Update",
            initialWeight: state.activeWeightGoal!.targetWeight,
            initialPhase: state.activeWeightGoal!.phase,
            onSubmit: ({required weight, required phase}) {
              context.read<WeightRecordCubit>().updateWeightGoal(
                    id: state.activeWeightGoal!.id,
                    targetWeight: weight,
                    phase: phase,
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
