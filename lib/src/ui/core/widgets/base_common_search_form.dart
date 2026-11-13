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

import 'package:material_ui/material_ui.dart';

import '../../../data/utils/display_names.dart';
import '../../../data/utils/enums.dart';
import './created_by_checkbox.dart';
import './favourite_checkbox.dart';
import './layout/app_dropdown.dart';
import './layout/app_text_form_field.dart';
import './search_form_button.dart';

class BaseCommonSearchForm extends StatefulWidget {
  final ThemeData theme;
  final String nameLabel;
  final double fontSize;
  final double padding;
  final double spacing;

  final bool isLoading;
  final String initialName;
  final Difficulty? initialDifficulty;
  final MuscleGroup? initialMuscleGroup;
  final int? initialEquipmentId;
  final Map<int, String>? equipmentSelection;
  final bool initialIsFavorite;
  final CreatedBy? initialCreatedBy;
  final bool showMuscleGroup;
  final bool showCreatedBy;
  final void Function({
    required String name,
    required Difficulty? difficulty,
    required MuscleGroup? muscleGroup,
    required int? equipmentId,
    required bool isFavourite,
    required CreatedBy? createdBy,
  })
  onSubmit;

  const BaseCommonSearchForm({
    super.key,
    required this.theme,
    required this.nameLabel,
    required this.padding,
    required this.fontSize,
    required this.spacing,
    required this.isLoading,
    required this.initialName,
    required this.initialDifficulty,
    this.initialMuscleGroup,
    this.initialEquipmentId,
    this.equipmentSelection,
    required this.initialIsFavorite,
    this.initialCreatedBy,
    this.showMuscleGroup = true,
    this.showCreatedBy = false,
    required this.onSubmit,
  });

  @override
  State<BaseCommonSearchForm> createState() => _BaseCommonSearchFormState();
}

class _BaseCommonSearchFormState extends State<BaseCommonSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      difficulty: widget.initialDifficulty,
      muscleGroup: widget.initialMuscleGroup,
      equipmentId: widget.initialEquipmentId,
      isFavourite: widget.initialIsFavorite,
      createdBy: widget.initialCreatedBy,
    );
    _nameController.text = _data.name;
  }

  @override
  void didUpdateWidget(BaseCommonSearchForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName &&
        widget.initialName != _data.name) {
      _data.name = widget.initialName;
      _nameController.text = widget.initialName;
    }
    if (oldWidget.initialDifficulty != widget.initialDifficulty &&
        widget.initialDifficulty != _data.difficulty) {
      _data.difficulty = widget.initialDifficulty;
    }
    if (oldWidget.initialMuscleGroup != widget.initialMuscleGroup &&
        widget.initialMuscleGroup != _data.muscleGroup) {
      _data.muscleGroup = widget.initialMuscleGroup;
    }
    if (oldWidget.initialEquipmentId != widget.initialEquipmentId &&
        widget.initialEquipmentId != _data.equipmentId) {
      _data.equipmentId = widget.initialEquipmentId;
    }
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite &&
        widget.initialIsFavorite != _data.isFavourite) {
      _data.isFavourite = widget.initialIsFavorite;
    }
    if (oldWidget.initialCreatedBy != widget.initialCreatedBy &&
        widget.initialCreatedBy != _data.createdBy) {
      _data.createdBy = widget.initialCreatedBy;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingSize = widget.fontSize * 2;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            theme: widget.theme,
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
                value: _data.isFavourite,
                onChanged: (value) {
                  setState(() {
                    _data.isFavourite = value;
                  });
                },
              ),
              if (widget.showCreatedBy) ...[
                SizedBox(width: widget.spacing),
                CreatedByCheckbox(
                  value: _data.createdBy,
                  onChanged: (value) {
                    setState(() {
                      _data.createdBy = value;
                    });
                  },
                ),
              ],
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
              if (widget.showMuscleGroup) ...[
                SizedBox(width: widget.spacing),
                Expanded(
                  child: AppDropdown<MuscleGroup>(
                    value: _data.muscleGroup,
                    emptyLabel: 'All Muscle Groups',
                    items: MuscleGroup.values,
                    fontSize: widget.fontSize,
                    padding: widget.padding / 2,
                    labelBuilder: (d) {
                      return EnumDisplayNames.getMuscleGroupDisplayName(d);
                    },
                    onChanged: (value) {
                      setState(() {
                        _data.muscleGroup = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _data.muscleGroup = value;
                      });
                    },
                  ),
                ),
              ],
              if (widget.equipmentSelection == null) ...[
                SizedBox(width: widget.spacing),
                SearchFormButton(
                  theme: widget.theme,
                  loadingSize: loadingSize,
                  isLoading: widget.isLoading,
                  onPressed: _submit,
                ),
              ],
            ],
          ),
          if (widget.equipmentSelection != null) ...[
            SizedBox(height: widget.spacing),
            Row(
              children: [
                Expanded(
                  child: AppDropdown<int>(
                    value: _data.equipmentId,
                    emptyLabel: 'All Equipment',
                    items: widget.equipmentSelection!.keys.toList(),
                    fontSize: widget.fontSize,
                    padding: widget.padding / 2,
                    labelBuilder: (id) => widget.equipmentSelection![id]!,
                    onChanged: (value) {
                      setState(() {
                        _data.equipmentId = value;
                      });
                    },
                    onSaved: (value) {
                      _data.equipmentId = value;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                SearchFormButton(
                  theme: widget.theme,
                  loadingSize: loadingSize,
                  isLoading: widget.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
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
      difficulty: _data.difficulty,
      muscleGroup: _data.muscleGroup,
      equipmentId: _data.equipmentId,
      isFavourite: _data.isFavourite,
      createdBy: _data.createdBy,
    );
  }
}

final class _FormData {
  String name;
  Difficulty? difficulty;
  MuscleGroup? muscleGroup;
  int? equipmentId;
  bool isFavourite;
  CreatedBy? createdBy;

  _FormData({
    required this.name,
    required this.difficulty,
    required this.muscleGroup,
    required this.equipmentId,
    required this.isFavourite,
    required this.createdBy,
  });
}
