import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/macro_tracking_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

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
    _caloriesController =
        TextEditingController(text: g?.targetCalories.toString() ?? '2000');
    _proteinController =
        TextEditingController(text: g?.targetProtein.toString() ?? '150');
    _carbsController =
        TextEditingController(text: g?.targetCarbs.toString() ?? '200');
    _fatController =
        TextEditingController(text: g?.targetFat.toString() ?? '65');
    _waterController = TextEditingController(
        text: g?.targetWaterIntakeMl?.toString() ?? '2500');
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
        id: widget.existingGoal!.id,
        name: name,
        targetCalories: calories,
        targetProtein: protein,
        targetCarbs: carbs,
        targetFat: fat,
        targetWaterIntakeMl: water,
        isActive: widget.existingGoal!.isActive,
      );
    } else {
      cubit.createMacroGoal(
        name: name,
        targetCalories: calories,
        targetProtein: protein,
        targetCarbs: carbs,
        targetFat: fat,
        targetWaterIntakeMl: water,
        phase: WeightGoalPhase.maintain,
        isActive: true,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                  TextFormField(
                    key: const ValueKey('macro-goal-name-input'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  TextFormField(
                    key: const ValueKey('macro-goal-calories-input'),
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily Calories (kcal) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('macro-goal-protein-input'),
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: widget.sizes.spacing),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('macro-goal-carbs-input'),
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Carbs (g) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('macro-goal-fat-input'),
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fat (g) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: widget.sizes.spacing),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('macro-goal-water-input'),
                          controller: _waterController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Water (ml)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.sizes.spacing * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: widget.sizes.spacing),
                      ElevatedButton(
                        key: const ValueKey('macro-goal-submit-button'),
                        onPressed: _submit,
                        child: Text(
                            widget.existingGoal != null ? 'Update' : 'Create'),
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
