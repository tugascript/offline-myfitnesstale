import '../layout/responsive_fields.dart';
import '../layout/app_text_form_field.dart';
import '../../common/nullable.dart';
import '../../services/inputs/macro_goal_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/macro_tracking_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/converters.dart';

class MacroGoalFormModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MacroGoalDto? existingGoal;

  const MacroGoalFormModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.existingGoal,
  });

  @override
  State<MacroGoalFormModal> createState() => _MacroGoalFormModalState();
}

class _MacroGoalFormModalState extends State<MacroGoalFormModal> {
  final _formKey = GlobalKey<FormState>();
  bool _calculateCaloriesFromMacros = true;

  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _nameController = TextEditingController(text: g?.name ?? 'Daily Target');
    _caloriesController = TextEditingController(
      text: g?.targetCalories.toString() ?? '2000',
    );
    _proteinController = TextEditingController(
      text: g?.targetProtein.toString() ?? '150',
    );
    _carbsController = TextEditingController(
      text: g?.targetCarbs.toString() ?? '200',
    );
    _fatController = TextEditingController(
      text: g?.targetFat.toString() ?? '65',
    );
    _waterController = TextEditingController(
      text: g?.targetWaterIntakeMl?.toString() ?? '2500',
    );
    for (final controller in [
      _proteinController,
      _carbsController,
      _fatController,
    ]) {
      controller.addListener(_updateCalculatedCalories);
    }
    _updateCalculatedCalories();
  }

  void _updateCalculatedCalories() {
    if (!_calculateCaloriesFromMacros) return;
    final protein = int.tryParse(_proteinController.text);
    final carbs = int.tryParse(_carbsController.text);
    final fat = int.tryParse(_fatController.text);
    if (protein == null ||
        carbs == null ||
        fat == null ||
        protein < 0 ||
        carbs < 0 ||
        fat < 0) {
      _caloriesController.clear();
      return;
    }
    _caloriesController.text = Converters.macrosToCalories(
      protein: protein,
      carbs: carbs,
      fats: fat,
    ).toString();
  }

  String? _validateMacro(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final grams = int.tryParse(value);
    return grams == null || grams < 0
        ? 'Enter a non-negative whole number'
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim().isEmpty
        ? 'Daily Target'
        : _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text) ?? 2000;
    final protein = int.tryParse(_proteinController.text) ?? 150;
    final carbs = int.tryParse(_carbsController.text) ?? 200;
    final fat = int.tryParse(_fatController.text) ?? 65;
    final water = int.tryParse(_waterController.text);

    final cubit = context.read<MacroTrackingCubit>();
    if (widget.existingGoal != null) {
      cubit.updateMacroGoal(
        widget.existingGoal!.id,
        MacroGoalInput(
          name: name,
          targetCalories: calories,
          targetProtein: protein,
          targetCarbs: carbs,
          targetFat: fat,
          targetWaterIntakeMl: Nullable(water),
          isActive: widget.existingGoal!.isActive,
          phase: widget.existingGoal!.phase,
        ),
      );
    } else {
      cubit.createMacroGoal(
        MacroGoalInput(
          name: name,
          targetCalories: calories,
          targetProtein: protein,
          targetCarbs: carbs,
          targetFat: fat,
          targetWaterIntakeMl: Nullable(water),
          phase: WeightGoalPhase.maintain,
          isActive: true,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                        ? 'Edit Macro Goal'
                        : 'Create Macro Goal',
                    style: TextStyle(
                      fontSize: widget.sizes.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('macro-goal-name-input'),
                    controller: _nameController,
                    labelText: 'Goal Name *',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: false,
                    key: const ValueKey('macro-goal-calories-input'),
                    controller: _caloriesController,
                    readOnly: _calculateCaloriesFromMacros,
                    keyboardType: TextInputType.number,
                    labelText: 'Daily Calories (kcal) *',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  CheckboxListTile(
                    key: const ValueKey(
                      'macro-goal-calculate-calories-checkbox',
                    ),
                    value: _calculateCaloriesFromMacros,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      'Calculate calories from macros',
                      style: TextStyle(fontSize: widget.sizes.fontSize),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _calculateCaloriesFromMacros = value ?? false;
                        _updateCalculatedCalories();
                      });
                    },
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  ResponsiveFields(
                    sizes: widget.sizes,
                    children: [
                      AppTextFormField(
                        theme: widget.theme,
                        fontSize: widget.sizes.fontSize,
                        padding: widget.sizes.padding,
                        isLoading: false,
                        key: const ValueKey('macro-goal-protein-input'),
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        labelText: 'Protein (g) *',
                        validator: _validateMacro,
                      ),
                      AppTextFormField(
                        theme: widget.theme,
                        fontSize: widget.sizes.fontSize,
                        padding: widget.sizes.padding,
                        isLoading: false,
                        key: const ValueKey('macro-goal-carbs-input'),
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        labelText: 'Carbs (g) *',
                        validator: _validateMacro,
                      ),
                    ],
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  ResponsiveFields(
                    sizes: widget.sizes,
                    children: [
                      AppTextFormField(
                        theme: widget.theme,
                        fontSize: widget.sizes.fontSize,
                        padding: widget.sizes.padding,
                        isLoading: false,
                        key: const ValueKey('macro-goal-fat-input'),
                        controller: _fatController,
                        keyboardType: TextInputType.number,
                        labelText: 'Fat (g) *',
                        validator: _validateMacro,
                      ),
                      AppTextFormField(
                        theme: widget.theme,
                        fontSize: widget.sizes.fontSize,
                        padding: widget.sizes.padding,
                        isLoading: false,
                        key: const ValueKey('macro-goal-water-input'),
                        controller: _waterController,
                        keyboardType: TextInputType.number,
                        labelText: 'Water (ml)',
                      ),
                    ],
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
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: widget.sizes.fontSize),
                        ),
                      ),
                      SizedBox(width: widget.sizes.spacing),
                      ElevatedButton(
                        key: const ValueKey('macro-goal-submit-button'),
                        onPressed: _submit,
                        child: Text(
                          widget.existingGoal != null ? 'Update' : 'Create',
                          style: TextStyle(fontSize: widget.sizes.fontSize),
                        ),
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
