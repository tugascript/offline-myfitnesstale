import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class FoodFormWidget extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final FoodDto? initialFood;
  final bool isLoading;
  final void Function({
    required String name,
    String? brand,
    String? barcode,
    required FoodCategory category,
    required int servingSizeBase,
    required int caloriesBase,
    required int proteinBase,
    required int carbsBase,
    required int fatBase,
    int? fiberBase,
    int? sodiumMg,
    required List<FoodPortionInput> portions,
  }) onSubmit;

  const FoodFormWidget({
    super.key,
    required this.theme,
    required this.sizes,
    this.initialFood,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<FoodFormWidget> createState() => _FoodFormWidgetState();
}

class _FoodPortionRow {
  final TextEditingController nameController;
  final TextEditingController gramsController;

  _FoodPortionRow({
    String name = '',
    String grams = '',
  })  : nameController = TextEditingController(text: name),
        gramsController = TextEditingController(text: grams);

  void dispose() {
    nameController.dispose();
    gramsController.dispose();
  }
}

class _FoodFormWidgetState extends State<FoodFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _servingSizeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sodiumController;

  late FoodCategory _selectedCategory;
  final List<_FoodPortionRow> _portionRows = [];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFood;
    _nameController = TextEditingController(text: f?.name ?? '');
    _brandController = TextEditingController(text: f?.brand ?? '');
    _servingSizeController =
        TextEditingController(text: f?.servingSizeBase.toString() ?? '100');
    _caloriesController =
        TextEditingController(text: f?.caloriesBase.toString() ?? '0');
    _proteinController =
        TextEditingController(text: f?.proteinBase.toString() ?? '0');
    _carbsController =
        TextEditingController(text: f?.carbsBase.toString() ?? '0');
    _fatController = TextEditingController(text: f?.fatBase.toString() ?? '0');
    _fiberController =
        TextEditingController(text: f?.fiberBase?.toString() ?? '');
    _sodiumController =
        TextEditingController(text: f?.micros?.sodiumMg?.toString() ?? '');
    _selectedCategory = f?.category ?? FoodCategory.other;

    if (f != null && f.portions.isNotEmpty) {
      for (final p in f.portions) {
        _portionRows.add(_FoodPortionRow(
          name: p.portionName,
          grams: p.gramWeight.toString(),
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sodiumController.dispose();
    for (final row in _portionRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addPortion() {
    setState(() {
      _portionRows.add(_FoodPortionRow(
        name: 'Serving',
        grams: _servingSizeController.text.isNotEmpty
            ? _servingSizeController.text
            : '100',
      ));
    });
  }

  void _removePortion(int index) {
    setState(() {
      final removed = _portionRows.removeAt(index);
      removed.dispose();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final portions = <FoodPortionInput>[];
    for (final row in _portionRows) {
      final name = row.nameController.text.trim();
      final grams = int.tryParse(row.gramsController.text.trim());
      if (name.isNotEmpty && grams != null && grams > 0) {
        portions.add(FoodPortionInput(
          portionName: name,
          gramWeight: grams,
        ));
      }
    }

    widget.onSubmit(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      category: _selectedCategory,
      servingSizeBase: int.tryParse(_servingSizeController.text) ?? 100,
      caloriesBase: int.tryParse(_caloriesController.text) ?? 0,
      proteinBase: int.tryParse(_proteinController.text) ?? 0,
      carbsBase: int.tryParse(_carbsController.text) ?? 0,
      fatBase: int.tryParse(_fatController.text) ?? 0,
      fiberBase: int.tryParse(_fiberController.text),
      sodiumMg: int.tryParse(_sodiumController.text),
      portions: portions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('food-form-name-input'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name *',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: widget.sizes.spacing),
            TextFormField(
              key: const ValueKey('food-form-brand-input'),
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: widget.sizes.spacing),
            DropdownButtonFormField<FoodCategory>(
              key: const ValueKey('food-form-category-dropdown'),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: FoodCategory.values.map((cat) {
                return DropdownMenuItem<FoodCategory>(
                  value: cat,
                  child:
                      Text(cat.value[0].toUpperCase() + cat.value.substring(1)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),
            SizedBox(height: widget.sizes.spacing),
            TextFormField(
              key: const ValueKey('food-form-serving-size-input'),
              controller: _servingSizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Serving Size (grams) *',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                final n = int.tryParse(val);
                if (n == null || n <= 0) return 'Must be positive';
                return null;
              },
            ),
            SizedBox(height: widget.sizes.spacing),
            Text(
              'Nutrition per Serving',
              style: TextStyle(
                fontSize: widget.sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-calories-input'),
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: widget.sizes.spacing),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-protein-input'),
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
              ],
            ),
            SizedBox(height: widget.sizes.spacing),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-carbs-input'),
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
                SizedBox(width: widget.sizes.spacing),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-fat-input'),
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
              ],
            ),
            SizedBox(height: widget.sizes.spacing),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-fiber-input'),
                    controller: _fiberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fiber (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: widget.sizes.spacing),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('food-form-sodium-input'),
                    controller: _sodiumController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sodium (mg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.sizes.spacing * 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Portions',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('food-form-add-portion-btn'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Portion'),
                  onPressed: _addPortion,
                ),
              ],
            ),
            if (_portionRows.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: widget.sizes.padding),
                child: Text(
                  'No additional portions defined. Default serving size will be used.',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize * 0.9,
                    color: Colors.grey,
                  ),
                ),
              ),
            ..._portionRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: row.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Portion Name',
                          hintText: 'e.g. 1 slice, 1 cup',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: row.gramsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Grams',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () => _removePortion(idx),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: widget.sizes.spacing * 2),
            ElevatedButton(
              key: const ValueKey('food-form-save-btn'),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Text(widget.initialFood != null
                      ? 'Update Food'
                      : 'Create Food'),
            ),
          ],
        ),
      ),
    );
  }
}
