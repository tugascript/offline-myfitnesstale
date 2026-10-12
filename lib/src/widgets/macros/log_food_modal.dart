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

  const LogFoodModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialMealType = MealType.breakfast,
    required this.selectedDate,
  });

  @override
  State<LogFoodModal> createState() => _LogFoodModalState();
}

class _LogFoodModalState extends State<LogFoodModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MealType _mealType;
  late DateTime _logDateTime;

  int? _selectedFoodId;
  int? _selectedPortionId;
  final TextEditingController _amountController =
      TextEditingController(text: '100');

  int? _selectedRecipeId;
  final TextEditingController _servingsController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mealType = widget.initialMealType;

    // Combine selected date with current time
    final now = DateTime.now();
    _logDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      now.hour,
      now.minute,
      now.second,
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
        const SnackBar(content: Text('Please select a food')),
      );
      return;
    }

    final amt = int.tryParse(_amountController.text.trim()) ?? 100;

    final cubit = context.read<MacroTrackingCubit>();
    final success = await cubit.logFoodItem(
      mealType: _mealType,
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
        const SnackBar(content: Text('Please select a recipe')),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;

    final cubit = context.read<MacroTrackingCubit>();
    final success = await cubit.logRecipe(
      mealType: _mealType,
      recipeId: _selectedRecipeId!,
      servings: servings,
      logTime: _logDateTime,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.all(widget.sizes.padding * 1.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log Nutrition',
                      style: TextStyle(
                        fontSize: widget.sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MealType>(
                        key: const ValueKey('log-food-meal-type-dropdown'),
                        initialValue: _mealType,
                        decoration: const InputDecoration(
                          labelText: 'Meal',
                          border: OutlineInputBorder(),
                        ),
                        items: MealType.values.map((t) {
                          return DropdownMenuItem<MealType>(
                            value: t,
                            child: Text(t.value[0].toUpperCase() +
                                t.value.substring(1)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _mealType = val);
                        },
                      ),
                    ),
                    SizedBox(width: widget.sizes.spacing),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(DateFormat('HH:mm').format(_logDateTime)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_logDateTime),
                          );
                          if (time != null) {
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
                    ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Food'),
                    Tab(text: 'Recipe'),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Food Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<int>(
                            key: const ValueKey('log-food-select-dropdown'),
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
                              initialValue: _selectedPortionId,
                              decoration: const InputDecoration(
                                labelText: 'Portion',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Grams'),
                                ),
                                ...currentFood.portions.map((p) {
                                  return DropdownMenuItem<int?>(
                                    value: p.id,
                                    child: Text(
                                        '${p.portionName} (${p.gramWeight}g)'),
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
                          TextFormField(
                            key: const ValueKey('log-food-amount-input'),
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: _selectedPortionId == null
                                  ? 'Amount (grams)'
                                  : 'Portion Count',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            key: const ValueKey('log-food-confirm-btn'),
                            onPressed: _logFood,
                            child: const Text('Log Food'),
                          ),
                        ],
                      ),
                      // Recipe Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<int>(
                            key: const ValueKey('log-recipe-select-dropdown'),
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
                          TextFormField(
                            key: const ValueKey('log-recipe-servings-input'),
                            controller: _servingsController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Number of Servings',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            key: const ValueKey('log-recipe-confirm-btn'),
                            onPressed: _logRecipe,
                            child: const Text('Log Recipe'),
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
