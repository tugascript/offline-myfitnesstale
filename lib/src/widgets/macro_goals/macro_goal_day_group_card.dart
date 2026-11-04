import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/app_text_form_field.dart';
import '../layout/responsive_fields.dart';

class DayGroupFormState {
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextEditingController waterController;
  final Set<DayOfWeek> selectedDays;
  final String? preservedName;
  final int? preservedFiber;
  final int? preservedSodium;
  final WeightGoalPhase? preservedPhase;
  bool calculateCaloriesFromMacros;
  final VoidCallback onChanged;
  bool _initializing = true;

  DayGroupFormState({
    required String calories,
    required String protein,
    required String carbs,
    required String fat,
    required String water,
    required Iterable<DayOfWeek> days,
    this.preservedName,
    this.preservedFiber,
    this.preservedSodium,
    this.preservedPhase,
    this.calculateCaloriesFromMacros = true,
    required this.onChanged,
  }) : caloriesController = TextEditingController(text: calories),
       proteinController = TextEditingController(text: protein),
       carbsController = TextEditingController(text: carbs),
       fatController = TextEditingController(text: fat),
       waterController = TextEditingController(text: water),
       selectedDays = Set<DayOfWeek>.from(days) {
    for (final c in [proteinController, carbsController, fatController]) {
      c.addListener(_onMacroEdited);
    }
    caloriesController.addListener(_notifyChanged);
    waterController.addListener(_notifyChanged);
    _recalculate();
    _initializing = false;
  }

  void _notifyChanged() {
    if (!_initializing) {
      onChanged();
    }
  }

  void _onMacroEdited() {
    _recalculate();
    _notifyChanged();
  }

  void _recalculate() {
    if (!calculateCaloriesFromMacros) return;
    final protein = int.tryParse(proteinController.text);
    final carbs = int.tryParse(carbsController.text);
    final fat = int.tryParse(fatController.text);
    if (protein == null ||
        carbs == null ||
        fat == null ||
        protein < 0 ||
        carbs < 0 ||
        fat < 0) {
      caloriesController.clear();
    } else {
      caloriesController.text = Converters.macrosToCalories(
        protein: protein,
        carbs: carbs,
        fats: fat,
      ).toString();
    }
  }

  void setCalculateCalories(bool value) {
    calculateCaloriesFromMacros = value;
    _recalculate();
    _notifyChanged();
  }

  void dispose() {
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    waterController.dispose();
  }
}

class MacroGoalDayGroupCard extends StatelessWidget {
  final int index;
  final DayGroupFormState group;
  final bool canRemove;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Map<DayOfWeek, String> dayLabels;
  final VoidCallback onRemove;
  final void Function(DayOfWeek day, bool selected) onToggleDay;
  final ValueChanged<bool> onToggleCalculateCalories;
  final FormFieldValidator<String> validateMacro;
  final FormFieldValidator<String> validateOptionalMacro;

  const MacroGoalDayGroupCard({
    super.key,
    required this.index,
    required this.group,
    required this.canRemove,
    required this.theme,
    required this.sizes,
    required this.dayLabels,
    required this.onRemove,
    required this.onToggleDay,
    required this.onToggleCalculateCalories,
    required this.validateMacro,
    required this.validateOptionalMacro,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('macro-goal-day-group-$index'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: sizes.spacing / 2,
              runSpacing: sizes.spacing / 2,
              children: [
                Text(
                  'Day Group ${index + 1}',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    key: ValueKey('macro-goal-remove-group-$index'),
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.delete_outline,
                      size: sizes.buttonIconSize,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            Wrap(
              spacing: sizes.spacing / 3,
              runSpacing: sizes.spacing / 3,
              children: [
                for (final day in DayOfWeek.values)
                  FilterChip(
                    key: ValueKey('macro-goal-group-$index-day-${day.value}'),
                    label: Text(
                      dayLabels[day]!,
                      style: TextStyle(fontSize: sizes.smallFontSize),
                    ),
                    selected: group.selectedDays.contains(day),
                    onSelected: (selected) => onToggleDay(day, selected),
                  ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            AppTextFormField(
              theme: theme,
              fontSize: sizes.fontSize,
              padding: sizes.padding,
              isLoading: false,
              key: ValueKey('macro-goal-group-$index-calories-input'),
              controller: group.caloriesController,
              readOnly: group.calculateCaloriesFromMacros,
              keyboardType: TextInputType.number,
              labelText: 'Daily Calories (kcal) *',
              validator: validateMacro,
            ),
            SizedBox(height: sizes.spacing / 2),
            CheckboxListTile(
              key: ValueKey(
                'macro-goal-group-$index-calculate-calories-checkbox',
              ),
              value: group.calculateCaloriesFromMacros,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Calculate calories from macros',
                style: TextStyle(fontSize: sizes.fontSize),
              ),
              onChanged: (value) => onToggleCalculateCalories(value ?? false),
            ),
            SizedBox(height: sizes.spacing / 2),
            ResponsiveFields(
              sizes: sizes,
              children: [
                AppTextFormField(
                  theme: theme,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-protein-input'),
                  controller: group.proteinController,
                  keyboardType: TextInputType.number,
                  labelText: 'Protein (g) *',
                  validator: validateMacro,
                ),
                AppTextFormField(
                  theme: theme,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-carbs-input'),
                  controller: group.carbsController,
                  keyboardType: TextInputType.number,
                  labelText: 'Carbs (g) *',
                  validator: validateMacro,
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            ResponsiveFields(
              sizes: sizes,
              children: [
                AppTextFormField(
                  theme: theme,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-fat-input'),
                  controller: group.fatController,
                  keyboardType: TextInputType.number,
                  labelText: 'Fat (g) *',
                  validator: validateMacro,
                ),
                AppTextFormField(
                  theme: theme,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-water-input'),
                  controller: group.waterController,
                  keyboardType: TextInputType.number,
                  labelText: 'Water (ml)',
                  validator: validateOptionalMacro,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
