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

import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/layout/sharp_switch_title.dart';

class WorkoutBaseForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String submitLabel;

  final String initialName;
  final bool initialIsFavorite;
  final Difficulty initialDifficulty;
  final EditorType initialEditorType;
  final String? initialDescription;

  final void Function({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    required EditorType editorType,
    String? description,
  })
  onSubmit;

  const WorkoutBaseForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.submitLabel,
    required this.initialName,
    required this.initialIsFavorite,
    required this.initialDifficulty,
    required this.initialEditorType,
    required this.onSubmit,
    this.initialDescription,
  });

  @override
  State<WorkoutBaseForm> createState() => _WorkoutBaseFormState();
}

class _WorkoutBaseFormState extends State<WorkoutBaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      isFavorite: widget.initialIsFavorite,
      difficulty: widget.initialDifficulty,
      editorType: widget.initialEditorType,
      description: widget.initialDescription,
    );
    _nameController.text = widget.initialName;
    _descriptionController.text = widget.initialDescription ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(
        name: _data.name,
        isFavorite: _data.isFavorite,
        difficulty: _data.difficulty,
        editorType: _data.editorType,
        description: _data.description,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdvancedEditorEnabled = _data.editorType == EditorType.advanced;
    final isAdvancedEditorLocked =
        widget.initialEditorType == EditorType.advanced;
    final canToggleAdvancedEditor = !isAdvancedEditorLocked;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: AppTextFormField(
                  filled: true,
                  theme: widget.theme,
                  maxLines: 1,
                  isLoading: widget.isLoading,
                  controller: _nameController,
                  labelText: "Name",
                  hintText: "Enter the name of the workout",
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the name of the workout";
                    }
                    return null;
                  },
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
                ),
              ),
              IconButton(
                icon: Icon(
                  _data.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.theme.colorScheme.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _data.isFavorite = !_data.isFavorite;
                  });
                },
                tooltip: _data.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _descriptionController,
            labelText: "Description",
            hintText: "Enter workout description",
            maxLines: 4,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            onChanged: (value) {
              setState(() {
                _data.description = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.description = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<Difficulty>(
            value: _data.difficulty,
            filled: true,
            labelText: 'Difficulty',
            emptyLabel: 'Difficulty',
            showEmptyValue: false,
            items: Difficulty.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: EnumDisplayNames.getDifficultyDisplayName,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _data.difficulty = value;
                });
              }
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.difficulty = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          SharpSwitchTitle(
            contentPadding: EdgeInsets.zero,
            title: 'Advanced Editor',
            value: isAdvancedEditorEnabled,
            enabled: canToggleAdvancedEditor,
            thumbSize: widget.sizes.subtitleFontSize * 1.5,
            switchPadding: EdgeInsets.all(widget.sizes.padding / 2),
            onChanged: (value) {
              if (!canToggleAdvancedEditor) return;

              setState(() {
                _data.editorType = value
                    ? EditorType.advanced
                    : EditorType.basic;
              });
            },
          ),
          if (isAdvancedEditorLocked) ...[
            SizedBox(height: widget.sizes.spacing / 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This workout already uses Advanced Editor and cannot be changed.',
                style: TextStyle(
                  fontSize: widget.sizes.smallFontSize,
                  color: widget.theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
          SizedBox(height: widget.sizes.padding * 1.25),
          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              theme: widget.theme,
              isLoading: widget.isLoading,
              sizes: widget.sizes,
              onPressed: _submit,
              label: widget.submitLabel,
              icon: Icons.save,
            ),
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;
  bool isFavorite;
  Difficulty difficulty;
  EditorType editorType;
  String? description;

  _FormData({
    required this.name,
    required this.isFavorite,
    required this.difficulty,
    required this.editorType,
    this.description,
  });
}
