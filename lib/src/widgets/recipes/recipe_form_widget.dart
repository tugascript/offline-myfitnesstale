import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/food_cubit.dart';
import '../../services/dtos/food_dto.dart';
import '../../services/dtos/recipe_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class RecipeFormWidget extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final RecipeDto? initialRecipe;
  final bool isLoading;
  final void Function({
    required String name,
    String? description,
    required int servingsYield,
    required List<RecipeItemInput> items,
  }) onSubmit;

  const RecipeFormWidget({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialRecipe,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<RecipeFormWidget> createState() => _RecipeFormWidgetState();
}

class _RecipeItemRow {
  int? foodId;
  int? portionId;
  final TextEditingController amountController;

  _RecipeItemRow({
    this.foodId,
    this.portionId,
    String amount = '100',
  }) : amountController = TextEditingController(text: amount);

  void dispose() {
    amountController.dispose();
  }
}

class _RecipeFormWidgetState extends State<RecipeFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsYieldController;

  final List<_RecipeItemRow> _itemRows = [];

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecipe;
    _nameController = TextEditingController(text: r?.name ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _servingsYieldController =
        TextEditingController(text: r?.servingsYield.toString() ?? '1');

    if (r != null && r.items.isNotEmpty) {
      for (final item in r.items) {
        _itemRows.add(_RecipeItemRow(
          foodId: item.foodId,
          portionId: item.portionId,
          amount: item.amount.toString(),
        ));
      }
    }

    // Ensure foods are loaded for ingredient selection
    final foodState = context.read<FoodCubit>().state;
    if (foodState.foods.isEmpty) {
      context.read<FoodCubit>().getFoods(limit: 100);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsYieldController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    final foods = context.read<FoodCubit>().state.foods;
    setState(() {
      _itemRows.add(_RecipeItemRow(
        foodId: foods.isNotEmpty ? foods.first.id : null,
        amount: '100',
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      final removed = _itemRows.removeAt(index);
      removed.dispose();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_itemRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final items = <RecipeItemInput>[];
    for (final row in _itemRows) {
      if (row.foodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('All ingredients must have a selected food')),
        );
        return;
      }
      final amt = int.tryParse(row.amountController.text.trim()) ?? 100;
      items.add(RecipeItemInput(
        foodId: row.foodId!,
        portionId: row.portionId,
        amount: amt,
      ));
    }

    widget.onSubmit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      servingsYield: int.tryParse(_servingsYieldController.text) ?? 1,
      items: items,
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
            TextFormField(
              key: const ValueKey('recipe-form-name-input'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: widget.sizes.spacing),
            TextFormField(
              key: const ValueKey('recipe-form-desc-input'),
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: widget.sizes.spacing),
            TextFormField(
              key: const ValueKey('recipe-form-servings-input'),
              controller: _servingsYieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Servings Yield *',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Min 1';
                return null;
              },
            ),
            SizedBox(height: widget.sizes.spacing * 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('recipe-form-add-item-btn'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                  onPressed: _addItem,
                ),
              ],
            ),
            if (_itemRows.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: widget.sizes.padding),
                child: Text(
                  'No ingredients added. Tap "Add Ingredient" to include foods in this recipe.',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize * 0.9,
                    color: Colors.grey,
                  ),
                ),
              ),
            ..._itemRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;

              FoodDto? currentFood;
              if (row.foodId != null) {
                final match = foods.where((f) => f.id == row.foodId);
                if (match.isNotEmpty) currentFood = match.first;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: row.foodId,
                              decoration: const InputDecoration(
                                labelText: 'Food',
                                isDense: true,
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
                                  row.foodId = val;
                                  row.portionId = null;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => _removeItem(idx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (currentFood != null &&
                              currentFood.portions.isNotEmpty) ...[
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<int?>(
                                initialValue: row.portionId,
                                decoration: const InputDecoration(
                                  labelText: 'Portion',
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Grams'),
                                  ),
                                  ...currentFood.portions.map((p) {
                                    return DropdownMenuItem<int?>(
                                      value: p.id,
                                      child: Text(p.portionName),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    row.portionId = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: row.amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: row.portionId == null
                                    ? 'Amount (g)'
                                    : 'Portion Count',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: widget.sizes.spacing * 2),
            ElevatedButton(
              key: const ValueKey('recipe-form-save-btn'),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Text(widget.initialRecipe != null
                      ? 'Update Recipe'
                      : 'Create Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
