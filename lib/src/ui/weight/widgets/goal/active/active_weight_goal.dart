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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../utils/nullable.dart';
import '../../../view_models/states/weight_record_state.dart';
import '../../../view_models/weight_record_cubit.dart';
import '../../../../../data/repositories/weight/inputs/weight_goal_input.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../editor/update_weight_goal_card.dart';
import './current_weight_goal.dart';
import './empty_weight_goal.dart';

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
