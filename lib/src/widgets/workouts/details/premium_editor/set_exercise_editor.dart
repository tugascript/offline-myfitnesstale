import 'package:flutter/material.dart';

import '../../../../models/common.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/exercise_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_dropdown.dart';
import '../../../layout/app_number_wheel.dart';
import '../../../layout/app_text_form_field.dart';
import '../editors/exercise_selection_button.dart';
import '../editors/reps_input.dart';
import '../editors/set_exercise_search_modal.dart';
import 'alternative_exercises_input.dart';
import 'complex_set_editor_data.dart';

class SetExerciseEditor extends StatelessWidget {
  final ComplexSetExerciseEditorData exerciseData;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<ExerciseDto>? onExerciseChanged;
  final ValueChanged<String>? onMinRepsChanged;
  final ValueChanged<String>? onMaxRepsChanged;
  final ValueChanged<bool?>? onToMaxRepsChanged;
  final ValueChanged<WorkoutSetExerciseDifficultyType?>?
      onDifficultyTypeChanged;
  final ValueChanged<String>? onDifficultyValueChanged;
  final ValueChanged<Set<AlternativeExerciseData>>?
      onAlternativeExercisesChanged;

  const SetExerciseEditor({
    super.key,
    required this.exerciseData,
    required this.sizes,
    required this.isLoading,
    this.onExerciseChanged,
    this.onMinRepsChanged,
    this.onMaxRepsChanged,
    this.onToMaxRepsChanged,
    this.onDifficultyTypeChanged,
    this.onDifficultyValueChanged,
    this.onAlternativeExercisesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = exerciseData.difficulty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepsInput(
              initialMinReps: exerciseData.minReps,
              initialMaxReps: exerciseData.maxReps,
              minRepsOnChanged: onMinRepsChanged,
              maxRepsOnChanged: onMaxRepsChanged,
              sizes: sizes,
              theme: theme,
              toMaxReps: exerciseData.toMaxReps,
              onToMaxRepsChanged: onToMaxRepsChanged,
            ),
            SizedBox(height: sizes.spacing / 2),
            ExerciseSelectionButton(
              exerciseName: exerciseData.exerciseName,
              sizes: sizes,
              theme: theme,
              onPressed: () {
                if (onExerciseChanged == null) {
                  return;
                }

                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return SetExerciseSearchModal(
                      sizes: sizes,
                      isLoading: isLoading,
                      onExerciseSelected: (exercise) {
                        onExerciseChanged!(exercise);
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: sizes.spacing / 2),
            _DifficultyInput(
              difficulty: difficulty,
              sizes: sizes,
              theme: theme,
              onDifficultyValueChanged: onDifficultyValueChanged,
              isLoading: isLoading,
              onDifficultyTypeChanged: onDifficultyTypeChanged,
            ),
            if (exerciseData.exerciseId != null) ...[
              SizedBox(height: sizes.spacing / 2),
              AlternativeExercisesInput(
                sizes: sizes,
                exerciseData: exerciseData,
                theme: theme,
                isLoading: isLoading,
                onAlternativesChanged: onAlternativeExercisesChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DifficultyInput extends StatelessWidget {
  final WorkoutSetExerciseDifficulty? difficulty;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final ValueChanged<String>? onDifficultyValueChanged;
  final bool isLoading;
  final ValueChanged<WorkoutSetExerciseDifficultyType?>?
      onDifficultyTypeChanged;

  const _DifficultyInput({
    required this.difficulty,
    required this.sizes,
    required this.theme,
    required this.onDifficultyValueChanged,
    required this.isLoading,
    required this.onDifficultyTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _DifficultyTypeInput(
            label: "Difficulty",
            initialValue: difficulty?.value.toString() ?? "",
            difficultyType: difficulty?.type,
            sizes: sizes,
            theme: theme,
            onChanged: onDifficultyValueChanged,
            enabled: !isLoading,
          ),
        ),
        SizedBox(width: sizes.spacing / 2),
        Expanded(
          flex: 3,
          child: AppDropdown<WorkoutSetExerciseDifficultyType>(
            value: difficulty?.type,
            emptyLabel: "None",
            items: WorkoutSetExerciseDifficultyType.values,
            labelBuilder: (s) => s.value,
            onChanged: (v) {
              if (isLoading) {
                return;
              }

              onDifficultyTypeChanged?.call(v);
            },
            onSaved: (v) {
              if (isLoading) {
                return;
              }

              onDifficultyTypeChanged?.call(v);
            },
            fontSize: sizes.fontSize,
            padding: sizes.padding * 0.4,
            filled: true,
          ),
        ),
      ],
    );
  }
}

class _DifficultyTypeInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final WorkoutSetExerciseDifficultyType? difficultyType;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const _DifficultyTypeInput({
    required this.label,
    required this.initialValue,
    required this.difficultyType,
    required this.onChanged,
    required this.enabled,
    required this.sizes,
    required this.theme,
  });

  @override
  State<_DifficultyTypeInput> createState() => _DifficultyTypeInputState();
}

class _DifficultyTypeInputState extends State<_DifficultyTypeInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: _formatValue(widget.initialValue, widget.difficultyType));
  }

  @override
  void didUpdateWidget(covariant _DifficultyTypeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue ||
        oldWidget.difficultyType != widget.difficultyType) {
      _controller.text =
          _formatValue(widget.initialValue, widget.difficultyType);
    }
  }

  String _formatValue(String val, WorkoutSetExerciseDifficultyType? type) {
    if (val.isEmpty) return val;
    if (type == WorkoutSetExerciseDifficultyType.rmp) {
      final parsed = double.tryParse(val);
      if (parsed != null && !val.endsWith('%')) {
        // Parse as integer to remove trailing zeros if possible
        return '${parsed.toInt()}%';
      }
    }
    return val;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (int, int, int) _getRanges() {
    switch (widget.difficultyType) {
      case WorkoutSetExerciseDifficultyType.rir:
        return (0, 5, 0); // min, max, initial
      case WorkoutSetExerciseDifficultyType.rpe:
        return (1, 10, 8);
      case WorkoutSetExerciseDifficultyType.rmp:
        return (50, 100, 75);
      default:
        return (0, 10, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.difficultyType == null) {
      return AppTextFormField(
        readOnly: true,
        enabled: false,
        fontSize: widget.sizes.fontSize,
        labelText: "Difficulty",
        theme: widget.theme,
        padding: widget.sizes.padding,
        isLoading: false,
        filled: true,
        prefixIcon: Icon(
          Icons.bolt,
          size: widget.sizes.fontSize * 1.2,
        ),
      );
    }

    return AppTextFormField(
      controller: _controller,
      readOnly: true,
      onTap: !widget.enabled
          ? null
          : () {
              final ranges = _getRanges();
              final minVal = ranges.$1;
              final maxVal = ranges.$2;
              final defaultVal = ranges.$3;

              String numStr = _controller.text.replaceAll('%', '');
              int initial = int.tryParse(numStr) ?? defaultVal;
              if (initial < minVal) initial = minVal;
              if (initial > maxVal) initial = maxVal;

              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => _DifficultyWheelSheetContent(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  initialValue: initial,
                  minVal: minVal,
                  maxVal: maxVal,
                  difficultyType: widget.difficultyType!,
                  onChanged: (val) {
                    _controller.text = _formatValue(val, widget.difficultyType);
                    widget.onChanged?.call(val);
                  },
                ),
              );
            },
      theme: widget.theme,
      labelText: widget.label,
      hintText: 'Value',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(
        Icons.bolt,
        size: widget.sizes.fontSize * 1.2,
      ),
    );
  }
}

class _DifficultyWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialValue;
  final int minVal;
  final int maxVal;
  final WorkoutSetExerciseDifficultyType difficultyType;
  final ValueChanged<String> onChanged;

  const _DifficultyWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialValue,
    required this.minVal,
    required this.maxVal,
    required this.difficultyType,
    required this.onChanged,
  });

  @override
  State<_DifficultyWheelSheetContent> createState() =>
      _DifficultyWheelSheetContentState();
}

