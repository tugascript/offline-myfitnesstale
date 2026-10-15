import '../layout/app_text_form_field.dart';
import '../../services/inputs/quick_food_log_input.dart';
import 'quick_add_food_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/food_cubit.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/recipe_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class LogFoodModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MealType initialMealType;
  final DateTime selectedDate;
  final TimeOfDay? initialTime;

  const LogFoodModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialMealType = MealType.snack,
    this.initialTime,
    required this.selectedDate,
  });

  @override
  State<LogFoodModal> createState() => _LogFoodModalState();
}

class _LogFoodModalState extends State<LogFoodModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _logDateTime;

  int? _selectedFoodId;
  int? _selectedPortionId;
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );

  int? _selectedRecipeId;
  final TextEditingController _servingsController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Hour actions prefill their time; the global action uses the current time.
    final now = DateTime.now();
    _logDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.initialTime?.hour ?? now.hour,
      widget.initialTime?.minute ?? now.minute,
    );

    // Ensure foods and recipes are loaded
    final foodState = context.read<FoodCubit>().state;
    if (foodState.foods.isEmpty) {
      context.read<FoodCubit>().getFoods(limit: 100);
    }
    final recipeState = context.read<RecipeCubit>().state;
    if (recipeState.recipes.isEmpty) {
      context.read<RecipeCubit>().getRecipes(limit: 100);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _logFood() async {
    if (_selectedFoodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a food',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
        ),
      );
      return;
    }

    final amt = int.tryParse(_amountController.text.trim()) ?? 100;

    final cubit = context.read<MacroTrackingCubit>();
    final success = await cubit.logFoodItem(
      mealType: widget.initialMealType,
      foodId: _selectedFoodId!,
      amount: amt,
      portionId: _selectedPortionId,
      logTime: _logDateTime,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _logRecipe() async {
    if (_selectedRecipeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a recipe',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
        ),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;

    final cubit = context.read<MacroTrackingCubit>();
    final success = await cubit.logRecipe(
      mealType: widget.initialMealType,
      recipeId: _selectedRecipeId!,
      servings: servings,
      logTime: _logDateTime,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _logQuickFood(QuickFoodLogInput input) async {
    final success = await context.read<MacroTrackingCubit>().logQuickFood(
      input,
      logTime: _logDateTime,
      mealType: widget.initialMealType,
    );
    if (success && mounted) Navigator.of(context).pop();
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final foods = context.watch<FoodCubit>().state.foods;
    final recipes = context.watch<RecipeCubit>().state.recipes;

    FoodDto? currentFood;
    if (_selectedFoodId != null) {
      final matches = foods.where((f) => f.id == _selectedFoodId);
      if (matches.isNotEmpty) currentFood = matches.first;
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.sizes.modalMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(widget.sizes.padding * 1.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: widget.sizes.spacing / 2,
                  runSpacing: widget.sizes.spacing / 2,
                  children: [
                    Text(
                      'Log Nutrition',
                      style: TextStyle(
                        fontSize: widget.sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: widget.sizes.buttonIconSize,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(_logDateTime),
                  style: TextStyle(fontSize: widget.sizes.fontSize),
                ),
                SizedBox(height: widget.sizes.spacing / 2),
                OutlinedButton.icon(
                  key: const ValueKey('log-food-time-btn'),
                  icon: Icon(
                    Icons.access_time,
                    size: widget.sizes.buttonIconSize,
                  ),
                  label: Text(
                    DateFormat('HH:mm').format(_logDateTime),
                    style: TextStyle(fontSize: widget.sizes.fontSize),
                  ),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_logDateTime),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _logDateTime = DateTime(
                          _logDateTime.year,
                          _logDateTime.month,
                          _logDateTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                SizedBox(height: widget.sizes.spacing),
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: widget.sizes.spacing / 4,
                  ),
                  labelStyle: TextStyle(
                    fontSize: widget.sizes.fontSize,
                    height: 1,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary,
                      width: widget.sizes.spacing / 4,
                    ),
                    borderRadius: BorderRadius.zero,
                    insets: EdgeInsets.zero,
                  ),
                  tabs: [
                    for (final label in ['Food', 'Recipe', 'Quick Add'])
                      Tab(
                        height:
                            MediaQuery.textScalerOf(context)
                                    .scale(widget.sizes.fontSize) *
                                3 +
                            widget.sizes.spacing,
                        child: Text(label, textAlign: TextAlign.center),
                      ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Visibility(
                        visible: _tabController.index == 2,
                        maintainState: true,
                        child: QuickAddFoodForm(
                          sizes: widget.sizes,
                          theme: widget.theme,
                          onSubmit: _logQuickFood,
                        ),
                      ),
                      if (_tabController.index != 2)
                        _tabController.index == 0
                            ? // Food Tab
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    itemHeight: null,
                                    iconSize: widget.sizes.buttonIconSize,
                                    style: TextStyle(
                                      fontSize: widget.sizes.fontSize,
                                      color: widget
                                          .theme
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    key: const ValueKey(
                                      'log-food-select-dropdown',
                                    ),
                                    initialValue: _selectedFoodId,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Food',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: foods.map((f) {
                                      return DropdownMenuItem<int>(
                                        value: f.id,
                                        child: Text(
                                          f.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: widget.sizes.fontSize,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedFoodId = val;
                                        _selectedPortionId = null;
                                      });
                                    },
                                  ),
                                  SizedBox(height: widget.sizes.spacing),
                                  if (currentFood != null &&
                                      currentFood.portions.isNotEmpty) ...[
                                    DropdownButtonFormField<int?>(
                                      isExpanded: true,
                                      itemHeight: null,
                                      iconSize: widget.sizes.buttonIconSize,
                                      style: TextStyle(
                                        fontSize: widget.sizes.fontSize,
                                        color: widget
                                            .theme
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                      initialValue: _selectedPortionId,
                                      decoration: const InputDecoration(
                                        labelText: 'Portion',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: [
                                        DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text(
                                            'Grams',
                                            style: TextStyle(
                                              fontSize: widget.sizes.fontSize,
                                            ),
                                          ),
                                        ),
                                        ...currentFood.portions.map((p) {
                                          return DropdownMenuItem<int?>(
                                            value: p.id,
                                            child: Text(
                                              '${p.portionName} (${p.gramWeight}g)',
                                              style: TextStyle(
                                                fontSize: widget.sizes.fontSize,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedPortionId = val;
                                        });
                                      },
                                    ),
                                    SizedBox(height: widget.sizes.spacing),
                                  ],
                                  AppTextFormField(
                                    theme: widget.theme,
                                    fontSize: widget.sizes.fontSize,
                                    padding: widget.sizes.padding,
                                    isLoading: false,
                                    key: const ValueKey(
                                      'log-food-amount-input',
                                    ),
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    labelText: _selectedPortionId == null
                                        ? 'Amount (grams)'
                                        : 'Portion Count',
                                  ),
                                  SizedBox(height: widget.sizes.spacing),
                                  ElevatedButton(
                                    key: const ValueKey('log-food-confirm-btn'),
                                    onPressed: _logFood,
                                    child: Text(
                                      'Log Food',
                                      style: TextStyle(
                                        fontSize: widget.sizes.fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : // Recipe Tab
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    itemHeight: null,
                                    iconSize: widget.sizes.buttonIconSize,
                                    style: TextStyle(
                                      fontSize: widget.sizes.fontSize,
                                      color: widget
                                          .theme
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    key: const ValueKey(
                                      'log-recipe-select-dropdown',
                                    ),
                                    initialValue: _selectedRecipeId,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Recipe',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: recipes.map((r) {
                                      return DropdownMenuItem<int>(
                                        value: r.id,
                                        child: Text(
                                          '${r.name} (${r.servingCalories} kcal/serv)',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: widget.sizes.fontSize,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedRecipeId = val;
                                      });
                                    },
                                  ),
                                  SizedBox(height: widget.sizes.spacing),
                                  AppTextFormField(
                                    theme: widget.theme,
                                    fontSize: widget.sizes.fontSize,
                                    padding: widget.sizes.padding,
                                    isLoading: false,
                                    key: const ValueKey(
                                      'log-recipe-servings-input',
                                    ),
                                    controller: _servingsController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    labelText: 'Number of Servings',
                                  ),
                                  SizedBox(height: widget.sizes.spacing),
                                  ElevatedButton(
                                    key: const ValueKey(
                                      'log-recipe-confirm-btn',
                                    ),
                                    onPressed: _logRecipe,
                                    child: Text(
                                      'Log Recipe',
                                      style: TextStyle(
                                        fontSize: widget.sizes.fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
