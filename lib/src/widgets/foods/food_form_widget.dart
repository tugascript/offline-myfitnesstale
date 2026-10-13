import '../layout/responsive_fields.dart';
import '../layout/app_text_form_field.dart';
import '../../common/nullable.dart';
import '../../services/inputs/food_input.dart';
import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class FoodFormWidget extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final FoodDto? initialFood;
  final bool isLoading;
  final ValueChanged<FoodInput> onSubmit;

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
    _servingSizeController = TextEditingController(
        text: f?.servingSizeBaseGrams.toString() ?? '100');
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
        TextEditingController(text: f?.sodiumBase?.toString() ?? '');
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

    widget.onSubmit(FoodInput(
      name: _nameController.text.trim(),
      brand: Nullable(_brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim()),
      category: _selectedCategory,
      servingSizeBaseGrams: int.tryParse(_servingSizeController.text) ?? 100,
      caloriesBase: int.tryParse(_caloriesController.text) ?? 0,
      proteinBase: int.tryParse(_proteinController.text) ?? 0,
      carbsBase: int.tryParse(_carbsController.text) ?? 0,
      fatBase: int.tryParse(_fatController.text) ?? 0,
      fiberBase: Nullable(int.tryParse(_fiberController.text)),
      portions: portions,
      sodiumBase: Nullable(int.tryParse(_sodiumController.text)),
      barcode: Nullable(widget.initialFood?.barcode),
      micros: Nullable(widget.initialFood?.micros),
      isFavorite: widget.initialFood?.isFavorite ?? false,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              key: const ValueKey('food-form-name-input'),
              controller: _nameController,
              labelText: 'Food Name *',
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: widget.sizes.spacing),
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('food-form-brand-input'),
              controller: _brandController,
              labelText: 'Brand (optional)',
            ),
            SizedBox(height: widget.sizes.spacing),
            DropdownButtonFormField<FoodCategory>(
              isExpanded: true,
              itemHeight: null,
              iconSize: widget.sizes.buttonIconSize,
              style: TextStyle(
                  fontSize: widget.sizes.fontSize,
                  color: widget.theme.textTheme.bodyMedium?.color),
              key: const ValueKey('food-form-category-dropdown'),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: FoodCategory.values.map((cat) {
                return DropdownMenuItem<FoodCategory>(
                  value: cat,
                  child: Text(
                      cat.value[0].toUpperCase() + cat.value.substring(1),
                      style: TextStyle(fontSize: widget.sizes.fontSize)),
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
            AppTextFormField(
              theme: widget.theme,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              key: const ValueKey('food-form-serving-size-input'),
              controller: _servingSizeController,
              keyboardType: TextInputType.number,
              labelText: 'Serving Size (grams) *',
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
            ResponsiveFields(sizes: widget.sizes, children: [
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-calories-input'),
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                labelText: 'Calories (kcal) *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-protein-input'),
                controller: _proteinController,
                keyboardType: TextInputType.number,
                labelText: 'Protein (g) *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ]),
            SizedBox(height: widget.sizes.spacing),
            ResponsiveFields(sizes: widget.sizes, children: [
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-carbs-input'),
                controller: _carbsController,
                keyboardType: TextInputType.number,
                labelText: 'Carbs (g) *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-fat-input'),
                controller: _fatController,
                keyboardType: TextInputType.number,
                labelText: 'Fat (g) *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ]),
            SizedBox(height: widget.sizes.spacing),
            ResponsiveFields(sizes: widget.sizes, children: [
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-fiber-input'),
                controller: _fiberController,
                keyboardType: TextInputType.number,
                labelText: 'Fiber (g)',
              ),
              AppTextFormField(
                theme: widget.theme,
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                key: const ValueKey('food-form-sodium-input'),
                controller: _sodiumController,
                keyboardType: TextInputType.number,
                labelText: 'Sodium (mg)',
              ),
            ]),
            SizedBox(height: widget.sizes.spacing * 1.5),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: widget.sizes.spacing / 2,
              runSpacing: widget.sizes.spacing / 2,
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
                  icon: Icon(Icons.add, size: widget.sizes.buttonIconSize),
                  label: Text('Add Portion',
                      style: TextStyle(fontSize: widget.sizes.fontSize)),
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
                padding: EdgeInsets.only(bottom: widget.sizes.padding / 2),
                child: ResponsiveFields(sizes: widget.sizes, children: [
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: widget.isLoading,
                    controller: row.nameController,
                    labelText: 'Portion Name',
                    hintText: 'e.g. 1 slice, 1 cup',
                  ),
                  AppTextFormField(
                    theme: widget.theme,
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    isLoading: widget.isLoading,
                    controller: row.gramsController,
                    keyboardType: TextInputType.number,
                    labelText: 'Grams',
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.red, size: widget.sizes.buttonIconSize),
                    onPressed: () => _removePortion(idx),
                  ),
                ]),
              );
            }),
            SizedBox(height: widget.sizes.spacing * 2),
            ElevatedButton(
              key: const ValueKey('food-form-save-btn'),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Text(
                      widget.initialFood != null
                          ? 'Update Food'
                          : 'Create Food',
                      style: TextStyle(fontSize: widget.sizes.fontSize)),
            ),
          ],
        ),
      ),
    );
  }
}
