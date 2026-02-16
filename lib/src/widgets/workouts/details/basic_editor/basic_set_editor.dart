import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_text_form_field.dart';
import '../../../layout/sharp_switch.dart';
import '../editors/set_exercise_search_modal.dart';
import 'set_editor_data.dart';

class BasicSetEditor extends StatelessWidget {
  final SetEditorData setData;
  final DataDisplaySizesList sizes;
  final TextEditingController? minSetsController;
  final TextEditingController? maxSetsController;
  final TextEditingController? minRepsController;
  final TextEditingController? maxRepsController;
  final TextEditingController? restController;
  final TextEditingController? maxRestController;
  final ValueChanged<(int, String)>? onExerciseChanged;
  final ValueChanged<String>? onMinSetsChanged;
  final ValueChanged<String>? onMaxSetsChanged;
  final ValueChanged<String>? onMinRepsChanged;
  final ValueChanged<String>? onMaxRepsChanged;
  final ValueChanged<bool?>? onToMaxRepsChanged;
  final ValueChanged<String>? onRestChanged;
  final ValueChanged<String>? onMaxRestChanged;

  const BasicSetEditor({
    super.key,
    required this.setData,
    required this.sizes,
    this.minSetsController,
    this.maxSetsController,
    this.minRepsController,
    this.maxRepsController,
    this.restController,
    this.maxRestController,
    this.onToMaxRepsChanged,
    this.onExerciseChanged,
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
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SetsInput(
              initialMinSets: setData.minSets,
              initialMaxSets: setData.maxSets,
              minSetsController: minSetsController,
              minSetsOnChanged: onMinSetsChanged,
              maxSetsController: maxSetsController,
              maxSetsOnChanged: onMaxSetsChanged,
              sizes: sizes,
              theme: theme,
            ),
            SizedBox(height: sizes.spacing),
            _RepsInput(
              initialMinReps: setData.minReps,
              initialMaxReps: setData.maxReps,
              minRepsController: minRepsController,
              minRepsOnChanged: onMinRepsChanged,
              maxRepsController: maxRepsController,
              maxRepsOnChanged: onMaxRepsChanged,
              sizes: sizes,
              theme: theme,
              toMaxReps: setData.toMaxReps,
              onToMaxRepsChanged: onToMaxRepsChanged,
            ),
            SizedBox(height: sizes.spacing),
            _ExerciseSelectionButton(
              exerciseName: setData.exerciseName,
              sizes: sizes,
              theme: theme,
              onPressed: () {
                if (onExerciseChanged == null) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return SetExerciseSearchModal(
                      sizes: sizes,
                      isLoading: false,
                      onExerciseSelected: (id, name) {
                        onExerciseChanged!((id, name));
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: sizes.spacing),
            _RestInput(
              initialRest: setData.recommendedRestSecs,
              initialMaxRest: setData.maxRestSecs,
              restController: restController,
              restOnChanged: onRestChanged,
              maxRestController: maxRestController,
              maxRestOnChanged: onMaxRestChanged,
              sizes: sizes,
              theme: theme,
            ),
          ],
        ),
      ),
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
    return Row(
      children: [
        Icon(Icons.fitness_center, size: sizes.fontSize * 1.2),
        SizedBox(width: sizes.spacing),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary,
                width: 0.5,
              ),
            ),
            onPressed: onPressed,
            child: Text(
              exerciseName == null ? "Select Exercise" : exerciseName!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SetsInput extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int initialMinSets;
  final int? initialMaxSets;
  final TextEditingController? minSetsController;
  final ValueChanged<String>? minSetsOnChanged;
  final TextEditingController? maxSetsController;
  final ValueChanged<String>? maxSetsOnChanged;

  const _SetsInput({
    this.minSetsController,
    this.minSetsOnChanged,
    this.maxSetsController,
    this.maxSetsOnChanged,
    required this.sizes,
    required this.theme,
    required this.initialMinSets,
    this.initialMaxSets,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.repeat, size: sizes.fontSize * 1.2),
        SizedBox(width: sizes.spacing),
        Expanded(
          child: AppTextFormField(
            filled: true,
            theme: theme,
            isLoading: false,
            initialValue: initialMinSets.toString(),
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
            isLoading: false,
            initialValue: initialMaxSets?.toString(),
            controller: maxSetsController,
            labelText: "Max",
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
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int initialMinReps;
  final int? initialMaxReps;
  final TextEditingController? minRepsController;
  final ValueChanged<String>? minRepsOnChanged;
  final TextEditingController? maxRepsController;
  final ValueChanged<String>? maxRepsOnChanged;
  final bool toMaxReps;
  final ValueChanged<bool?>? onToMaxRepsChanged;

  const _RepsInput({
    required this.initialMinReps,
    this.initialMaxReps,
    this.minRepsController,
    this.minRepsOnChanged,
    this.maxRepsController,
    this.maxRepsOnChanged,
    required this.sizes,
    required this.theme,
    required this.toMaxReps,
    this.onToMaxRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
        SizedBox(width: sizes.spacing),
        Expanded(
          child: AppTextFormField(
            initialValue: initialMinReps.toString(),
            filled: true,
            theme: theme,
            isLoading: false,
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
        if (!toMaxReps) ...[
          SizedBox(width: halfSpacing),
          Expanded(
            child: AppTextFormField(
              initialValue: initialMaxReps?.toString(),
              filled: true,
              theme: theme,
              isLoading: false,
              controller: maxRepsController,
              labelText: "Max",
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
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "To Max",
              style: TextStyle(fontSize: sizes.fontSize),
            ),
            SharpSwitch(
              value: toMaxReps,
              onChanged: (value) => onToMaxRepsChanged?.call(value),
              thumbSize: sizes.subtitleFontSize * 1.15,
            ),
          ],
        ),
      ],
    );
  }
}

class _RestInput extends StatelessWidget {
  final int initialRest;
  final int? initialMaxRest;
  final TextEditingController? restController;
  final ValueChanged<String>? restOnChanged;
  final TextEditingController? maxRestController;
  final ValueChanged<String>? maxRestOnChanged;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const _RestInput({
    required this.initialRest,
    this.initialMaxRest,
    this.restController,
    this.restOnChanged,
    this.maxRestController,
    this.maxRestOnChanged,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: sizes.fontSize * 1.2),
        SizedBox(width: sizes.spacing),
        Expanded(
          child: AppTextFormField(
            initialValue: initialRest.toString(),
            filled: true,
            theme: theme,
            isLoading: false,
            controller: restController,
            labelText: "Rest",
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
            initialValue: initialMaxRest?.toString(),
            theme: theme,
            isLoading: false,
            controller: maxRestController,
            labelText: "Max",
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
