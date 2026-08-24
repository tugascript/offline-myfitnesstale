import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../layout/app_dropdown.dart';
import '../layout/app_text_form_field.dart';
import '../common/favourite_checkbox.dart';

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
  }) onSubmit;

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
              )
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
