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

import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/max_strength_calculator.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';

class StrengthGoalForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final String? initialName;
  final String initialWeight;
  final String initialReps;
  final int? initialExerciseId;
  final List<ExerciseDto> exercises;
  final bool showExerciseSelection;
  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;
  final Units units;
  final void Function({
    String? name,
    required double targetWeight,
    required int targetReps,
    required int targetMaxStrength,
    required int exerciseId,
  })
  onSubmit;

  const StrengthGoalForm({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialName,
    this.initialWeight = '',
    this.initialReps = '',
    this.initialExerciseId,
    this.exercises = const [],
    this.showExerciseSelection = false,
    required this.isLoading,
    required this.submitLabel,
    this.submitIcon,
    required this.units,
    required this.onSubmit,
  });

  @override
  State<StrengthGoalForm> createState() => _StrengthGoalFormState();
}

class _StrengthGoalFormState extends State<StrengthGoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _maxStrengthController;
  int? _selectedExerciseId;
  int _calculatedMaxStrengthGrams = 0;

  @override
  void initState() {
    super.initState();
    _selectedExerciseId = widget.initialExerciseId;
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _weightController = TextEditingController(text: widget.initialWeight);
    _repsController = TextEditingController(text: widget.initialReps);
    _maxStrengthController = TextEditingController();

    _weightController.addListener(_updateCalculatedMaxStrength);
    _repsController.addListener(_updateCalculatedMaxStrength);
    _updateCalculatedMaxStrength();
  }

  @override
  void didUpdateWidget(covariant StrengthGoalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.units != widget.units) {
      _updateCalculatedMaxStrength();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _maxStrengthController.dispose();
    super.dispose();
  }

  void _updateCalculatedMaxStrength() {
    final targetWeight = double.tryParse(_weightController.text.trim());
    final targetReps = int.tryParse(_repsController.text.trim());

    if (targetWeight == null ||
        targetWeight <= 0 ||
        targetReps == null ||
        targetReps < 1 ||
        targetReps > 10) {
      _calculatedMaxStrengthGrams = 0;
      if (_maxStrengthController.text.isNotEmpty) {
        _maxStrengthController.clear();
      }
      return;
    }

    final targetWeightGrams = widget.units == Units.imperial
        ? Converters.lbsToGrams(targetWeight)
        : Converters.kgToGrams(targetWeight);
    final maxStrengthGrams = MaxStrengthCalculator.calculateMaxStrength(
      targetReps,
      targetWeightGrams,
    );
    _calculatedMaxStrengthGrams = maxStrengthGrams;

    final displayMaxStrength = widget.units == Units.imperial
        ? Converters.gramsToLbs(maxStrengthGrams)
        : Converters.gramsToKg(maxStrengthGrams);
    final formatted = displayMaxStrength.toStringAsFixed(1);
    if (_maxStrengthController.text != formatted) {
      _maxStrengthController.text = formatted;
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final exerciseId = widget.showExerciseSelection
        ? _selectedExerciseId
        : widget.initialExerciseId;
    if (exerciseId == null) {
      return;
    }

    _updateCalculatedMaxStrength();
    final trimmedName = _nameController.text.trim();
    final name = trimmedName.isEmpty ? null : trimmedName;
    final targetWeight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final targetReps = int.tryParse(_repsController.text.trim()) ?? 1;

    widget.onSubmit(
      name: name,
      targetWeight: targetWeight,
      targetReps: targetReps,
      targetMaxStrength: _calculatedMaxStrengthGrams,
      exerciseId: exerciseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightUnitLabel = widget.units == Units.imperial ? 'lbs' : 'kg';
    final exerciseNamesById = {
      for (final exercise in widget.exercises) exercise.id: exercise.name,
    };

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showExerciseSelection) ...[
            AppDropdown<int>(
              key: const ValueKey('strength-goal-exercise-dropdown'),
              theme: widget.theme,
              filled: true,
              isLoading: widget.isLoading,
              value: _selectedExerciseId,
              emptyLabel: 'Exercise',
              labelText: 'Exercise',
              items: widget.exercises.map((e) => e.id).toList(),
              fontSize: widget.sizes.subtitleFontSize,
              padding: widget.sizes.padding,
              labelBuilder: (id) => exerciseNamesById[id] ?? '$id',
              onChanged: (value) {
                setState(() {
                  _selectedExerciseId = value;
                });
              },
              onSaved: (value) {
                _selectedExerciseId = value;
              },
              validator: (value) =>
                  value == null ? 'Please select an exercise' : null,
            ),
            SizedBox(height: widget.sizes.spacing),
          ],
          AppTextFormField(
            key: const ValueKey('strength-goal-weight-input'),
            filled: true,
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            labelText: 'Target Weight ($weightUnitLabel)',
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              final num = double.tryParse(val.trim());
              if (num == null || num <= 0) return 'Must be positive';
              return null;
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            key: const ValueKey('strength-goal-reps-input'),
            filled: true,
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _repsController,
            keyboardType: TextInputType.number,
            labelText: 'Target Reps (1-10)',
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              final num = int.tryParse(val.trim());
              if (num == null || num < 1 || num > 10) {
                return 'Must be between 1 and 10';
              }
              return null;
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            key: const ValueKey('strength-goal-max-strength-input'),
            filled: true,
            readOnly: true,
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _maxStrengthController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            labelText: 'Target 1RM ($weightUnitLabel)',
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            key: const ValueKey('strength-goal-name-input'),
            filled: true,
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _nameController,
            labelText: 'Goal Name (optional)',
          ),
          SizedBox(height: widget.sizes.spacing),
          AppElevatedButton(
            key: const ValueKey('strength-goal-submit-button'),
            isLoading: widget.isLoading,
            onPressed: _handleSubmit,
            sizes: widget.sizes,
            theme: widget.theme,
            label: widget.submitLabel,
            icon: widget.submitIcon ?? Icons.add,
          ),
        ],
      ),
    );
  }
}
