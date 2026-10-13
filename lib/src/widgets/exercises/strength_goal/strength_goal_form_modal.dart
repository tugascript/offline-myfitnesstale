import '../../layout/app_text_form_field.dart';
import '../../../common/nullable.dart';
import '../../../services/inputs/strength_goal_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/exercise_cubit.dart';
import '../../../cubits/exercise_record_cubit.dart';
import '../../../cubits/profile_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/strength_goal_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';

class StrengthGoalFormModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final StrengthGoalDto? existingGoal;

  const StrengthGoalFormModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.existingGoal,
  });

  @override
  State<StrengthGoalFormModal> createState() => _StrengthGoalFormModalState();
}

class _StrengthGoalFormModalState extends State<StrengthGoalFormModal> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedExerciseId;
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _maxStrengthController;

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    _selectedExerciseId = goal?.exerciseId;
    _nameController =
        TextEditingController(text: goal?.name ?? 'Strength Target');

    final profileUnits =
        context.read<ProfileCubit>().state.system?.units ?? Units.metric;
    final double weightVal = goal != null
        ? (profileUnits == Units.imperial
            ? Converters.gramsToLbs(goal.targetWeight)
            : Converters.gramsToKg(goal.targetWeight))
        : 0.0;

    _weightController = TextEditingController(
      text: goal != null ? weightVal.toStringAsFixed(1) : '',
    );
    _repsController = TextEditingController(
      text: goal?.targetReps.toString() ?? '10',
    );
    _maxStrengthController = TextEditingController(
      text: goal?.targetMaxStrength.toString() ?? '100',
    );

    // Load exercises if empty
    final exerciseState = context.read<ExerciseCubit>().state;
    if (exerciseState.exercises.isEmpty) {
      context.read<ExerciseCubit>().getExercises(limit: 100);
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select an exercise',
                style: TextStyle(fontSize: widget.sizes.fontSize))),
      );
      return;
    }

    final profileUnits =
        context.read<ProfileCubit>().state.system?.units ?? Units.metric;
    final parsedWeight = double.tryParse(_weightController.text) ?? 0.0;
    final targetWeightGrams = profileUnits == Units.imperial
        ? Converters.lbsToGrams(parsedWeight)
        : Converters.kgToGrams(parsedWeight);
    final targetReps = int.tryParse(_repsController.text) ?? 1;
    final targetMaxStrength = int.tryParse(_maxStrengthController.text) ?? 0;
    final name = _nameController.text.trim().isEmpty
        ? 'Strength Target'
        : _nameController.text.trim();

    final cubit = context.read<ExerciseRecordCubit>();
    if (widget.existingGoal != null) {
      cubit.updateStrengthGoal(
          widget.existingGoal!.id,
          StrengthGoalInput(
            name: name,
            targetWeight: targetWeightGrams,
            targetReps: targetReps,
            targetMaxStrength: targetMaxStrength,
            status: widget.existingGoal!.status,
            exerciseId: widget.existingGoal!.exerciseId,
            startDate: widget.existingGoal!.startDate,
            completedAt: Nullable(widget.existingGoal!.completedAt),
          ));
    } else {
      cubit.createStrengthGoal(StrengthGoalInput(
        exerciseId: _selectedExerciseId!,
        name: name,
        targetWeight: targetWeightGrams,
        targetReps: targetReps,
        targetMaxStrength: targetMaxStrength,
        startDate: DateTime.now(),
        status: ProgressStatus.inProgress,
      ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileUnits =
        context.watch<ProfileCubit>().state.system?.units ?? Units.metric;
    final weightUnitLabel = profileUnits == Units.imperial ? 'lbs' : 'kg';
    final exercises = context.watch<ExerciseCubit>().state.exercises;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.sizes.modalMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(widget.sizes.padding * 1.5),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.existingGoal != null
                        ? 'Edit Strength Goal'
                        : 'Create Strength Goal',
                    style: TextStyle(
                      fontSize: widget.sizes.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    itemHeight: null,
                    iconSize: widget.sizes.buttonIconSize,
                    style: TextStyle(
                        fontSize: widget.sizes.fontSize,
                        color: widget.theme.textTheme.bodyMedium?.color),
                    key: const ValueKey('strength-goal-exercise-dropdown'),
                    initialValue: _selectedExerciseId,
                    decoration: const InputDecoration(
                      labelText: 'Exercise',
                      border: OutlineInputBorder(),
                    ),
                    items: exercises.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(e.name,
                            style: TextStyle(fontSize: widget.sizes.fontSize)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedExerciseId = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Please select an exercise' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('strength-goal-weight-input'),
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    labelText: 'Target Weight ($weightUnitLabel)',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final num = double.tryParse(val);
                      if (num == null || num <= 0) return 'Must be positive';
                      return null;
                    },
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('strength-goal-reps-input'),
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    labelText: 'Target Reps',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final num = int.tryParse(val);
                      if (num == null || num <= 0) return 'Must be positive';
                      return null;
                    },
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('strength-goal-max-strength-input'),
                    controller: _maxStrengthController,
                    keyboardType: TextInputType.number,
                    labelText: 'Target 1RM / Max Strength',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final num = int.tryParse(val);
                      if (num == null || num <= 0) return 'Must be positive';
                      return null;
                    },
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('strength-goal-name-input'),
                    controller: _nameController,
                    labelText: 'Goal Name *',
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing * 1.5),
                  Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: widget.sizes.spacing / 2,
                    runSpacing: widget.sizes.spacing / 2,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: TextStyle(fontSize: widget.sizes.fontSize)),
                      ),
                      SizedBox(width: widget.sizes.spacing),
                      ElevatedButton(
                        key: const ValueKey('strength-goal-submit-button'),
                        onPressed: _submit,
                        child: Text(
                            widget.existingGoal != null ? 'Update' : 'Create',
                            style: TextStyle(fontSize: widget.sizes.fontSize)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
