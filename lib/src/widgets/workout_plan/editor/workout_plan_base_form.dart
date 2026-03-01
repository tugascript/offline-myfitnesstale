import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_dropdown.dart';
import '../../layout/app_primary_button.dart';
import '../../layout/app_text_form_field.dart';

class WorkoutPlanBaseForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String submitLabel;

  final String initialName;
  final bool initialIsFavorite;
  final Difficulty initialDifficulty;
  final String? initialDescription;

  final void Function({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    String? description,
  }) onSubmit;

  const WorkoutPlanBaseForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.submitLabel,
    required this.initialName,
    required this.initialIsFavorite,
    required this.initialDifficulty,
    this.initialDescription,
    required this.onSubmit,
  });

  @override
  State<WorkoutPlanBaseForm> createState() => _WorkoutPlanBaseFormState();
}

class _WorkoutPlanBaseFormState extends State<WorkoutPlanBaseForm> {
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
        description: _data.description,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  hintText: "Enter the name of the workout plan",
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the name of the workout plan";
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
            hintText: "Enter workout plan description",
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
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
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
  String? description;

  _FormData({
    required this.name,
    required this.isFavorite,
    required this.difficulty,
    this.description,
  });
}
