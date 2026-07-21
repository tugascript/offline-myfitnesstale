import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/common.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/mutation_button.dart';
import '../../layout/app_text_form_field.dart';
import '../workout_set_exercise_difficulty_input.dart';

class ActiveSetExerciseLog extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;

  final WorkoutSetExerciseDifficultyType initialDifficultyType;
  final int initialDifficultyValue;
  final int workoutSetExerciseId;
  final int setNumber;
  final double initialWeight;
  final int initialReps;
  final bool isOptional;

  final void Function({
    required double weight,
    required int reps,
    required WorkoutSetExerciseDifficulty difficulty,
  }) onLogSet;
  final VoidCallback onSkip;

  const ActiveSetExerciseLog({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.initialDifficultyType,
    required this.initialDifficultyValue,
    required this.workoutSetExerciseId,
    this.setNumber = 1,
    this.initialWeight = 0,
    this.initialReps = 0,
    required this.isLoading,
    required this.onLogSet,
    required this.onSkip,
    required this.isOptional,
  });

  @override
  State<ActiveSetExerciseLog> createState() => _ActiveSetExerciseLogState();
}

class _ActiveSetExerciseLogState extends State<ActiveSetExerciseLog> {
  int _weightHundreds = 0;
  int _weightTens = 0;
  double _weightDecimals = 0.0;
  int _reps = 0;

  late WorkoutSetExerciseDifficultyType _difficultyType;
  late int _difficultyValue;

  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  final List<double> _decimalValues = [0.0, 0.25, 0.5, 0.75];
  final List<String> _decimalLabels = ['.00', '.25', '.50', '.75'];

  @override
  void initState() {
    super.initState();
    _difficultyType = widget.initialDifficultyType;
    _difficultyValue = widget.initialDifficultyValue;
    _applyInitialValues();
    _weightController = TextEditingController(text: _formatWeight());
    _repsController = TextEditingController(text: '$_reps');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActiveSetExerciseLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutSetExerciseId != widget.workoutSetExerciseId ||
        oldWidget.setNumber != widget.setNumber ||
        oldWidget.initialWeight != widget.initialWeight ||
        oldWidget.initialReps != widget.initialReps) {
      _applyInitialValues();
      _difficultyType = widget.initialDifficultyType;
      _difficultyValue = widget.initialDifficultyValue;
      _weightController.text = _formatWeight();
      _repsController.text = '$_reps';
    }
  }

  void _applyInitialValues() {
    final roundedWeight = (widget.initialWeight * 4).round() / 4;
    final integerWeight = roundedWeight.truncate();
    _weightHundreds = integerWeight ~/ 100;
    _weightTens = integerWeight % 100;
    _weightDecimals = roundedWeight - integerWeight;
    _reps = widget.initialReps;
  }

  String _formatWeight() {
    final total = (_weightHundreds * 100) + _weightTens + _weightDecimals;
    return total.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }

  void _openWeightWheel() {
    int tempHundreds = _weightHundreds;
    int tempTens = _weightTens;
    double tempDecimals = _weightDecimals;

    final hundredsController =
        FixedExtentScrollController(initialItem: tempHundreds);
    final tensController = FixedExtentScrollController(initialItem: tempTens);
    final decimalsController = FixedExtentScrollController(
        initialItem: _decimalValues.indexOf(tempDecimals).clamp(0, 3));

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  Text(
                      'Weight (${widget.units == Units.metric ? "KG" : "LBS"})',
                      style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _weightHundreds = hundredsController.selectedItem;
                        _weightTens = tensController.selectedItem;
                        _weightDecimals = _decimalValues[
                            decimalsController.selectedItem.clamp(0, 3)];

                        _weightController.text = _formatWeight();
                      });
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: widget.sizes.subtitleFontSize * 3,
                      scrollController: hundredsController,
                      onSelectedItemChanged: (_) {},
                      children: List.generate(
                        widget.units == Units.metric ? 6 : 11,
                        (index) => Center(
                          child: Text(
                            '$index',
                            style: TextStyle(
                                fontSize: widget.sizes.subtitleFontSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: widget.sizes.subtitleFontSize * 3,
                      scrollController: tensController,
                      onSelectedItemChanged: (_) {},
                      children: List.generate(
                        100,
                        (index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: widget.sizes.subtitleFontSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: widget.sizes.subtitleFontSize * 3,
                      scrollController: decimalsController,
                      onSelectedItemChanged: (_) {},
                      children: List.generate(
                        4,
                        (index) => Center(
                          child: Text(
                            _decimalLabels[index],
                            style: TextStyle(
                                fontSize: widget.sizes.subtitleFontSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      hundredsController.dispose();
      tensController.dispose();
      decimalsController.dispose();
    });
  }

  void _openRepsWheel() {
    int tempReps = _reps;
    final controller = FixedExtentScrollController(initialItem: tempReps);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  Text('Reps',
                      style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _reps = controller.selectedItem;
                        _repsController.text = '$_reps';
                      });
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: CupertinoPicker(
                itemExtent: widget.sizes.subtitleFontSize * 3,
                scrollController: controller,
                onSelectedItemChanged: (_) {},
                children: List.generate(
                  100,
                  (index) => Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(fontSize: widget.sizes.subtitleFontSize),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    theme: widget.theme,
                    controller: _weightController,
                    readOnly: true,
                    onTap: _openWeightWheel,
                    labelText: 'Weight',
                    hintText: '0',
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    filled: true,
                    prefixIcon:
                        Icon(Icons.scale, size: widget.sizes.fontSize * 1.2),
                  ),
                ),
                SizedBox(width: widget.sizes.inputSpacing),
                Expanded(
                  child: AppTextFormField(
                    theme: widget.theme,
                    controller: _repsController,
                    readOnly: true,
                    onTap: _openRepsWheel,
                    labelText: 'Reps',
                    hintText: '0',
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.repeat_one,
                      size: widget.sizes.fontSize * 1.2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.sizes.inputSpacing),
            WorkoutSetExerciseDifficultyInput(
              key: ValueKey(
                (widget.workoutSetExerciseId, widget.setNumber),
              ),
              initialDifficultyType: widget.initialDifficultyType,
              initialDifficultyValue: widget.initialDifficultyValue,
              theme: widget.theme,
              sizes: widget.sizes,
              onChanged: (type, value) {
                _difficultyType = type;
                _difficultyValue = value;
              },
            ),
            SizedBox(height: widget.sizes.inputSpacing),
            SizedBox(
              width: double.infinity,
              child: MutationButton(
                theme: widget.theme,
                isLoading: widget.isLoading,
                sizes: widget.sizes,
                isDense: true,
                onPressed: () {
                  final double weight =
                      (_weightHundreds * 100) + _weightTens + _weightDecimals;
                  widget.onLogSet(
                    weight: weight,
                    reps: _reps,
                    difficulty: WorkoutSetExerciseDifficulty.create(
                      value: _difficultyValue,
                      type: _difficultyType,
                    ),
                  );
                },
                label: "Log Set",
                icon: Icons.add,
              ),
            ),
            if (widget.isOptional) ...[
              SizedBox(height: widget.sizes.inputSpacing),
              SizedBox(
                width: double.infinity,
                child: MutationButton(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  isLoading: widget.isLoading,
                  icon: Icons.skip_next,
                  color: widget.theme.colorScheme.secondary,
                  isDense: true,
                  label: "Skip to next group",
                  onPressed: widget.onSkip,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
