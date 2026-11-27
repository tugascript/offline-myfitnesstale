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
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/created_by_checkbox.dart';
import '../../core/widgets/favourite_checkbox.dart';
import '../../core/widgets/layout/app_dropdown.dart';
import '../../core/widgets/layout/app_text_form_field.dart';
import '../../core/widgets/search_form_button.dart';

class CardioExerciseSearchForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String? initialName;
  final Difficulty? initialDifficulty;
  final CardioBaseMode? initialCardioBaseMode;
  final CardioUnitType? initialCardioUnitType;
  final int? initialEquipmentId;
  final Map<int, String>? equipmentSelection;
  final bool initialIsFavorite;
  final CreatedBy? initialCreatedBy;
  final bool showCreatedBy;
  final void Function({
    String? name,
    Difficulty? difficulty,
    CardioBaseMode? cardioBaseMode,
    CardioUnitType? cardioUnitType,
    int? equipmentId,
    bool isFavourite,
    CreatedBy? createdBy,
  })
  onSubmit;
  final void Function({
    required String name,
    required Difficulty? difficulty,
    required int? equipmentId,
    required bool isFavourite,
    required CreatedBy? createdBy,
  })?
  onSharedFiltersChanged;

  const CardioExerciseSearchForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    this.initialName,
    this.initialDifficulty,
    this.initialCardioBaseMode,
    this.initialCardioUnitType,
    this.initialEquipmentId,
    this.equipmentSelection,
    this.initialIsFavorite = false,
    this.initialCreatedBy,
    this.showCreatedBy = true,
    required this.onSubmit,
    this.onSharedFiltersChanged,
  });

  @override
  State<CardioExerciseSearchForm> createState() =>
      _CardioExerciseSearchFormState();
}

