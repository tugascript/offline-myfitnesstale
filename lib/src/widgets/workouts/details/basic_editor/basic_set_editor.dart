import 'package:flutter/material.dart';

import '../../../../services/dtos/workout_set_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_text_form_field.dart';
import '../editors/set_exercise_search_modal.dart';

class BasicSetEditor extends StatelessWidget {
  final WorkoutSetDto set;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final TextEditingController minSetsController;
  final TextEditingController maxSetsController;
  final TextEditingController minRepsController;
  final TextEditingController maxRepsController;
  final TextEditingController restController;
  final TextEditingController maxRestController;
  final bool isMaxReps;
  final ValueChanged<bool> onIsMaxRepsChanged;
  final (int, String)? exercise;
  final ValueChanged<(int, String)> onExerciseChanged;
  final ValueChanged<String>? onMinSetsChanged;
  final ValueChanged<String>? onMaxSetsChanged;
  final ValueChanged<String>? onMinRepsChanged;
  final ValueChanged<String>? onMaxRepsChanged;
  final ValueChanged<String>? onRestChanged;
  final ValueChanged<String>? onMaxRestChanged;

  const BasicSetEditor({
    super.key,
    required this.set,
    required this.sizes,
    required this.isLoading,
    required this.minSetsController,
    required this.maxSetsController,
    required this.minRepsController,
    required this.maxRepsController,
    required this.restController,
    required this.maxRestController,
    required this.isMaxReps,
    required this.onIsMaxRepsChanged,
    required this.exercise,
    required this.onExerciseChanged,
    this.onMinSetsChanged,
    this.onMaxSetsChanged,
    this.onMinRepsChanged,
    this.onMaxRepsChanged,
    this.onRestChanged,
    this.onMaxRestChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SetsInput(
                minSetsController: minSetsController,
                minSetsOnChanged: onMinSetsChanged,
                maxSetsController: maxSetsController,
                maxSetsOnChanged: onMaxSetsChanged,
                isLoading: isLoading,
                sizes: sizes,
                theme: theme,
              ),
            ),
            SizedBox(width: sizes.spacing),
            Expanded(
              child: _RepsInput(
                minRepsController: minRepsController,
                minRepsOnChanged: onMinRepsChanged,
                maxRepsController: maxRepsController,
                maxRepsOnChanged: onMaxRepsChanged,
                isLoading: isLoading,
                sizes: sizes,
                theme: theme,
                isMaxReps: isMaxReps,
                onIsMaxRepsChanged: (value) {
                  if (value != null) {
                    onIsMaxRepsChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        _ExerciseSelectionButton(
          exerciseName: exercise?.$2,
          sizes: sizes,
          theme: theme,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return SetExerciseSearchModal(
                  sizes: sizes,
                  onExerciseSelected: (id, name) {
                    onExerciseChanged((id, name));
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
        ),
        SizedBox(height: sizes.spacing),
        _RestInput(
          restController: restController,
          restOnChanged: onRestChanged,
          maxRestController: maxRestController,
          maxRestOnChanged: onMaxRestChanged,
          sizes: sizes,
          theme: theme,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _ExerciseSelectionButton extends StatelessWidget {
  final String? exerciseName;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onPressed;

  const _ExerciseSelectionButton({
    required this.exerciseName,
    required this.sizes,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        exerciseName == null ? "Select Exercise" : exerciseName!,
        style: TextStyle(fontSize: sizes.fontSize),
      ),
    );
  }
}

class _SetsInput extends StatelessWidget {
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final TextEditingController minSetsController;
  final ValueChanged<String>? minSetsOnChanged;
  final TextEditingController maxSetsController;
  final ValueChanged<String>? maxSetsOnChanged;

  const _SetsInput({
    required this.minSetsController,
    required this.minSetsOnChanged,
    required this.maxSetsController,
    required this.maxSetsOnChanged,
    required this.isLoading,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.repeat, size: sizes.fontSize * 1.2),
        SizedBox(width: halfSpacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: isLoading,
            controller: minSetsController,
            labelText: "Sets",
            hintText: "0",
            keyboardType: TextInputType.number,
            fontSize: sizes.fontSize,
            padding: sizes.padding,
            validator: (value) {
              if (value == null) {
                return "Min sets is required";
              }

              final intSets = int.tryParse(value);
              if (intSets == null) {
                return "Invalid number";
              }

              if (intSets < 1) {
                return "Min sets must be at least 1";
              }

              return null;
            },
            onChanged: minSetsOnChanged,
          ),
        ),
        SizedBox(width: halfSpacing),
        Icon(Icons.remove, size: sizes.fontSize * 1.2),
        SizedBox(width: halfSpacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: isLoading,
            controller: maxSetsController,
            labelText: "Max Sets",
            hintText: "0",
            keyboardType: TextInputType.number,
            fontSize: sizes.fontSize,
            padding: sizes.padding,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              final intSets = int.tryParse(value);
              if (intSets == null) {
                return "Invalid number";
              }

              if (intSets < 0) {
                return "Max sets must be at least 0";
              }

              return null;
            },
            onChanged: maxSetsOnChanged,
          ),
        ),
      ],
    );
  }
}

class _RepsInput extends StatelessWidget {
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final TextEditingController minRepsController;
  final ValueChanged<String>? minRepsOnChanged;
  final TextEditingController maxRepsController;
  final ValueChanged<String>? maxRepsOnChanged;
  final bool isMaxReps;
  final ValueChanged<bool?> onIsMaxRepsChanged;

  const _RepsInput({
    required this.minRepsController,
    required this.minRepsOnChanged,
    required this.maxRepsController,
    required this.maxRepsOnChanged,
    required this.isLoading,
    required this.sizes,
    required this.theme,
    required this.isMaxReps,
    required this.onIsMaxRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "💪",
          style: TextStyle(fontSize: sizes.fontSize * 1.2),
        ),
        SizedBox(width: halfSpacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: isLoading,
            controller: minRepsController,
            labelText: "Reps",
            hintText: "0",
            keyboardType: TextInputType.number,
            fontSize: sizes.fontSize,
            padding: sizes.padding,
            validator: (value) {
              if (value == null) {
                return "Min reps is required";
              }

              final intReps = int.tryParse(value);
              if (intReps == null) {
                return "Invalid number";
              }

              if (intReps < 1) {
                return "Min reps must be at least 1";
              }

              return null;
            },
            onChanged: minRepsOnChanged,
          ),
        ),
        SizedBox(width: halfSpacing),
        Icon(Icons.remove, size: sizes.fontSize * 1.2),
        if (isMaxReps) ...[
          SizedBox(width: halfSpacing),
          Expanded(
            child: AppTextFormField(
              filled: true,
              theme: theme,
              isLoading: isLoading,
              controller: maxRepsController,
              labelText: "Max Reps",
              hintText: "0",
              keyboardType: TextInputType.number,
              fontSize: sizes.fontSize,
              padding: sizes.padding,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                final intReps = int.tryParse(value);
                if (intReps == null) {
                  return "Invalid number";
                }

                if (intReps < 0) {
                  return "Max reps must be at least 0";
                }

                return null;
              },
              onChanged: maxRepsOnChanged,
            ),
          ),
        ],
        SizedBox(width: halfSpacing),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("To Max"),
            Switch(
              value: isMaxReps,
              onChanged: (value) => onIsMaxRepsChanged(value),
            ),
          ],
        ),
      ],
    );
  }
}

