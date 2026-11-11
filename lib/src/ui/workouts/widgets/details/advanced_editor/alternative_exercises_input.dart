// Copyright (C) 2026 Afonso Barracha
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

import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/dynamic_list_input.dart';
import '../../../../core/widgets/layout/expanding_section.dart';
import '../../../../exercises/view_models/exercise_cubit.dart';
import '../../../../exercises/view_models/states/exercise_state.dart';
import '../editors/set_exercise_search_modal.dart';
import './complex_set_editor_data.dart';

class AlternativeExercisesInput extends StatelessWidget {
  const AlternativeExercisesInput({
    super.key,
    required this.sizes,
    required this.exerciseData,
    required this.theme,
    required this.isLoading,
    required this.onAlternativesChanged,
  });

  final DataDisplaySizesList sizes;
  final ComplexSetExerciseEditorData exerciseData;
  final ThemeData theme;
  final bool isLoading;
  final ValueChanged<Set<AlternativeExerciseData>>? onAlternativesChanged;

  @override
  Widget build(BuildContext context) {
    return ExpandingSection(
      icon: Icons.swap_horiz,
      title:
          "${exerciseData.alternativeExercises.length} alternative${exerciseData.alternativeExercises.length == 1 ? '' : 's'}",
      titleFountSize: sizes.fontSize,
      titleFontWeight: FontWeight.w300,
      padding: 0,
      dense: true,
      initiallyExpanded: false,
      children: [
        DynamicListInput<AlternativeExerciseData>(
          handlesPadding: sizes.padding / 4,
          addButtonHeight: sizes.smallFontSize * 3,
          theme: theme,
          filled: true,
          items: exerciseData.alternativeExercises.toList(),
          fontSize: sizes.smallFontSize,
          padding: sizes.padding,
          spacing: sizes.spacing,
          isLoading: isLoading,
          addLabel: "Add Alternative",
          keyBuilder: (id) => ValueKey(id),
          onAdd: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return SetExerciseSearchModal(
                  sizes: sizes,
                  isLoading: isLoading,
                  initialMuscleGroup: exerciseData.exerciseMuscleGroup,
                  onExerciseSelected: (exercise) {
                    if (onAlternativesChanged != null) {
                      final newAlternatives =
                          Set<AlternativeExerciseData>.from(
                            exerciseData.alternativeExercises,
                          )..add(
                            AlternativeExerciseData(
                              id: exercise.id,
                              name: exercise.name,
                            ),
                          );
                      onAlternativesChanged!(newAlternatives);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            );
          },
          onChanged: (items) {
            onAlternativesChanged?.call(items.toSet());
          },
          itemBuilder: (context, index, exerciseId) {
            return BlocBuilder<ExerciseCubit, ExerciseState>(
              builder: (context, state) {
                return _SmallButton(
                  exerciseName: exerciseData.alternativeExercises
                      .elementAt(index)
                      .name,
                  sizes: sizes,
                  theme: theme,
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return SetExerciseSearchModal(
                          sizes: sizes,
                          isLoading: isLoading,
                          initialMuscleGroup: exerciseData.exerciseMuscleGroup,
                          onExerciseSelected: (exercise) {
                            if (onAlternativesChanged != null) {
                              final newAlternatives =
                                  List<AlternativeExerciseData>.from(
                                    exerciseData.alternativeExercises,
                                  );
                              newAlternatives[index] = AlternativeExerciseData(
                                id: exercise.id,
                                name: exercise.name,
                              );
                              onAlternativesChanged!(newAlternatives.toSet());
                            }
                            Navigator.of(dialogContext).pop();
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.sizes,
    required this.theme,
    required this.onPressed,
    required this.exerciseName,
  });

  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onPressed;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sizes.smallFontSize * 3,
      child: OutlinedButton.icon(
        icon: Icon(Icons.fitness_center, size: sizes.smallFontSize * 1.2),
        label: Text(
          exerciseName,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sizes.smallFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 0.5),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
