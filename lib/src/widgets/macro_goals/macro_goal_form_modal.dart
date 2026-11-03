import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/nullable.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/macro_tracking_dto.dart';
import '../../services/inputs/macro_goal_input.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/app_text_form_field.dart';
import '../layout/responsive_fields.dart';

class _DayGroupFormState {
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

  _DayGroupFormState({
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
      c.addListener(_recalculate);
    }
    caloriesController.addListener(onChanged);
    _recalculate();
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
  }

  void dispose() {
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    waterController.dispose();
  }
}

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
  late MacroGoalType _goalType;
  bool _calculateCaloriesFromMacros = true;
  String? _dayValidationError;

  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;

  final List<_DayGroupFormState> _dayGroups = [];

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
    _goalType = g?.goalType ?? MacroGoalType.flat;
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
    _initDayGroups(g);
  }

  void _initDayGroups(MacroGoalDto? g) {
    if (g != null &&
        g.goalType == MacroGoalType.calorieCycling &&
        g.days.isNotEmpty) {
      for (int i = 0; i < g.days.length; i++) {
        final d = g.days[i];
        _dayGroups.add(
          _DayGroupFormState(
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
            onChanged: _onDayGroupChanged,
          ),
        );
      }
    }
  }

  void _createDefaultCyclingGroups() {
    for (final group in _dayGroups) {
      group.dispose();
    }
    _dayGroups.clear();
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

    _dayGroups.add(
      _DayGroupFormState(
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
        calculateCaloriesFromMacros: _calculateCaloriesFromMacros,
        onChanged: _onDayGroupChanged,
      ),
    );
    _dayGroups.add(
      _DayGroupFormState(
        calories: _caloriesController.text,
        protein: baseProtein,
        carbs: weekendCarbs,
        fat: baseFat,
        water: baseWater,
        days: const [DayOfWeek.saturday, DayOfWeek.sunday],
        preservedFiber: preservedFiber,
        preservedSodium: preservedSodium,
        preservedPhase: preservedPhase,
        calculateCaloriesFromMacros: _calculateCaloriesFromMacros,
        onChanged: _onDayGroupChanged,
      ),
    );
  }

  void _onDayGroupChanged() {
    if (mounted) {
      setState(() {});
    }
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

  void _toggleDayForGroup(int groupIndex, DayOfWeek day, bool selected) {
    setState(() {
      _dayValidationError = null;
      if (selected) {
        for (int i = 0; i < _dayGroups.length; i++) {
          if (i != groupIndex) {
            _dayGroups[i].selectedDays.remove(day);
          }
        }
        _dayGroups[groupIndex].selectedDays.add(day);
      } else {
        _dayGroups[groupIndex].selectedDays.remove(day);
      }
    });
  }

  void _addDayGroup() {
    if (_dayGroups.length >= 7) return;
    final assigned = <DayOfWeek>{for (final g in _dayGroups) ...g.selectedDays};
    final unassigned = DayOfWeek.values
        .where((d) => !assigned.contains(d))
        .toList();
    final initialDays = unassigned.isNotEmpty
        ? <DayOfWeek>[unassigned.first]
        : <DayOfWeek>[];

    setState(() {
      _dayValidationError = null;
      _dayGroups.add(
        _DayGroupFormState(
          calories: _caloriesController.text.isNotEmpty
              ? _caloriesController.text
              : '2000',
          protein: _proteinController.text.isNotEmpty
              ? _proteinController.text
              : '150',
          carbs: _carbsController.text.isNotEmpty
              ? _carbsController.text
              : '200',
          fat: _fatController.text.isNotEmpty ? _fatController.text : '65',
          water: _waterController.text,
          days: initialDays,
          onChanged: _onDayGroupChanged,
        ),
      );
    });
  }

  void _removeDayGroup(int index) {
    if (_dayGroups.length <= 1) return;
    setState(() {
      _dayValidationError = null;
      final removed = _dayGroups.removeAt(index);
      final orphanDays = removed.selectedDays.toList();
      removed.dispose();
      if (_dayGroups.isNotEmpty && orphanDays.isNotEmpty) {
        _dayGroups.first.selectedDays.addAll(orphanDays);
      }
    });
  }

  ({int totalCalories, int avgCalories, Set<DayOfWeek> missingDays})
  _computeCyclingSummary() {
    int totalCals = 0;
    final assigned = <DayOfWeek>{};
    for (final g in _dayGroups) {
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
    for (final group in _dayGroups) {
      group.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim().isEmpty
        ? 'Daily Target'
        : _nameController.text.trim();
    final phase = widget.existingGoal?.phase ?? WeightGoalPhase.maintain;
    final isActive = widget.existingGoal?.isActive ?? true;
    final cubit = context.read<MacroTrackingCubit>();

    if (_goalType == MacroGoalType.flat) {
      final calories = int.tryParse(_caloriesController.text) ?? 2000;
      final protein = int.tryParse(_proteinController.text) ?? 150;
      final carbs = int.tryParse(_carbsController.text) ?? 200;
      final fat = int.tryParse(_fatController.text) ?? 65;
      final water = int.tryParse(_waterController.text);
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

      if (widget.existingGoal != null) {
        cubit.updateMacroGoal(widget.existingGoal!.id, input);
      } else {
        cubit.createMacroGoal(input);
      }
      Navigator.of(context).pop();
      return;
    }

    // Calorie cycling validation
    for (int i = 0; i < _dayGroups.length; i++) {
      if (_dayGroups[i].selectedDays.isEmpty) {
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

    for (int i = 0; i < _dayGroups.length; i++) {
      final g = _dayGroups[i];
      final sortedDays = g.selectedDays.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final calories = int.tryParse(g.caloriesController.text) ?? 2000;
      final protein = int.tryParse(g.proteinController.text) ?? 150;
      final carbs = int.tryParse(g.carbsController.text) ?? 200;
      final fat = int.tryParse(g.fatController.text) ?? 65;
      final water = int.tryParse(g.waterController.text);

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

    if (widget.existingGoal != null) {
      cubit.updateMacroGoal(widget.existingGoal!.id, input);
    } else {
      cubit.createMacroGoal(input);
    }

    Navigator.of(context).pop();
  }

  Widget _buildFlatFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: widget.sizes.spacing),
        CheckboxListTile(
          key: const ValueKey('macro-goal-calculate-calories-checkbox'),
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
        for (int i = 0; i < _dayGroups.length; i++) ...[
          _buildDayGroupCard(i, _dayGroups[i]),
          SizedBox(height: widget.sizes.spacing),
        ],
        if (_dayGroups.length < 7)
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

  Widget _buildDayGroupCard(int index, _DayGroupFormState group) {
    return Card(
      key: ValueKey('macro-goal-day-group-$index'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: widget.sizes.spacing / 2,
              runSpacing: widget.sizes.spacing / 2,
              children: [
                Text(
                  'Day Group ${index + 1}',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_dayGroups.length > 1)
                  IconButton(
                    key: ValueKey('macro-goal-remove-group-$index'),
                    onPressed: () => _removeDayGroup(index),
                    icon: Icon(
                      Icons.delete_outline,
                      size: widget.sizes.buttonIconSize,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            Wrap(
              spacing: widget.sizes.spacing / 3,
              runSpacing: widget.sizes.spacing / 3,
              children: [
                for (final day in DayOfWeek.values)
                  FilterChip(
                    key: ValueKey('macro-goal-group-$index-day-${day.value}'),
                    label: Text(
                      _dayLabels[day]!,
                      style: TextStyle(fontSize: widget.sizes.smallFontSize),
                    ),
                    selected: group.selectedDays.contains(day),
                    onSelected: (selected) =>
                        _toggleDayForGroup(index, day, selected),
                  ),
              ],
            ),
            SizedBox(height: widget.sizes.spacing),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: false,
              key: ValueKey('macro-goal-group-$index-calories-input'),
              controller: group.caloriesController,
              readOnly: group.calculateCaloriesFromMacros,
              keyboardType: TextInputType.number,
              labelText: 'Daily Calories (kcal) *',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            CheckboxListTile(
              key: ValueKey(
                'macro-goal-group-$index-calculate-calories-checkbox',
              ),
              value: group.calculateCaloriesFromMacros,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Calculate calories from macros',
                style: TextStyle(fontSize: widget.sizes.fontSize),
              ),
              onChanged: (value) {
                setState(() {
                  group.setCalculateCalories(value ?? false);
                });
              },
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            ResponsiveFields(
              sizes: widget.sizes,
              children: [
                AppTextFormField(
                  theme: widget.theme,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-protein-input'),
                  controller: group.proteinController,
                  keyboardType: TextInputType.number,
                  labelText: 'Protein (g) *',
                  validator: _validateMacro,
                ),
                AppTextFormField(
                  theme: widget.theme,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-carbs-input'),
                  controller: group.carbsController,
                  keyboardType: TextInputType.number,
                  labelText: 'Carbs (g) *',
                  validator: _validateMacro,
                ),
              ],
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            ResponsiveFields(
              sizes: widget.sizes,
              children: [
                AppTextFormField(
                  theme: widget.theme,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-fat-input'),
                  controller: group.fatController,
                  keyboardType: TextInputType.number,
                  labelText: 'Fat (g) *',
                  validator: _validateMacro,
                ),
                AppTextFormField(
                  theme: widget.theme,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  isLoading: false,
                  key: ValueKey('macro-goal-group-$index-water-input'),
                  controller: group.waterController,
                  keyboardType: TextInputType.number,
                  labelText: 'Water (ml)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  Wrap(
                    key: const ValueKey('macro-goal-type-selector'),
                    spacing: widget.sizes.spacing / 2,
                    runSpacing: widget.sizes.spacing / 2,
                    children: [
                      ChoiceChip(
                        key: const ValueKey('macro-goal-type-flat'),
                        label: Text(
                          'Flat Week',
                          style: TextStyle(fontSize: widget.sizes.fontSize),
                        ),
                        selected: _goalType == MacroGoalType.flat,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _goalType = MacroGoalType.flat;
                              _dayValidationError = null;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        key: const ValueKey('macro-goal-type-cycling'),
                        label: Text(
                          'Calorie Cycling',
                          style: TextStyle(fontSize: widget.sizes.fontSize),
                        ),
                        selected: _goalType == MacroGoalType.calorieCycling,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _goalType = MacroGoalType.calorieCycling;
                              _dayValidationError = null;
                              if (_dayGroups.isEmpty) {
                                _createDefaultCyclingGroups();
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  if (_goalType == MacroGoalType.flat)
                    _buildFlatFormFields()
                  else
                    _buildCyclingFormFields(),
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
