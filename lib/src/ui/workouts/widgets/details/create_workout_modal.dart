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
import '../../view_models/states/workout_state.dart';
import '../../view_models/workout_cubit.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_modal.dart';
import './workout_base_form.dart';

class CreateWorkoutDialog extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const CreateWorkoutDialog({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          return WorkoutBaseForm(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
            submitLabel: "CREATE WORKOUT",
            initialName: "",
            initialIsFavorite: false,
            initialDifficulty: Difficulty.beginner,
            initialEditorType: EditorType.basic,
            onSubmit:
                ({
                  required String name,
                  required bool isFavorite,
                  required Difficulty difficulty,
                  required EditorType editorType,
                  String? description,
                }) async {
                  await context.read<WorkoutCubit>().createWorkout(
                    WorkoutInput(
                      name: name,
                      isFavorite: isFavorite,
                      difficulty: difficulty,
                      editorType: editorType,
                      description: Nullable(description),
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 10));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final cubitState = context.read<WorkoutCubit>().state;
                    if (cubitState.selectedWorkout != null) {
                      context.push(
                        "/workouts/${cubitState.selectedWorkout!.id}",
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