class _CardioExerciseSearchFormState extends State<CardioExerciseSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _CardioSearchFormData _data;

  @override
  void initState() {
    super.initState();
    _data = _CardioSearchFormData(
      name: widget.initialName ?? '',
      difficulty: widget.initialDifficulty,
      cardioBaseMode: widget.initialCardioBaseMode,
      cardioUnitType: widget.initialCardioUnitType,
      equipmentId: widget.initialEquipmentId,
      isFavourite: widget.initialIsFavorite,
      createdBy: widget.initialCreatedBy,
    );
    _nameController.text = _data.name;
  }

  @override
  void didUpdateWidget(covariant CardioExerciseSearchForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialName != oldWidget.initialName &&
        (widget.initialName ?? '') != _data.name) {
      _data.name = widget.initialName ?? '';
      _nameController.value = TextEditingValue(
        text: _data.name,
        selection: TextSelection.collapsed(offset: _data.name.length),
      );
    }
    if (widget.initialDifficulty != oldWidget.initialDifficulty &&
        widget.initialDifficulty != _data.difficulty) {
      _data.difficulty = widget.initialDifficulty;
    }
    if (widget.initialCardioBaseMode != oldWidget.initialCardioBaseMode &&
        widget.initialCardioBaseMode != _data.cardioBaseMode) {
      _data.cardioBaseMode = widget.initialCardioBaseMode;
    }
    if (widget.initialCardioUnitType != oldWidget.initialCardioUnitType &&
        widget.initialCardioUnitType != _data.cardioUnitType) {
      _data.cardioUnitType = widget.initialCardioUnitType;
    }
    if (widget.initialEquipmentId != oldWidget.initialEquipmentId &&
        widget.initialEquipmentId != _data.equipmentId) {
      _data.equipmentId = widget.initialEquipmentId;
    }
    if (widget.initialIsFavorite != oldWidget.initialIsFavorite &&
        widget.initialIsFavorite != _data.isFavourite) {
      _data.isFavourite = widget.initialIsFavorite;
    }
    if (widget.initialCreatedBy != oldWidget.initialCreatedBy &&
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
    final double iconSize = widget.sizes.iconFontSize;
    final double loadingSize = widget.sizes.fontSize * 1.4;
    final double spacing = widget.sizes.inputSpacing;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _nameController,
            hintText: 'Search Cardio Exercise',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            maxLines: 1,
            onChanged: (value) {
              setState(() {
                _data.name = value;
              });
              _notifySharedFiltersChanged();
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.name = value;
                });
              }
            },
            prefixIcon: Icon(Icons.search, size: iconSize),
            suffixIcon: _data.name.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.clear, size: iconSize),
                    onPressed: () {
                      setState(() {
                        _data.name = '';
                      });
                      _nameController.clear();
                      _notifySharedFiltersChanged();
                    },
                  )
                : null,
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              HeartCheckbox(
                value: _data.isFavourite,
                onChanged: (value) {
                  setState(() {
                    _data.isFavourite = value;
                  });
                  _notifySharedFiltersChanged();
                },
              ),
              if (widget.showCreatedBy) ...[
                SizedBox(width: spacing),
                CreatedByCheckbox(
                  value: _data.createdBy,
                  onChanged: (value) {
                    setState(() {
                      _data.createdBy = value;
                    });
                    _notifySharedFiltersChanged();
                  },
                ),
              ],
              SizedBox(width: spacing),
              Expanded(
                child: AppDropdown<Difficulty>(
                  theme: widget.theme,
                  isLoading: widget.isLoading,
                  value: _data.difficulty,
                  emptyLabel: 'All Difficulties',
                  items: Difficulty.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  labelBuilder: EnumDisplayNames.getDifficultyDisplayName,
                  onChanged: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                    _notifySharedFiltersChanged();
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                  },
                  prefixIcon: Icon(Icons.bolt, size: iconSize),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: AppDropdown<CardioBaseMode>(
                  key: const ValueKey('cardio-search-mode-dropdown'),
                  theme: widget.theme,
                  isLoading: widget.isLoading,
                  value: _data.cardioBaseMode,
                  emptyLabel: 'All Modes',
                  items: CardioBaseMode.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  labelBuilder: EnumDisplayNames.getCardioBaseModeDisplayName,
                  onChanged: (value) {
                    setState(() {
                      _data.cardioBaseMode = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.cardioBaseMode = value;
                    });
                  },
                  prefixIcon: Icon(Icons.timer_outlined, size: iconSize),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: AppDropdown<CardioUnitType>(
                  key: const ValueKey('cardio-search-unit-type-dropdown'),
                  theme: widget.theme,
                  isLoading: widget.isLoading,
                  value: _data.cardioUnitType,
                  emptyLabel: 'All Unit Types',
                  items: CardioUnitType.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  labelBuilder: EnumDisplayNames.getCardioUnitTypeDisplayName,
                  onChanged: (value) {
                    setState(() {
                      _data.cardioUnitType = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.cardioUnitType = value;
                    });
                  },
                  prefixIcon: Icon(Icons.straighten, size: iconSize),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              if (widget.equipmentSelection != null) ...[
                Expanded(
                  child: AppDropdown<int>(
                    theme: widget.theme,
                    isLoading: widget.isLoading,
                    value: _data.equipmentId,
                    emptyLabel: 'All Equipment',
                    items: widget.equipmentSelection!.keys.toList(),
                    fontSize: widget.sizes.fontSize,
                    padding: widget.sizes.padding,
                    labelBuilder: (id) => widget.equipmentSelection![id]!,
                    onChanged: (value) {
                      setState(() {
                        _data.equipmentId = value;
                      });
                      _notifySharedFiltersChanged();
                    },
                    onSaved: (value) {
                      _data.equipmentId = value;
                    },
                    prefixIcon: Icon(Icons.build_outlined, size: iconSize),
                  ),
                ),
                SizedBox(width: spacing),
              ] else
                const Spacer(),
              SearchFormButton(
                theme: widget.theme,
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

  void _notifySharedFiltersChanged() {
    widget.onSharedFiltersChanged?.call(
      name: _data.name,
      difficulty: _data.difficulty,
      equipmentId: _data.equipmentId,
      isFavourite: _data.isFavourite,
      createdBy: _data.createdBy,
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
      cardioBaseMode: _data.cardioBaseMode,
      cardioUnitType: _data.cardioUnitType,
      equipmentId: _data.equipmentId,
      isFavourite: _data.isFavourite,
      createdBy: _data.createdBy,
    );
  }
}

final class _CardioSearchFormData {
  String name;
  Difficulty? difficulty;
  CardioBaseMode? cardioBaseMode;
  CardioUnitType? cardioUnitType;
  int? equipmentId;
  bool isFavourite;
  CreatedBy? createdBy;

  _CardioSearchFormData({
    required this.name,
    required this.difficulty,
    required this.cardioBaseMode,
    required this.cardioUnitType,
    required this.equipmentId,
    required this.isFavourite,
    required this.createdBy,
  });
}
