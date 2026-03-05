// Copyright (C) 2026 Afonso Barracha
//
// This file is part of MyFitnessTale.
//
// MyFitnessTale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MyFitnessTale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MyFitnessTale.  If not, see <https://www.gnu.org/licenses/>.

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
