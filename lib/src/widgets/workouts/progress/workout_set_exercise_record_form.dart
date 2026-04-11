import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/common.dart';
import '../../../models/enums.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_text_form_field.dart';
import '../workout_set_exercise_difficulty_input.dart';
import 'workout_rest_duration_input.dart';

const List<double> _weightDecimalValues = [0.0, 0.25, 0.5, 0.75];
const List<String> _weightDecimalLabels = ['.00', '.25', '.50', '.75'];

class WorkoutSetExerciseRecordForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final bool isLoading;
  final int initialWeight;
  final int initialReps;
  final int initialDifficulty;
  final WorkoutSetExerciseDifficultyType initialDifficultyType;

  final void Function({
    required double weight,
    required int reps,
    required WorkoutSetExerciseDifficulty difficulty,
  }) onValuesChanged;

  final bool showIterationRest;
  final int initialRestSecs;
  final ValueChanged<int>? onRestSecsChanged;

  const WorkoutSetExerciseRecordForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.isLoading,
    required this.initialWeight,
    required this.initialReps,
    required this.initialDifficulty,
    required this.initialDifficultyType,
    required this.onValuesChanged,
    this.showIterationRest = false,
    this.initialRestSecs = 0,
    this.onRestSecsChanged,
  });

  @override
  State<WorkoutSetExerciseRecordForm> createState() =>
      _WorkoutSetExerciseRecordFormState();
}

class _WorkoutSetExerciseRecordFormState
    extends State<WorkoutSetExerciseRecordForm> {
  int _weightHundreds = 0;
  int _weightTens = 0;
  double _weightDecimals = 0.0;
  int _reps = 0;

  late WorkoutSetExerciseDifficultyType _difficultyType;
  late int _difficultyValue;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _difficultyType = widget.initialDifficultyType;
    _difficultyValue = widget.initialDifficulty;
    _applyIntegerWeight(widget.initialWeight);
    _reps = widget.initialReps;
    _weightController = TextEditingController(text: _formatWeightDisplay());
    _repsController = TextEditingController(text: '$_reps');
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitValues());
  }

  @override
  void didUpdateWidget(covariant WorkoutSetExerciseRecordForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWeight != widget.initialWeight) {
      _applyIntegerWeight(widget.initialWeight);
      _weightController.text = _formatWeightDisplay();
    }
    if (oldWidget.initialReps != widget.initialReps) {
      _reps = widget.initialReps;
      _repsController.text = '$_reps';
    }
    if (oldWidget.initialDifficultyType != widget.initialDifficultyType ||
        oldWidget.initialDifficulty != widget.initialDifficulty) {
      _difficultyType = widget.initialDifficultyType;
      _difficultyValue = widget.initialDifficulty;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _applyIntegerWeight(int grams) {
    final double converted = widget.units == Units.metric
        ? Converters.gramsToKg(grams)
        : Converters.gramsToLbs(grams);

    final int intPart = converted.truncate();
    _weightHundreds = intPart ~/ 100;
    _weightTens = intPart % 100;

    final double decimals = converted - intPart;
    if (decimals >= 0.875) {
      _weightTens += 1;
      if (_weightTens == 100) {
        _weightTens = 0;
        _weightHundreds += 1;
      }
      _weightDecimals = 0.0;
    } else if (decimals >= 0.625) {
      _weightDecimals = 0.75;
    } else if (decimals >= 0.375) {
      _weightDecimals = 0.5;
    } else if (decimals >= 0.125) {
      _weightDecimals = 0.25;
    } else {
      _weightDecimals = 0.0;
    }
  }

  String _formatWeightDisplay() {
    final double total =
        (_weightHundreds * 100) + _weightTens + _weightDecimals;
    return total.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }

  void _emitValues() {
    final double weight =
        (_weightHundreds * 100) + _weightTens + _weightDecimals;
    widget.onValuesChanged(
      weight: weight,
      reps: _reps,
      difficulty: WorkoutSetExerciseDifficulty.create(
        value: _difficultyValue,
        type: _difficultyType,
      ),
    );
  }

  void _openWeightWheel() {
    int tempHundreds = _weightHundreds;
    int tempTens = _weightTens;
    double tempDecimals = _weightDecimals;

    final hundredsController =
        FixedExtentScrollController(initialItem: tempHundreds);
    final tensController = FixedExtentScrollController(initialItem: tempTens);
    final decimalsController = FixedExtentScrollController(
      initialItem: _weightDecimalValues.indexOf(tempDecimals).clamp(0, 3),
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
                      'Weight (${widget.units == Units.metric ? "KG" : "LBS"})',
                      style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _weightHundreds = hundredsController.selectedItem;
                        _weightTens = tensController.selectedItem;
                        _weightDecimals = _weightDecimalValues[
                            decimalsController.selectedItem.clamp(
                          0,
                          3,
                        )];

                        _weightController.text = _formatWeightDisplay();
                      });
                      Navigator.of(sheetContext).pop();
                      _emitValues();
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
                            _weightDecimalLabels[index],
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
                      _emitValues();
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  isLoading: widget.isLoading,
                  filled: true,
                  suffixIcon: Text(
                    widget.units == Units.metric ? 'KG' : 'LB',
                    style: TextStyle(
                      fontSize: widget.sizes.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.scale,
                    size: widget.sizes.fontSize * 1.2,
                  ),
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
                  isLoading: widget.isLoading,
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
            initialDifficultyType: widget.initialDifficultyType,
            initialDifficultyValue: widget.initialDifficulty,
            theme: widget.theme,
            sizes: widget.sizes,
            onChanged: (type, value) {
              _difficultyType = type;
              _difficultyValue = value;
              _emitValues();
            },
          ),
          if (widget.showIterationRest) ...[
            SizedBox(height: widget.sizes.inputSpacing),
            WorkoutRestDurationInput(
              theme: widget.theme,
              sizes: widget.sizes,
              initialTotalSecs: widget.initialRestSecs,
              onChanged: widget.onRestSecsChanged ?? (_) {},
            ),
          ],
        ],
      ),
    );
  }
}
