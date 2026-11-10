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

import '../../../data/utils/enums.dart';

import '../../core/widgets/favourite_checkbox.dart';
import '../../core/widgets/search_form_button.dart';
import '../../core/widgets/layout/app_dropdown.dart';
import '../../core/widgets/layout/app_text_form_field.dart';
import '../../../data/utils/display_names.dart';

class FoodSearchForm extends StatefulWidget {
  final String nameLabel;
  final double fontSize;
  final double padding;
  final double spacing;

  final bool isLoading;
  final String initialName;
  final FoodCategory? initialCategory;
  final bool initialIsFavorite;
  final void Function({
    required String name,
    required FoodCategory? category,
    required bool isFavorite,
  })
  onSubmit;

  const FoodSearchForm({
    super.key,
    this.nameLabel = 'foods',
    required this.padding,
    required this.fontSize,
    required this.spacing,
    required this.isLoading,
    required this.initialName,
    required this.initialCategory,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<FoodSearchForm> createState() => _FoodSearchFormState();
}

class _FoodSearchFormState extends State<FoodSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      category: widget.initialCategory,
      isFavorite: widget.initialIsFavorite,
    );
    _nameController.text = widget.initialName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingSize = widget.fontSize * 2;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            key: const ValueKey('foods-search-input'),
            theme: theme,
            isLoading: widget.isLoading,
            controller: _nameController,
            hintText: 'Search ${widget.nameLabel}...',
            fontSize: widget.fontSize,
            padding: widget.padding,
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
            onFieldSubmitted: (_) => _submit(),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.padding * 0.65),
              child: Icon(Icons.search, size: widget.fontSize),
            ),
            suffixIcon: _data.name.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.clear, size: widget.fontSize),
                    onPressed: () {
                      setState(() {
                        _data.name = '';
                      });
                      _nameController.clear();
                    },
                  )
                : null,
          ),
          SizedBox(height: widget.spacing),
          Row(
            children: [
              HeartCheckbox(
                key: const ValueKey('foods-filter-favorites'),
                value: _data.isFavorite,
                tooltip: _data.isFavorite
                    ? 'Show all ${widget.nameLabel}'
                    : 'Filter favorite ${widget.nameLabel}',
                onChanged: (value) {
                  setState(() {
                    _data.isFavorite = value;
                  });
                },
              ),
              SizedBox(width: widget.spacing),
              Expanded(
                child: AppDropdown<FoodCategory>(
                  key: const ValueKey('foods-filter-category'),
                  value: _data.category,
                  emptyLabel: 'All Categories',
                  items: FoodCategory.values,
                  fontSize: widget.fontSize,
                  padding: widget.padding / 2,
                  labelBuilder: (c) {
                    return EnumDisplayNames.getFoodCategoryDisplayName(c);
                  },
                  onChanged: (value) {
                    setState(() {
                      _data.category = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.category = value;
                    });
                  },
                ),
              ),
              SearchFormButton(
                key: const ValueKey('foods-search-button'),
                theme: theme,
                loadingSize: loadingSize,
                isLoading: widget.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (widget.isLoading || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    widget.onSubmit(
      name: _data.name,
      category: _data.category,
      isFavorite: _data.isFavorite,
    );
  }
}

final class _FormData {
  String name;
  FoodCategory? category;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.category,
    required this.isFavorite,
  });
}
