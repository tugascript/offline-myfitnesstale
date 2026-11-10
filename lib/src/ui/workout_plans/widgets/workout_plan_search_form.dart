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

import '../../core/widgets/layout/app_dropdown.dart';
import '../../core/widgets/layout/app_text_form_field.dart';
import '../../core/widgets/favourite_checkbox.dart';
import '../../../data/utils/display_names.dart';

class WorkoutPlanSearchForm extends StatefulWidget {
  final String nameLabel;
  final double fontSize;
  final double padding;
  final double spacing;

  final bool isLoading;
  final String initialName;
  final Difficulty? initialDifficulty;
  final bool initialIsFavorite;
  final void Function({
    required String name,
    required Difficulty? difficulty,
    required bool isFavorite,
  })
  onSubmit;

  const WorkoutPlanSearchForm({
    super.key,
    required this.nameLabel,
    required this.padding,
    required this.fontSize,
    required this.spacing,
    required this.isLoading,
    required this.initialName,
    required this.initialDifficulty,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<WorkoutPlanSearchForm> createState() => _WorkoutPlanSearchFormState();
}

class _WorkoutPlanSearchFormState extends State<WorkoutPlanSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      difficulty: widget.initialDifficulty,
      isFavorite: widget.initialIsFavorite,
    );
    _nameController.text = widget.initialName;
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
                value: _data.isFavorite,
                onChanged: (value) {
                  setState(() {
                    _data.isFavorite = value;
                  });
                },
              ),
              SizedBox(width: widget.spacing),
              Expanded(
                child: AppDropdown<Difficulty>(
                  value: _data.difficulty,
                  emptyLabel: 'All Difficulties',
                  items: Difficulty.values,
                  fontSize: widget.fontSize,
                  padding: widget.padding / 2,
                  labelBuilder: (d) {
                    return EnumDisplayNames.getDifficultyDisplayName(d);
                  },
                  onChanged: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                  },
                ),
              ),
              SizedBox(width: widget.spacing),
              IconButton(
                icon: widget.isLoading
                    ? SizedBox(
                        width: loadingSize,
                        height: loadingSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: loadingSize,
                        color: Theme.of(context).primaryColor,
                      ),
                onPressed: () {
                  setState(() {
                    if (!widget.isLoading) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onSubmit(
                          name: _data.name,
                          difficulty: _data.difficulty,
                          isFavorite: _data.isFavorite,
                        );
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;
  Difficulty? difficulty;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.difficulty,
    required this.isFavorite,
  });
}
