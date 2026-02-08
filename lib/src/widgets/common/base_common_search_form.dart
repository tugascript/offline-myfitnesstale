import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../layout/app_dropdown.dart';
import '../layout/app_text_form_field.dart';
import 'search_form_button.dart';

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
  final void Function({
    required String name,
    required Difficulty? difficulty,
    required MuscleGroup? muscleGroup,
  }) onSubmit;

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
    required this.initialMuscleGroup,
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
    );
    _nameController.text = _data.name;
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
              padding: EdgeInsets.symmetric(
                horizontal: widget.padding * 0.65,
              ),
              child: Icon(
                Icons.search,
                size: widget.fontSize,
              ),
            ),
            suffixIcon: _data.name.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.clear,
                      size: widget.fontSize,
                    ),
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
              Expanded(
                child: AppDropdown<Difficulty>(
                  value: _data.difficulty,
                  label: 'All Difficulties',
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
              Expanded(
                child: AppDropdown<MuscleGroup>(
                  value: _data.muscleGroup,
                  label: 'All Muscle Groups',
                  items: MuscleGroup.values,
                  fontSize: widget.fontSize,
                  padding: widget.padding / 2,
                  labelBuilder: (d) {
                    return EnumDisplayNames.getMuscleGroupDisplayName(
                      d,
                    );
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
              SizedBox(width: widget.spacing),
              SearchFormButton(
                theme: widget.theme,
                loadingSize: loadingSize,
                isLoading: widget.isLoading,
                onPressed: () {
                  if (!widget.isLoading) {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSubmit(
                        name: _data.name,
                        difficulty: _data.difficulty,
                        muscleGroup: _data.muscleGroup,
                      );
                    }
                  }
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
  MuscleGroup? muscleGroup;

  _FormData({
    required this.name,
    required this.difficulty,
    required this.muscleGroup,
  });
}
