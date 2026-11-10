// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';

import '../../../../utils/nullable.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../../data/repositories/macros/inputs/macro_goal_input.dart';
import '../../../core/utils/converters.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/icons_switch.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/layout/responsive_fields.dart';
import './macro_goal_day_group_card.dart';

class MacroGoalForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MacroGoalDto? existingGoal;
  final bool isLoading;
  final String? submitLabel;
  final IconData? submitIcon;
  final void Function(MacroGoalInput input) onSubmit;

  const MacroGoalForm({
    super.key,
    required this.theme,
    required this.sizes,
    this.existingGoal,
    this.isLoading = false,
    this.submitLabel,
    this.submitIcon,
    required this.onSubmit,
  });

  @override
  State<MacroGoalForm> createState() => _MacroGoalFormState();
}

class _MacroGoalFormState extends State<MacroGoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final _FormData _data;
  String? _dayValidationError;

  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _waterController;

  static const Map<DayOfWeek, String> _dayLabels = {
    DayOfWeek.monday: 'Mon',
    DayOfWeek.tuesday: 'Tue',
    DayOfWeek.wednesday: 'Wed',
    DayOfWeek.thursday: 'Thu',
    DayOfWeek.friday: 'Fri',
    DayOfWeek.saturday: 'Sat',
    DayOfWeek.sunday: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    final goalType = g?.goalType ?? MacroGoalType.flat;
    final name = g?.name ?? 'Daily Target';
    final calories = g?.targetCalories ?? 2000;
    final protein = g?.targetProtein ?? 150;
    final carbs = g?.targetCarbs ?? 200;
    final fat = g?.targetFat ?? 65;
    final water = g?.targetWaterIntakeMl ?? 2500;
    bool calcFromMacros = true;
    if (g != null) {
      calcFromMacros =
          g.targetCalories ==
          Converters.macrosToCalories(
            protein: g.targetProtein,
            carbs: g.targetCarbs,
            fats: g.targetFat,
          );
    }

    _data = _FormData(
      goalType: goalType,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      water: water,
      calculateCaloriesFromMacros: calcFromMacros,
    );

    _nameController = TextEditingController(text: _data.name);
    _caloriesController = TextEditingController(
      text: _data.calories.toString(),
    );
    _proteinController = TextEditingController(text: _data.protein.toString());
    _carbsController = TextEditingController(text: _data.carbs.toString());
    _fatController = TextEditingController(text: _data.fat.toString());
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
    _initDayGroups(g);
  }

  void _initDayGroups(MacroGoalDto? g) {
    if (g != null &&
        g.goalType == MacroGoalType.calorieCycling &&
        g.days.isNotEmpty) {
      _data.cyclingGroupsCustomized = true;
      for (int i = 0; i < g.days.length; i++) {
        final d = g.days[i];
        final isCalculated =
            d.targetCalories ==
            Converters.macrosToCalories(
              protein: d.targetProtein,
              carbs: d.targetCarbs,
              fats: d.targetFat,
            );
        _data.dayGroups.add(
          DayGroupFormState(
            calories: d.targetCalories.toString(),
            protein: d.targetProtein.toString(),
            carbs: d.targetCarbs.toString(),
            fat: d.targetFat.toString(),
            water: d.targetWaterIntakeMl?.toString() ?? '',
            days: d.days,
            preservedName: d.name,
            preservedFiber: d.targetFiber,
            preservedSodium: d.targetSodium,
            preservedPhase: d.phase,
            calculateCaloriesFromMacros: isCalculated,
            onChanged: _onDayGroupChanged,
          ),
        );
      }
    }
  }

  void _createDefaultCyclingGroups() {
    for (final group in _data.dayGroups) {
      group.dispose();
    }
    _data.dayGroups.clear();
    _data.cyclingGroupsCustomized = false;
    final baseProtein = _proteinController.text.isNotEmpty
        ? _proteinController.text
        : '150';
    final baseCarbs = _carbsController.text.isNotEmpty
        ? _carbsController.text
        : '200';
    final baseFat = _fatController.text.isNotEmpty ? _fatController.text : '65';
    final baseWater = _waterController.text;
    final weekendCarbs = ((int.tryParse(baseCarbs) ?? 200) + 50).toString();
    final existingDay =
        widget.existingGoal != null && widget.existingGoal!.days.length == 1
        ? widget.existingGoal!.days.first
        : null;
    final preservedFiber =
        existingDay?.targetFiber ?? widget.existingGoal?.targetFiber;
    final preservedSodium =
        existingDay?.targetSodium ?? widget.existingGoal?.targetSodium;
    final preservedPhase = existingDay?.phase ?? widget.existingGoal?.phase;

    _data.dayGroups.add(
      DayGroupFormState(
        calories: _caloriesController.text,
        protein: baseProtein,
        carbs: baseCarbs,
        fat: baseFat,
        water: baseWater,
        days: const [
          DayOfWeek.monday,
          DayOfWeek.tuesday,
          DayOfWeek.wednesday,
          DayOfWeek.thursday,
          DayOfWeek.friday,
        ],
        preservedFiber: preservedFiber,
        preservedSodium: preservedSodium,
        preservedPhase: preservedPhase,
        calculateCaloriesFromMacros: _data.calculateCaloriesFromMacros,
        onChanged: _onDayGroupChanged,
      ),
    );
    _data.dayGroups.add(
      DayGroupFormState(
        calories: _caloriesController.text,
        protein: baseProtein,
        carbs: weekendCarbs,
        fat: baseFat,
        water: baseWater,
        days: const [DayOfWeek.saturday, DayOfWeek.sunday],
        preservedFiber: preservedFiber,
        preservedSodium: preservedSodium,
        preservedPhase: preservedPhase,
        calculateCaloriesFromMacros: _data.calculateCaloriesFromMacros,
        onChanged: _onDayGroupChanged,
      ),
    );
  }

  void _onDayGroupChanged() {
    _data.cyclingGroupsCustomized = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _setGoalType(MacroGoalType type) {
    if (_data.goalType == type) return;
    setState(() {
      _data.goalType = type;
      _dayValidationError = null;
      if (type == MacroGoalType.calorieCycling &&
          (_data.dayGroups.isEmpty || !_data.cyclingGroupsCustomized)) {
        _createDefaultCyclingGroups();
      }
    });
  }

  void _updateCalculatedCalories() {
    if (!_data.calculateCaloriesFromMacros) return;
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

  String? _validateOptionalMacro(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    return parsed == null || parsed < 0
        ? 'Enter a non-negative whole number'
        : null;
  }

  void _toggleDayForGroup(int groupIndex, DayOfWeek day, bool selected) {
    setState(() {
      _data.cyclingGroupsCustomized = true;
      _dayValidationError = null;
      if (selected) {
        for (int i = 0; i < _data.dayGroups.length; i++) {
          if (i != groupIndex) {
            _data.dayGroups[i].selectedDays.remove(day);
          }
        }
        _data.dayGroups[groupIndex].selectedDays.add(day);
      } else {
        _data.dayGroups[groupIndex].selectedDays.remove(day);
      }
    });
  }

  void _addDayGroup() {
    if (_data.dayGroups.length >= 7) return;
    final assigned = <DayOfWeek>{
      for (final g in _data.dayGroups) ...g.selectedDays,
    };
    final unassigned = DayOfWeek.values
        .where((d) => !assigned.contains(d))
        .toList();
    final initialDays = unassigned.isNotEmpty
        ? <DayOfWeek>[unassigned.first]
        : <DayOfWeek>[];
    final sourceGroup = _data.dayGroups.isNotEmpty
        ? _data.dayGroups.last
        : null;
    final existingDay =
        widget.existingGoal != null && widget.existingGoal!.days.isNotEmpty
        ? widget.existingGoal!.days.first
        : null;

    setState(() {
      _data.cyclingGroupsCustomized = true;
      _dayValidationError = null;
      _data.dayGroups.add(
        DayGroupFormState(
          calories:
              sourceGroup?.caloriesController.text ??
              (_caloriesController.text.isNotEmpty
                  ? _caloriesController.text
                  : '2000'),
          protein:
              sourceGroup?.proteinController.text ??
              (_proteinController.text.isNotEmpty
                  ? _proteinController.text
                  : '150'),
          carbs:
              sourceGroup?.carbsController.text ??
              (_carbsController.text.isNotEmpty
                  ? _carbsController.text
                  : '200'),
          fat:
              sourceGroup?.fatController.text ??
              (_fatController.text.isNotEmpty ? _fatController.text : '65'),
          water: sourceGroup?.waterController.text ?? _waterController.text,
          days: initialDays,
          preservedFiber:
              sourceGroup?.preservedFiber ??
              existingDay?.targetFiber ??
              widget.existingGoal?.targetFiber,
          preservedSodium:
              sourceGroup?.preservedSodium ??
              existingDay?.targetSodium ??
              widget.existingGoal?.targetSodium,
          preservedPhase:
              sourceGroup?.preservedPhase ??
              existingDay?.phase ??
              widget.existingGoal?.phase,
          calculateCaloriesFromMacros:
              sourceGroup?.calculateCaloriesFromMacros ??
              _data.calculateCaloriesFromMacros,
          onChanged: _onDayGroupChanged,
        ),
      );
    });
  }

  void _removeDayGroup(int index) {
    if (_data.dayGroups.length <= 2) return;
    setState(() {
      _data.cyclingGroupsCustomized = true;
      _dayValidationError = null;
      final removed = _data.dayGroups.removeAt(index);
      removed.dispose();
    });
  }

  ({int totalCalories, int avgCalories, Set<DayOfWeek> missingDays})
  _computeCyclingSummary() {
    int totalCals = 0;
    final assigned = <DayOfWeek>{};
    for (final g in _data.dayGroups) {
      final cals = int.tryParse(g.caloriesController.text) ?? 0;
      totalCals += cals * g.selectedDays.length;
      assigned.addAll(g.selectedDays);
    }
    final missing = DayOfWeek.values
        .where((d) => !assigned.contains(d))
        .toSet();
    return (
      totalCalories: totalCals,
      avgCalories: (totalCals / 7).round(),
      missingDays: missing,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    for (final group in _data.dayGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final name = _data.name.trim().isEmpty ? 'Daily Target' : _data.name.trim();
    final phase = widget.existingGoal?.phase ?? WeightGoalPhase.maintain;
    final isActive = widget.existingGoal?.isActive ?? true;

    if (_data.goalType == MacroGoalType.flat) {
      final calories = int.tryParse(_caloriesController.text) ?? _data.calories;
      final protein = int.tryParse(_proteinController.text) ?? _data.protein;
      final carbs = int.tryParse(_carbsController.text) ?? _data.carbs;
      final fat = int.tryParse(_fatController.text) ?? _data.fat;
      final water = _data.water;
      final existingDay =
          widget.existingGoal != null && widget.existingGoal!.days.length == 1
          ? widget.existingGoal!.days.first
          : null;
      final preservedFiber =
          existingDay?.targetFiber ?? widget.existingGoal?.targetFiber;
      final preservedSodium =
          existingDay?.targetSodium ?? widget.existingGoal?.targetSodium;

      final input = MacroGoalInput(
        name: name,
        targetCalories: calories,
        targetProtein: protein,
        targetCarbs: carbs,
        targetFat: fat,
        targetFiber: Nullable(preservedFiber),
        targetSodium: Nullable(preservedSodium),
        targetWaterIntakeMl: Nullable(water),
        goalType: MacroGoalType.flat,
        days: [
          DayMacroGoalInput(
            name: name,
            days: DayOfWeek.values,
            targetCalories: calories,
            targetProtein: protein,
            targetCarbs: carbs,
            targetFat: fat,
            targetFiber: Nullable(preservedFiber),
            targetSodium: Nullable(preservedSodium),
            targetWaterIntakeMl: Nullable(water),
            phase: phase,
            isActive: isActive,
          ),
        ],
        phase: phase,
        isActive: isActive,
      );

      widget.onSubmit(input);
      return;
    }

    // Calorie cycling validation
    if (_data.dayGroups.length < 2) {
      setState(() {
        _dayValidationError =
            'Calorie cycling requires at least two day groups.';
      });
      return;
    }
    for (int i = 0; i < _data.dayGroups.length; i++) {
      if (_data.dayGroups[i].selectedDays.isEmpty) {
        setState(() {
          _dayValidationError =
              'Each day group must have at least one day selected.';
        });
        return;
      }
    }
    final summary = _computeCyclingSummary();
    if (summary.missingDays.isNotEmpty) {
      final missingNames = summary.missingDays
          .map((d) => _dayLabels[d]!)
          .join(', ');
      setState(() {
        _dayValidationError = 'Assign all 7 days (missing: $missingNames).';
      });
      return;
    }

    final dayInputs = <DayMacroGoalInput>[];
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int totalFiber = 0;
    bool hasFiber = false;
    int totalSodium = 0;
    bool hasSodium = false;
    int totalWater = 0;
    bool hasWater = false;

    for (int i = 0; i < _data.dayGroups.length; i++) {
      final g = _data.dayGroups[i];
      final sortedDays = g.selectedDays.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final calories = int.parse(g.caloriesController.text);
      final protein = int.parse(g.proteinController.text);
      final carbs = int.parse(g.carbsController.text);
      final fat = int.parse(g.fatController.text);
      final water = int.tryParse(g.waterController.text.trim());

      final count = sortedDays.length;
      totalCalories += calories * count;
      totalProtein += protein * count;
      totalCarbs += carbs * count;
      totalFat += fat * count;
      if (g.preservedFiber != null) {
        hasFiber = true;
        totalFiber += g.preservedFiber! * count;
      }
      if (g.preservedSodium != null) {
        hasSodium = true;
        totalSodium += g.preservedSodium! * count;
      }
      if (water != null) {
        hasWater = true;
        totalWater += water * count;
      }

      dayInputs.add(
        DayMacroGoalInput(
          name: g.preservedName,
          days: sortedDays,
          targetCalories: calories,
          targetProtein: protein,
          targetCarbs: carbs,
          targetFat: fat,
          targetFiber: Nullable(g.preservedFiber),
          targetSodium: Nullable(g.preservedSodium),
          targetWaterIntakeMl: Nullable(water),
          phase: g.preservedPhase ?? phase,
          isActive: isActive,
        ),
      );
    }

    final input = MacroGoalInput(
      name: name,
      targetCalories: (totalCalories / 7).round(),
      targetProtein: (totalProtein / 7).round(),
      targetCarbs: (totalCarbs / 7).round(),
      targetFat: (totalFat / 7).round(),
      targetFiber: Nullable(hasFiber ? (totalFiber / 7).round() : null),
      targetSodium: Nullable(hasSodium ? (totalSodium / 7).round() : null),
      targetWaterIntakeMl: Nullable(hasWater ? (totalWater / 7).round() : null),
      goalType: MacroGoalType.calorieCycling,
      days: dayInputs,
      phase: phase,
      isActive: isActive,
    );

    widget.onSubmit(input);
  }

  Widget _buildFlatFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFormField(
          theme: widget.theme,
          fontSize: widget.sizes.fontSize,
          padding: widget.sizes.padding,
          isLoading: widget.isLoading,
          key: const ValueKey('macro-goal-calories-input'),
          controller: _caloriesController,
          readOnly: _data.calculateCaloriesFromMacros,
          keyboardType: TextInputType.number,
          labelText: 'Daily Calories (kcal) *',
          validator: _validateMacro,
          onSaved: (v) {
            if (v != null) {
              _data.calories = int.tryParse(v) ?? 0;
            }
          },
        ),
        SizedBox(height: widget.sizes.spacing),
        CheckboxListTile(
          key: const ValueKey('macro-goal-calculate-calories-checkbox'),
          value: _data.calculateCaloriesFromMacros,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Calculate calories from macros',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
          onChanged: (value) {
            setState(() {
              _data.calculateCaloriesFromMacros = value ?? false;
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
              isLoading: widget.isLoading,
              key: const ValueKey('macro-goal-protein-input'),
              controller: _proteinController,
              keyboardType: TextInputType.number,
              labelText: 'Protein (g) *',
              validator: _validateMacro,
              onSaved: (v) {
                if (v != null) {
                  _data.protein = int.tryParse(v) ?? 0;
                }
              },
            ),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('macro-goal-carbs-input'),
              controller: _carbsController,
              keyboardType: TextInputType.number,
              labelText: 'Carbs (g) *',
              validator: _validateMacro,
              onSaved: (v) {
                if (v != null) {
                  _data.carbs = int.tryParse(v) ?? 0;
                }
              },
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
              isLoading: widget.isLoading,
              key: const ValueKey('macro-goal-fat-input'),
              controller: _fatController,
              keyboardType: TextInputType.number,
              labelText: 'Fat (g) *',
              validator: _validateMacro,
              onSaved: (v) {
                if (v != null) {
                  _data.fat = int.tryParse(v) ?? 0;
                }
              },
            ),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('macro-goal-water-input'),
              controller: _waterController,
              keyboardType: TextInputType.number,
              labelText: 'Water (ml)',
              validator: _validateOptionalMacro,
              onSaved: (v) {
                _data.water = int.tryParse(v?.trim() ?? '');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCyclingFormFields() {
    final summary = _computeCyclingSummary();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(widget.sizes.padding),
          color: widget.theme.colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Total: ${summary.totalCalories} kcal',
                key: const ValueKey('macro-goal-weekly-total-text'),
                style: TextStyle(
                  fontSize: widget.sizes.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Daily Average: ${summary.avgCalories} kcal / day',
                key: const ValueKey('macro-goal-daily-avg-text'),
                style: TextStyle(fontSize: widget.sizes.smallFontSize),
              ),
            ],
          ),
        ),
        if (_dayValidationError != null) ...[
          SizedBox(height: widget.sizes.spacing / 2),
          Text(
            _dayValidationError!,
            key: const ValueKey('macro-goal-days-error'),
            style: TextStyle(
              fontSize: widget.sizes.smallFontSize,
              color: widget.theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: widget.sizes.spacing),
        for (int i = 0; i < _data.dayGroups.length; i++) ...[
          MacroGoalDayGroupCard(
            index: i,
            group: _data.dayGroups[i],
            canRemove: _data.dayGroups.length > 2,
            theme: widget.theme,
            sizes: widget.sizes,
            dayLabels: _dayLabels,
            onRemove: () => _removeDayGroup(i),
            onToggleDay: (day, selected) =>
                _toggleDayForGroup(i, day, selected),
            onToggleCalculateCalories: (value) {
              setState(() {
                _data.cyclingGroupsCustomized = true;
                _data.dayGroups[i].setCalculateCalories(value);
              });
            },
            validateMacro: _validateMacro,
            validateOptionalMacro: _validateOptionalMacro,
          ),
          SizedBox(height: widget.sizes.spacing),
        ],
        if (_data.dayGroups.length < 7)
          OutlinedButton.icon(
            key: const ValueKey('macro-goal-add-day-group-btn'),
            onPressed: _addDayGroup,
            icon: Icon(Icons.add, size: widget.sizes.buttonIconSize),
            label: Text(
              'Add Day Group',
              style: TextStyle(fontSize: widget.sizes.fontSize),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextFormField(
            theme: widget.theme,
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            key: const ValueKey('macro-goal-name-input'),
            controller: _nameController,
            labelText: 'Goal Name *',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onSaved: (v) {
              _data.name = v ?? '';
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          Wrap(
            key: const ValueKey('macro-goal-type-selector'),
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: widget.sizes.spacing,
            runSpacing: widget.sizes.spacing / 2,
            children: [
              InkWell(
                key: const ValueKey('macro-goal-type-flat'),
                onTap: () => _setGoalType(MacroGoalType.flat),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.sizes.padding / 2,
                  ),
                  child: Text(
                    'Flat Week',
                    style: TextStyle(
                      fontSize: widget.sizes.fontSize,
                      fontWeight: _data.goalType == MacroGoalType.flat
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _data.goalType == MacroGoalType.flat
                          ? widget.theme.colorScheme.primary
                          : widget.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              IconsSwitch(
                key: const ValueKey('macro-goal-type-switch'),
                theme: widget.theme,
                offIcon: Icons.calendar_view_week,
                onIcon: Icons.sync,
                switchOn: _data.goalType == MacroGoalType.calorieCycling,
                spacing: widget.sizes.spacing / 2,
                switchPadding: widget.sizes.padding / 4,
                thumbSize: widget.sizes.subtitleFontSize * 1.1,
                iconSize: widget.sizes.titleFontSize,
                onChanged: (bool value) {
                  _setGoalType(
                    value ? MacroGoalType.calorieCycling : MacroGoalType.flat,
                  );
                },
              ),
              InkWell(
                key: const ValueKey('macro-goal-type-cycling'),
                onTap: () => _setGoalType(MacroGoalType.calorieCycling),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.sizes.padding / 2,
                  ),
                  child: Text(
                    'Calorie Cycling',
                    style: TextStyle(
                      fontSize: widget.sizes.fontSize,
                      fontWeight: _data.goalType == MacroGoalType.calorieCycling
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _data.goalType == MacroGoalType.calorieCycling
                          ? widget.theme.colorScheme.primary
                          : widget.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          if (_data.goalType == MacroGoalType.flat)
            _buildFlatFormFields()
          else
            _buildCyclingFormFields(),
          SizedBox(height: widget.sizes.spacing * 1.5),
          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              key: const ValueKey('macro-goal-submit-button'),
              theme: widget.theme,
              isLoading: widget.isLoading,
              sizes: widget.sizes,
              onPressed: _submit,
              label:
                  widget.submitLabel ??
                  (widget.existingGoal != null ? 'Update' : 'Create'),
              icon: widget.submitIcon ?? Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  MacroGoalType goalType;
  String name;
  int calories;
  int protein;
  int carbs;
  int fat;
  int? water;
  bool calculateCaloriesFromMacros;
  bool cyclingGroupsCustomized = false;
  final List<DayGroupFormState> dayGroups;

  _FormData({
    required this.goalType,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.water,
    this.calculateCaloriesFromMacros = true,
    List<DayGroupFormState>? dayGroups,
  }) : dayGroups = dayGroups ?? [];
}
