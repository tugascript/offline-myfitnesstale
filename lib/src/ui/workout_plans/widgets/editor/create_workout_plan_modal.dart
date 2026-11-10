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
import 'package:go_router/go_router.dart';

import '../../../../utils/nullable.dart';
import '../../view_models/states/workout_plan_state.dart';
import '../../view_models/workout_plan_cubit.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_modal.dart';
import './workout_plan_base_form.dart';

class CreateWorkoutPlanModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateWorkoutPlanModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
        builder: (context, state) {
          return WorkoutPlanBaseForm(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
            submitLabel: "CREATE WORKOUT PLAN",
            initialName: "",
            initialIsFavorite: false,
            initialDifficulty: Difficulty.beginner,
            initialDescription: null,
            onSubmit:
                ({
                  required String name,
                  required bool isFavorite,
                  required Difficulty difficulty,
                  String? description,
                }) async {
                  await context.read<WorkoutPlanCubit>().createWorkoutPlan(
                    WorkoutPlanInput(
                      name: name,
                      isFavorite: isFavorite,
                      difficulty: difficulty,
                      description: Nullable(description),
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 10));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final cubitState = context.read<WorkoutPlanCubit>().state;
                    if (cubitState.selectedWorkoutPlan != null) {
                      context.push(
                        "/workout-plans/${cubitState.selectedWorkoutPlan!.id}",
                      );
                    }
                  }
                },
          );
        },
      ),
    );
  }
}