class _DifficultyWheelSheetContentState
    extends State<_DifficultyWheelSheetContent> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
        initialItem: widget.initialValue - widget.minVal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final index = _controller.selectedItem;
    final val = widget.minVal + index;
    widget.onChanged(val.toString());
    Navigator.of(context).pop();
  }

  String _getHelperText() {
    switch (widget.difficultyType) {
      case WorkoutSetExerciseDifficultyType.rir:
        return "(0 is hardest, 5 is easiest)";
      case WorkoutSetExerciseDifficultyType.rpe:
        return "(1 is easiest, 10 is hardest)";
      case WorkoutSetExerciseDifficultyType.rmp:
        return "(percentage of your 1-rep max)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final wheelItemExtent = widget.sizes.subtitleFontSize * 3;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(widget.sizes.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Difficulty',
                        style: TextStyle(
                            fontSize: widget.sizes.subtitleFontSize,
                            fontWeight: FontWeight.w600)),
                    Text(
                      _getHelperText(),
                      style: TextStyle(
                          fontSize: widget.sizes.fontSize * 0.8,
                          color: Colors.grey),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _onConfirm,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: wheelItemExtent * 5,
            child: AppNumberWheel(
              minValue: widget.minVal,
              maxValue: widget.maxVal,
              scrollController: _controller,
              itemExtent: wheelItemExtent,
              fontSize: widget.sizes.subtitleFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