class _RestInput extends StatelessWidget {
  final TextEditingController restController;
  final ValueChanged<String>? restOnChanged;
  final TextEditingController maxRestController;
  final ValueChanged<String>? maxRestOnChanged;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isLoading;

  const _RestInput({
    required this.restController,
    required this.restOnChanged,
    required this.maxRestController,
    required this.maxRestOnChanged,
    required this.sizes,
    required this.theme,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: sizes.fontSize * 1.2),
        SizedBox(width: halfSpacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: isLoading,
            controller: restController,
            labelText: "Recommended Rest",
            hintText: "0",
            keyboardType: TextInputType.number,
            fontSize: sizes.fontSize,
            padding: sizes.padding,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              final intRest = int.tryParse(value);
              if (intRest == null) {
                return "Invalid number";
              }

              if (intRest < 0) {
                return "Rest must be at least 0";
              }

              return null;
            },
            onChanged: restOnChanged,
          ),
        ),
        SizedBox(width: halfSpacing),
        Icon(Icons.remove, size: sizes.fontSize * 1.2),
        SizedBox(width: halfSpacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: isLoading,
            controller: maxRestController,
            labelText: "Max Rest",
            hintText: "0",
            keyboardType: TextInputType.number,
            fontSize: sizes.fontSize,
            padding: sizes.padding,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              final intRest = int.tryParse(value);
              if (intRest == null) {
                return "Invalid number";
              }

              if (intRest < 0) {
                return "Max rest must be at least 0";
              }

              return null;
            },
            onChanged: maxRestOnChanged,
          ),
        ),
      ],
    );
  }
}
