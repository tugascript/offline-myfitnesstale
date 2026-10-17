import '../layout/responsive_fields.dart';
import '../layout/app_text_form_field.dart';
import '../../common/nullable.dart';
import '../../services/inputs/meal_plan_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/food_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import '../../services/dtos/meal_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MealPlanFormWidget extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MealPlanDto? initialPlan;
  final bool isLoading;
  final ValueChanged<MealPlanInput> onSubmit;

  const MealPlanFormWidget({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialPlan,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<MealPlanFormWidget> createState() => _MealPlanFormWidgetState();
}

class _MealItemDraft {
  int? foodId;
  int? portionId;
  final TextEditingController amountController;

  _MealItemDraft({this.foodId, this.portionId, String amount = '100'})
    : amountController = TextEditingController(text: amount);

  void dispose() {
    amountController.dispose();
  }
}

class _MealDraft {
  MealType mealType;
  final TextEditingController nameController;
  final List<_MealItemDraft> items;

  _MealDraft({
    required this.mealType,
    String name = '',
    List<_MealItemDraft>? items,
  }) : nameController = TextEditingController(text: name),
       items = items ?? [];

  void dispose() {
    nameController.dispose();
    for (final it in items) {
      it.dispose();
    }
  }
}

class _DayDraft {
  int dayNumber;
  final TextEditingController nameController;
  final List<_MealDraft> meals;

  _DayDraft({
    required this.dayNumber,
    String name = '',
    List<_MealDraft>? meals,
  }) : nameController = TextEditingController(text: name),
       meals = meals ?? [];

  void dispose() {
    nameController.dispose();
    for (final m in meals) {
      m.dispose();
    }
  }
}

class _WeekDraft {
  int weekNumber;
  final TextEditingController nameController;
  final List<_DayDraft> days;

  _WeekDraft({
    required this.weekNumber,
    String name = '',
    List<_DayDraft>? days,
  }) : nameController = TextEditingController(text: name),
       days = days ?? [];

  void dispose() {
    nameController.dispose();
    for (final d in days) {
      d.dispose();
    }
  }
}

class _MealPlanFormWidgetState extends State<MealPlanFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationWeeksController;

  final List<_WeekDraft> _weeks = [];

  @override
  void initState() {
    super.initState();
    final p = widget.initialPlan;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _durationWeeksController = TextEditingController(
      text: p?.totalWeeks.toString() ?? '1',
    );

    if (p != null && p.weeks.isNotEmpty) {
      for (final w in p.weeks) {
        final dayDrafts = <_DayDraft>[];
        for (final d in w.days) {
          final mealDrafts = <_MealDraft>[];
          for (final m in d.meals) {
            final itemDrafts = <_MealItemDraft>[];
            for (final it in m.items) {
              itemDrafts.add(
                _MealItemDraft(
                  foodId: it.foodId,
                  portionId: it.portionId,
                  amount: it.amount.toString(),
                ),
              );
            }
            mealDrafts.add(
              _MealDraft(mealType: m.mealType, name: m.name, items: itemDrafts),
            );
          }
          dayDrafts.add(
            _DayDraft(
              dayNumber: d.day,
              name: d.name ?? 'Day ${d.day}',
              meals: mealDrafts,
            ),
          );
        }
        _weeks.add(
          _WeekDraft(
            weekNumber: w.weekNumber,
            name: 'Week ${w.weekNumber}',
            days: dayDrafts,
          ),
        );
      }
    } else {
      // Create initial 1 week with 1 day with Breakfast
      _weeks.add(
        _WeekDraft(
          weekNumber: 1,
          name: 'Week 1',
          days: [
            _DayDraft(
              dayNumber: 1,
              name: 'Day 1',
              meals: [
                _MealDraft(mealType: MealType.breakfast, name: 'Breakfast'),
              ],
            ),
          ],
        ),
      );
    }

    // Ensure foods are loaded for selection
    final foodState = context.read<FoodCubit>().state;
    if (foodState.foods.isEmpty) {
      context.read<FoodCubit>().getFoods(limit: 100);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationWeeksController.dispose();
    for (final w in _weeks) {
      w.dispose();
    }
    super.dispose();
  }

  void _addWeek() {
    setState(() {
      final nextNum = _weeks.length + 1;
      _weeks.add(
        _WeekDraft(
          weekNumber: nextNum,
          name: 'Week $nextNum',
          days: [
            _DayDraft(
              dayNumber: 1,
              name: 'Day 1',
              meals: [
                _MealDraft(mealType: MealType.breakfast, name: 'Breakfast'),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _addDay(_WeekDraft week) {
    setState(() {
      final nextDay = week.days.length + 1;
      week.days.add(
        _DayDraft(
          dayNumber: nextDay,
          name: 'Day $nextDay',
          meals: [_MealDraft(mealType: MealType.breakfast, name: 'Breakfast')],
        ),
      );
    });
  }

  void _addMeal(_DayDraft day) {
    setState(() {
      day.meals.add(
        _MealDraft(
          mealType: MealType.lunch,
          name: 'Meal ${day.meals.length + 1}',
        ),
      );
    });
  }

  void _addItem(_MealDraft meal) {
    final foods = context.read<FoodCubit>().state.foods;
    setState(() {
      meal.items.add(
        _MealItemDraft(
          foodId: foods.isNotEmpty ? foods.first.id : null,
          amount: '100',
        ),
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_weeks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meal plan must contain at least one week',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
        ),
      );
      return;
    }

    final weekInputs = <MealPlanWeekInput>[];
    for (final w in _weeks) {
      final dayInputs = <MealPlanDayInput>[];
      for (final d in w.days) {
        final mealInputs = <MealPlanMealInput>[];
        for (final m in d.meals) {
          final itemInputs = <MealPlanMealItemInput>[];
          for (final it in m.items) {
            if (it.foodId != null) {
              final amt = int.tryParse(it.amountController.text.trim()) ?? 100;
              itemInputs.add(
                MealPlanMealItemInput(
                  foodId: it.foodId!,
                  portionId: it.portionId,
                  amount: amt,
                ),
              );
            }
          }
          mealInputs.add(
            MealPlanMealInput(
              position: mealInputs.length + 1,
              mealType: m.mealType,
              name: m.nameController.text.trim().isEmpty
                  ? m.mealType.value
                  : m.nameController.text.trim(),
              items: itemInputs,
            ),
          );
        }
        dayInputs.add(
          MealPlanDayInput(
            day: d.dayNumber,
            name: d.nameController.text.trim().isEmpty
                ? 'Day ${d.dayNumber}'
                : d.nameController.text.trim(),
            meals: mealInputs,
          ),
        );
      }
      weekInputs.add(
        MealPlanWeekInput(
          weekNumber: w.weekNumber,
          phase: MealPlanPhase.maintain,
          days: dayInputs,
        ),
      );
    }

    widget.onSubmit(
      MealPlanInput(
        name: _nameController.text.trim(),
        description: Nullable(
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
        weeks: weekInputs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = context.watch<FoodCubit>().state.foods;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('meal-plan-form-name-input'),
              controller: _nameController,
              labelText: 'Meal Plan Name *',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: widget.sizes.spacing),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('meal-plan-form-desc-input'),
              controller: _descriptionController,
              maxLines: 2,
              labelText: 'Description (optional)',
            ),
            SizedBox(height: widget.sizes.spacing),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('meal-plan-form-duration-input'),
              controller: _durationWeeksController,
              keyboardType: TextInputType.number,
              labelText: 'Duration in Weeks *',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Min 1';
                return null;
              },
            ),
            SizedBox(height: widget.sizes.spacing * 1.5),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: widget.sizes.spacing / 2,
              runSpacing: widget.sizes.spacing / 2,
              children: [
                Text(
                  'Plan Schedule',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('meal-plan-form-add-week-btn'),
                  icon: Icon(Icons.add, size: widget.sizes.buttonIconSize),
                  label: Text(
                    'Add Week',
                    style: TextStyle(fontSize: widget.sizes.fontSize),
                  ),
                  onPressed: _addWeek,
                ),
              ],
            ),
            ..._weeks.asMap().entries.map((wEntry) {
              final wIdx = wEntry.key;
              final week = wEntry.value;

              return Card(
                margin: EdgeInsets.only(bottom: widget.sizes.padding),
                child: Padding(
                  padding: EdgeInsets.all(widget.sizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ResponsiveFields(
                        sizes: widget.sizes,
                        children: [
                          AppTextFormField(
                            theme: widget.theme,
                            fontSize: widget.sizes.fontSize,
                            padding: widget.sizes.padding,
                            isLoading: widget.isLoading,
                            controller: week.nameController,
                            labelText: 'Week ${week.weekNumber} Name',
                          ),
                          if (_weeks.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: widget.sizes.buttonIconSize,
                              ),
                              onPressed: () {
                                setState(() {
                                  final rem = _weeks.removeAt(wIdx);
                                  rem.dispose();
                                });
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: widget.sizes.spacing),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: widget.sizes.spacing / 2,
                        runSpacing: widget.sizes.spacing / 2,
                        children: [
                          Text(
                            'Days (${week.days.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: widget.sizes.fontSize,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: widget.sizes.compactIconSize,
                            ),
                            label: Text(
                              'Add Day',
                              style: TextStyle(fontSize: widget.sizes.fontSize),
                            ),
                            onPressed: () => _addDay(week),
                          ),
                        ],
                      ),
                      ...week.days.asMap().entries.map((dEntry) {
                        final dIdx = dEntry.key;
                        final day = dEntry.value;

                        return Container(
                          margin: EdgeInsets.only(
                            bottom: widget.sizes.padding / 2,
                          ),
                          padding: EdgeInsets.all(widget.sizes.padding / 2),
                          decoration: BoxDecoration(
                            color: widget.theme.cardColor.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ResponsiveFields(
                                sizes: widget.sizes,
                                children: [
                                  AppTextFormField(
                                    theme: widget.theme,
                                    fontSize: widget.sizes.fontSize,
                                    padding: widget.sizes.padding,
                                    isLoading: widget.isLoading,
                                    controller: day.nameController,
                                    labelText: 'Day ${day.dayNumber} Name',
                                  ),
                                  if (week.days.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: widget.sizes.compactIconSize,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          final rem = week.days.removeAt(dIdx);
                                          rem.dispose();
                                        });
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: widget.sizes.spacing),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: widget.sizes.spacing / 2,
                                runSpacing: widget.sizes.spacing / 2,
                                children: [
                                  Text(
                                    'Meals (${day.meals.length})',
                                    style: TextStyle(
                                      fontSize: widget.sizes.fontSize * 0.9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: Icon(
                                      Icons.add,
                                      size: widget.sizes.compactIconSize,
                                    ),
                                    label: Text(
                                      'Add Meal',
                                      style: TextStyle(
                                        fontSize: widget.sizes.fontSize,
                                      ),
                                    ),
                                    onPressed: () => _addMeal(day),
                                  ),
                                ],
                              ),
                              ...day.meals.asMap().entries.map((mEntry) {
                                final mIdx = mEntry.key;
                                final meal = mEntry.value;

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: widget.sizes.padding / 2,
                                  ),
                                  padding: EdgeInsets.all(
                                    widget.sizes.padding / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ResponsiveFields(
                                        sizes: widget.sizes,
                                        children: [
                                          DropdownButtonFormField<MealType>(
                                            isExpanded: true,
                                            itemHeight: null,
                                            iconSize:
                                                widget.sizes.buttonIconSize,
                                            style: TextStyle(
                                              fontSize: widget.sizes.fontSize,
                                              color: widget
                                                  .theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                            ),
                                            initialValue: meal.mealType,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              labelText: 'Type',
                                            ),
                                            items: MealType.values.map((t) {
                                              return DropdownMenuItem<MealType>(
                                                value: t,
                                                child: Text(
                                                  t.value,
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.sizes.fontSize,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  meal.mealType = val;
                                                });
                                              }
                                            },
                                          ),
                                          AppTextFormField(
                                            theme: widget.theme,
                                            fontSize: widget.sizes.fontSize,
                                            padding: widget.sizes.padding,
                                            isLoading: widget.isLoading,
                                            controller: meal.nameController,
                                            labelText: 'Meal Name',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              size:
                                                  widget.sizes.compactIconSize,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                final rem = day.meals.removeAt(
                                                  mIdx,
                                                );
                                                rem.dispose();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: widget.sizes.spacing / 2,
                                      ),
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: widget.sizes.spacing / 2,
                                        runSpacing: widget.sizes.spacing / 2,
                                        children: [
                                          Text(
                                            'Items (${meal.items.length})',
                                            style: TextStyle(
                                              fontSize:
                                                  widget.sizes.fontSize * 0.8,
                                            ),
                                          ),
                                          TextButton.icon(
                                            icon: Icon(
                                              Icons.add,
                                              size:
                                                  widget.sizes.compactIconSize,
                                            ),
                                            label: Text(
                                              'Add Food',
                                              style: TextStyle(
                                                fontSize: widget.sizes.fontSize,
                                              ),
                                            ),
                                            onPressed: () => _addItem(meal),
                                          ),
                                        ],
                                      ),
                                      ...meal.items.asMap().entries.map((
                                        itEntry,
                                      ) {
                                        final itIdx = itEntry.key;
                                        final item = itEntry.value;

                                        FoodDto? currentFood;
                                        if (item.foodId != null) {
                                          final match = foods.where(
                                            (f) => f.id == item.foodId,
                                          );
                                          if (match.isNotEmpty) {
                                            currentFood = match.first;
                                          }
                                        }

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: widget.sizes.padding / 2,
                                          ),
                                          child: ResponsiveFields(
                                            sizes: widget.sizes,
                                            children: [
                                              DropdownButtonFormField<int>(
                                                isExpanded: true,
                                                itemHeight: null,
                                                iconSize:
                                                    widget.sizes.buttonIconSize,
                                                style: TextStyle(
                                                  fontSize:
                                                      widget.sizes.fontSize,
                                                  color: widget
                                                      .theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                                initialValue: item.foodId,
                                                decoration:
                                                    const InputDecoration(
                                                      isDense: true,
                                                    ),
                                                items: foods.map((f) {
                                                  return DropdownMenuItem<int>(
                                                    value: f.id,
                                                    child: Text(
                                                      f.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: widget
                                                            .sizes
                                                            .fontSize,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (val) {
                                                  setState(() {
                                                    item.foodId = val;
                                                    item.portionId = null;
                                                  });
                                                },
                                              ),
                                              if (currentFood != null &&
                                                  currentFood
                                                      .portions
                                                      .isNotEmpty) ...[
                                                DropdownButtonFormField<int?>(
                                                  isExpanded: true,
                                                  itemHeight: null,
                                                  iconSize: widget
                                                      .sizes
                                                      .buttonIconSize,
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.sizes.fontSize,
                                                    color: widget
                                                        .theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                  initialValue: item.portionId,
                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                      ),
                                                  items: [
                                                    DropdownMenuItem<int?>(
                                                      value: null,
                                                      child: Text(
                                                        'Grams',
                                                        style: TextStyle(
                                                          fontSize: widget
                                                              .sizes
                                                              .fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                    ...currentFood.portions.map(
                                                      (p) {
                                                        return DropdownMenuItem<
                                                          int?
                                                        >(
                                                          value: p.id,
                                                          child: Text(
                                                            p.portionName,
                                                            style: TextStyle(
                                                              fontSize: widget
                                                                  .sizes
                                                                  .fontSize,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                  onChanged: (val) {
                                                    setState(() {
                                                      item.portionId = val;
                                                    });
                                                  },
                                                ),
                                                SizedBox(
                                                  width:
                                                      widget.sizes.spacing / 2,
                                                ),
                                              ],
                                              AppTextFormField(
                                                theme: widget.theme,
                                                fontSize: widget.sizes.fontSize,
                                                padding: widget.sizes.padding,
                                                isLoading: widget.isLoading,
                                                controller:
                                                    item.amountController,
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                labelText: 'Amt',
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  size: widget
                                                      .sizes
                                                      .compactIconSize,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    final rem = meal.items
                                                        .removeAt(itIdx);
                                                    rem.dispose();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: widget.sizes.spacing * 2),
            ElevatedButton(
              key: const ValueKey('meal-plan-form-save-btn'),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Text(
                      widget.initialPlan != null
                          ? 'Update Meal Plan'
                          : 'Create Meal Plan',
                      style: TextStyle(fontSize: widget.sizes.fontSize),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
