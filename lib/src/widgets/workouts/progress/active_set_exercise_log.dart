import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/common.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/mutation_button.dart';
import '../../layout/app_dropdown.dart';
import '../../layout/app_number_wheel.dart';
import '../../layout/app_text_form_field.dart';

class ActiveSetExerciseLog extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;

  final WorkoutSetExerciseDifficultyType initialDifficultyType;
  final int initialDifficultyValue;
  final int workoutSetExerciseId;
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
    _weightController = TextEditingController(text: '0');
    _repsController = TextEditingController(text: '0');
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
    if (oldWidget.workoutSetExerciseId != widget.workoutSetExerciseId) {
      // Reset values for new exercise
      _weightHundreds = 0;
      _weightTens = 0;
      _weightDecimals = 0.0;
      _reps = 0;
      _difficultyType = widget.initialDifficultyType;
      _difficultyValue = widget.initialDifficultyValue;
      _weightController.text = '0';
      _repsController.text = '0';
    }
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

                        final double total = (_weightHundreds * 100) +
                            _weightTens +
                            _weightDecimals;
                        _weightController.text = total
                            .toStringAsFixed(2)
                            .replaceAll(RegExp(r'\.00$'), '');
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
                    prefixIcon: Icon(Icons.fitness_center,
                        size: widget.sizes.fontSize * 1.2),
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
                    prefixIcon:
                        Icon(Icons.repeat, size: widget.sizes.fontSize * 1.2),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.sizes.inputSpacing),
            _LogSetDifficultyInput(
              key: ValueKey(widget.workoutSetExerciseId),
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

class _LogSetDifficultyInput extends StatefulWidget {
  final WorkoutSetExerciseDifficultyType initialDifficultyType;
  final int initialDifficultyValue;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final void Function(
    WorkoutSetExerciseDifficultyType type,
    int value,
  ) onChanged;

  const _LogSetDifficultyInput({
    super.key,
    required this.initialDifficultyType,
    required this.initialDifficultyValue,
    required this.theme,
    required this.sizes,
    required this.onChanged,
  });

  @override
  State<_LogSetDifficultyInput> createState() => _LogSetDifficultyInputState();
}

class _LogSetDifficultyInputState extends State<_LogSetDifficultyInput> {
  late WorkoutSetExerciseDifficultyType _type;
  late int _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _type = widget.initialDifficultyType;
    _value = widget.initialDifficultyValue;
    _controller = TextEditingController(text: _formatValue(_value));
    widget.onChanged(_type, _value);
  }

  @override
  void didUpdateWidget(covariant _LogSetDifficultyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDifficultyType != widget.initialDifficultyType ||
        oldWidget.initialDifficultyValue != widget.initialDifficultyValue) {
      _type = widget.initialDifficultyType;
      _value = widget.initialDifficultyValue;
      _controller.text = _formatValue(_value);
      widget.onChanged(_type, _value);
    }
  }

  String _formatValue(int v) {
    if (_type == WorkoutSetExerciseDifficultyType.rmp) return '$v%';
    return '$v';
  }

  (int, int) get _range => (_type.minValue, _type.maxValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWheel() {
    final (minVal, maxVal) = _range;
    int initial = _value.clamp(minVal, maxVal);
    final controller = FixedExtentScrollController(
      initialItem: initial - minVal,
    );
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
                    'Difficulty (${_type.value})',
                    style: TextStyle(
                      fontSize: widget.sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final idx = controller.selectedItem;
                      final val = minVal + idx;
                      setState(() {
                        _value = val;
                        _controller.text = _formatValue(val);
                      });
                      widget.onChanged(_type, val);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: AppNumberWheel(
                minValue: minVal,
                maxValue: maxVal,
                scrollController: controller,
                itemExtent: widget.sizes.subtitleFontSize * 3,
                fontSize: widget.sizes.subtitleFontSize,
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AppTextFormField(
            theme: widget.theme,
            controller: _controller,
            readOnly: true,
            onTap: _openWheel,
            labelText: 'Difficulty',
            hintText: 'Value',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            isLoading: false,
            filled: true,
            prefixIcon: Icon(Icons.bolt, size: widget.sizes.fontSize * 1.2),
          ),
        ),
        SizedBox(width: widget.sizes.inputSpacing),
        Expanded(
          flex: 3,
          child: AppDropdown<WorkoutSetExerciseDifficultyType>(
            value: _type,
            emptyLabel: 'None',
            showEmptyValue: false,
            items: WorkoutSetExerciseDifficultyType.values,
            labelBuilder: (t) => t.value,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                _value = _value.clamp(v.minValue, v.maxValue);
                _controller.text = _formatValue(_value);
              });
              widget.onChanged(_type, _value);
            },
            onSaved: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                _value = _value.clamp(v.minValue, v.maxValue);
                _controller.text = _formatValue(_value);
              });
              widget.onChanged(_type, _value);
            },
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding * 0.4,
            filled: true,
          ),
        ),
      ],
    );
  }
}
