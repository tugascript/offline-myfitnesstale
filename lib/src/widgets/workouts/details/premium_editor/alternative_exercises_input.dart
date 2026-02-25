import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/exercise_cubit.dart';
import '../../../../cubits/states/exercise_state.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/dynamic_list_input.dart';
import '../../../layout/expanding_section.dart';
import '../editors/set_exercise_search_modal.dart';
import 'complex_set_editor_data.dart';

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
      initiallyExpanded: exerciseData.alternativeExercises.isNotEmpty,
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
                  onExerciseSelected: (id, name) {
                    if (onAlternativesChanged != null) {
                      final newAlternatives = Set<AlternativeExerciseData>.from(
                        exerciseData.alternativeExercises,
                      )..add(AlternativeExerciseData(id: id, name: name));
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
                  exerciseName:
                      exerciseData.alternativeExercises.elementAt(index).name,
                  sizes: sizes,
                  theme: theme,
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return SetExerciseSearchModal(
                          sizes: sizes,
                          isLoading: isLoading,
                          onExerciseSelected: (id, name) {
                            if (onAlternativesChanged != null) {
                              final newAlternatives =
                                  List<AlternativeExerciseData>.from(
                                exerciseData.alternativeExercises,
                              );
                              newAlternatives[index] =
                                  AlternativeExerciseData(id: id, name: name);
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
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 0.5,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
