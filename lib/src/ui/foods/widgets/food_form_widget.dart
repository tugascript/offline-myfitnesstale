// Copyright (C) 2026 Afonso Barracha
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

import '../../../data/repositories/foods/dtos/food_dto.dart';
import '../../../data/repositories/foods/inputs/food_input.dart';
import '../../../data/utils/display_names.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/nullable.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/layout/app_dropdown.dart';
import '../../core/widgets/layout/app_elevated_button.dart';
import '../../core/widgets/layout/app_text_form_field.dart';
import '../../core/widgets/layout/responsive_fields.dart';

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

  _FoodPortionRow({String name = '', String grams = ''})
    : nameController = TextEditingController(text: name),
      gramsController = TextEditingController(text: grams);

  void dispose() {
    nameController.dispose();
    gramsController.dispose();
  }
}

class _FoodFormWidgetState extends State<FoodFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sodiumController = TextEditingController();

  late final _FormData _data;
  final List<_FoodPortionRow> _portionRows = [];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFood;
    _data = _FormData(
      name: f?.name ?? '',
      brand: f?.brand ?? '',
      category: f?.category ?? FoodCategory.other,
      servingSizeBaseGrams: f?.servingSizeBaseGrams.toString() ?? '100',
      caloriesBase: f?.caloriesBase.toString() ?? '0',
      proteinBase: f?.proteinBase.toString() ?? '0',
      carbsBase: f?.carbsBase.toString() ?? '0',
      fatBase: f?.fatBase.toString() ?? '0',
      fiberBase: f?.fiberBase?.toString() ?? '',
      sodiumBase: f?.sodiumBase?.toString() ?? '',
      isFavorite: f?.isFavorite ?? false,
    );
    _nameController.text = _data.name;
    _brandController.text = _data.brand;
    _servingSizeController.text = _data.servingSizeBaseGrams;
    _caloriesController.text = _data.caloriesBase;
    _proteinController.text = _data.proteinBase;
    _carbsController.text = _data.carbsBase;
    _fatController.text = _data.fatBase;
    _fiberController.text = _data.fiberBase;
    _sodiumController.text = _data.sodiumBase;

    if (f != null && f.portions.isNotEmpty) {
      for (final p in f.portions) {
        _portionRows.add(
          _FoodPortionRow(name: p.portionName, grams: p.gramWeight.toString()),
        );
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
      _portionRows.add(
        _FoodPortionRow(
          name: 'Serving',
          grams: _data.servingSizeBaseGrams.isNotEmpty
              ? _data.servingSizeBaseGrams
              : '100',
        ),
      );
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
        portions.add(FoodPortionInput(portionName: name, gramWeight: grams));
      }
    }

    widget.onSubmit(
      FoodInput(
        name: _data.name.trim(),
        brand: Nullable(_data.brand.trim().isEmpty ? null : _data.brand.trim()),
        category: _data.category,
        servingSizeBaseGrams: int.tryParse(_data.servingSizeBaseGrams) ?? 100,
        caloriesBase: int.tryParse(_data.caloriesBase) ?? 0,
        proteinBase: int.tryParse(_data.proteinBase) ?? 0,
        carbsBase: int.tryParse(_data.carbsBase) ?? 0,
        fatBase: int.tryParse(_data.fatBase) ?? 0,
        fiberBase: Nullable(int.tryParse(_data.fiberBase)),
        portions: portions,
        sodiumBase: Nullable(int.tryParse(_data.sodiumBase)),
        barcode: Nullable(widget.initialFood?.barcode),
        micros: Nullable(widget.initialFood?.micros),
        isFavorite: _data.isFavorite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.sizes.subtitleFontSize;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextFormField(
            key: const ValueKey('food-form-name-input'),
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            fontSize: fontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _nameController,
            labelText: 'Name',
            hintText: 'Enter food name',
            onChanged: (value) {
              setState(() {
                _data.name = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.name = value;
                });
              }
            },
            validator: (val) => val == null || val.trim().isEmpty
                ? 'Please enter a name'
                : null,
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            key: const ValueKey('food-form-brand-input'),
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            fontSize: fontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _brandController,
            labelText: 'Brand',
            hintText: 'Enter brand (optional)',
            onChanged: (value) {
              setState(() {
                _data.brand = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.brand = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<FoodCategory>(
            key: const ValueKey('food-form-category-dropdown'),
            value: _data.category,
            filled: true,
            emptyLabel: 'Category',
            showEmptyValue: false,
            items: FoodCategory.values,
            fontSize: fontSize,
            padding: widget.sizes.padding,
            labelBuilder: EnumDisplayNames.getFoodCategoryDisplayName,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _data.category = value;
                });
              }
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.category = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            key: const ValueKey('food-form-serving-size-input'),
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            fontSize: fontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            controller: _servingSizeController,
            keyboardType: TextInputType.number,
            labelText: 'Serving Size (grams)',
            hintText: 'Enter serving size',
            onChanged: (value) {
              setState(() {
                _data.servingSizeBaseGrams = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.servingSizeBaseGrams = value;
                });
              }
            },
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
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: widget.sizes.spacing),
          ResponsiveFields(
            sizes: widget.sizes,
            children: [
              AppTextFormField(
                key: const ValueKey('food-form-calories-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                labelText: 'Calories (kcal)',
                onChanged: (value) {
                  setState(() {
                    _data.caloriesBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.caloriesBase = value;
                    });
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              AppTextFormField(
                key: const ValueKey('food-form-protein-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _proteinController,
                keyboardType: TextInputType.number,
                labelText: 'Protein (g)',
                onChanged: (value) {
                  setState(() {
                    _data.proteinBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.proteinBase = value;
                    });
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          ResponsiveFields(
            sizes: widget.sizes,
            children: [
              AppTextFormField(
                key: const ValueKey('food-form-carbs-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _carbsController,
                keyboardType: TextInputType.number,
                labelText: 'Carbs (g)',
                onChanged: (value) {
                  setState(() {
                    _data.carbsBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.carbsBase = value;
                    });
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              AppTextFormField(
                key: const ValueKey('food-form-fat-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _fatController,
                keyboardType: TextInputType.number,
                labelText: 'Fat (g)',
                onChanged: (value) {
                  setState(() {
                    _data.fatBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.fatBase = value;
                    });
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          ResponsiveFields(
            sizes: widget.sizes,
            children: [
              AppTextFormField(
                key: const ValueKey('food-form-fiber-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _fiberController,
                keyboardType: TextInputType.number,
                labelText: 'Fiber (g)',
                onChanged: (value) {
                  setState(() {
                    _data.fiberBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.fiberBase = value;
                    });
                  }
                },
              ),
              AppTextFormField(
                key: const ValueKey('food-form-sodium-input'),
                filled: true,
                theme: widget.theme,
                maxLines: 1,
                fontSize: fontSize,
                padding: widget.sizes.padding,
                isLoading: widget.isLoading,
                controller: _sodiumController,
                keyboardType: TextInputType.number,
                labelText: 'Sodium (mg)',
                onChanged: (value) {
                  setState(() {
                    _data.sodiumBase = value;
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.sodiumBase = value;
                    });
                  }
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
                'Portions',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                key: const ValueKey('food-form-add-portion-btn'),
                icon: Icon(Icons.add, size: widget.sizes.buttonIconSize),
                label: Text(
                  'Add Portion',
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: _addPortion,
              ),
            ],
          ),
          if (_portionRows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: widget.sizes.padding),
              child: Text(
                'No additional portions defined. Default serving size will be used.',
                style: TextStyle(fontSize: fontSize * 0.9, color: Colors.grey),
              ),
            ),
          ..._portionRows.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: widget.sizes.padding / 2),
              child: ResponsiveFields(
                sizes: widget.sizes,
                children: [
                  AppTextFormField(
                    filled: true,
                    theme: widget.theme,
                    maxLines: 1,
                    fontSize: fontSize,
                    padding: widget.sizes.padding,
                    isLoading: widget.isLoading,
                    controller: row.nameController,
                    labelText: 'Portion Name',
                    hintText: 'e.g. 1 slice, 1 cup',
                  ),
                  AppTextFormField(
                    filled: true,
                    theme: widget.theme,
                    maxLines: 1,
                    fontSize: fontSize,
                    padding: widget.sizes.padding,
                    isLoading: widget.isLoading,
                    controller: row.gramsController,
                    keyboardType: TextInputType.number,
                    labelText: 'Grams',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: widget.sizes.buttonIconSize,
                    ),
                    onPressed: () => _removePortion(idx),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: widget.sizes.spacing),
          AppElevatedButton(
            key: const ValueKey('food-form-save-btn'),
            theme: widget.theme,
            isLoading: widget.isLoading,
            sizes: widget.sizes,
            onPressed: _submit,
            label: widget.initialFood != null ? 'Update Food' : 'Create Food',
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;
  String brand;
  FoodCategory category;
  String servingSizeBaseGrams;
  String caloriesBase;
  String proteinBase;
  String carbsBase;
  String fatBase;
  String fiberBase;
  String sodiumBase;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.brand,
    required this.category,
    required this.servingSizeBaseGrams,
    required this.caloriesBase,
    required this.proteinBase,
    required this.carbsBase,
    required this.fatBase,
    required this.fiberBase,
    required this.sodiumBase,
    required this.isFavorite,
  });
}
