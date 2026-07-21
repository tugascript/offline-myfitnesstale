import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/common.dart';
import '../../../models/enums.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_text_form_field.dart';
import '../workout_set_exercise_difficulty_input.dart';
import 'workout_rest_duration_input.dart';

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
  double _weight = 0;
  int _reps = 0;

  late WorkoutSetExerciseDifficultyType _difficultyType;
  late int _difficultyValue;

  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  static final _decimalInputFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        RegExp(r'^\d*(?:\.\d{0,3})?$').hasMatch(newValue.text)
            ? newValue
            : oldValue,
  );

  @override
  void initState() {
    super.initState();
    _difficultyType = widget.initialDifficultyType;
    _difficultyValue = widget.initialDifficulty;
    _weight = _displayWeight(widget.initialWeight);
    _reps = widget.initialReps;
    _weightController = TextEditingController(text: _formatWeight(_weight));
    _repsController = TextEditingController(text: '$_reps');
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitValues());
  }

  @override
  void didUpdateWidget(covariant WorkoutSetExerciseRecordForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWeight != widget.initialWeight ||
        oldWidget.units != widget.units) {
      _weight = _displayWeight(widget.initialWeight);
      _weightController.text = _formatWeight(_weight);
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

  double _displayWeight(int grams) {
    return widget.units == Units.metric
        ? Converters.gramsToKg(grams)
        : Converters.gramsToLbs(grams);
  }

  String _formatWeight(double weight) {
    return weight
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _emitValues() {
    widget.onValuesChanged(
      weight: _weight,
      reps: _reps,
      difficulty: WorkoutSetExerciseDifficulty.create(
        value: _difficultyValue,
        type: _difficultyType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  key: const ValueKey('manual-weight-input'),
                  theme: widget.theme,
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_decimalInputFormatter],
                  onChanged: (value) {
                    _weight = double.tryParse(value) ?? 0;
                    _emitValues();
                  },
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
                  key: const ValueKey('manual-reps-input'),
                  theme: widget.theme,
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    _reps = int.tryParse(value) ?? 0;
                    _emitValues();
                  },
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
