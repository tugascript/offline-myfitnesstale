import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/utilities.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/favourite_checkbox.dart';
import '../../../common/search_form_button.dart';
import '../../../layout/app_dropdown.dart';
import '../../../layout/app_text_form_field.dart';

class SetExerciseSearchForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final String initialName;
  final MuscleGroup? initialMuscleGroup;
  final bool initialIsFavorite;
  final void Function({
    required String name,
    required MuscleGroup? muscleGroup,
    required bool isFavorite,
  }) onSubmit;

  const SetExerciseSearchForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.initialName,
    required this.initialMuscleGroup,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<SetExerciseSearchForm> createState() => _SetExerciseSearchFormState();
}

class _SetExerciseSearchFormState extends State<SetExerciseSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      muscleGroup: widget.initialMuscleGroup,
      isFavorite: widget.initialIsFavorite,
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
    final loadingSize = widget.sizes.smallFontSize * 2;
    final padding = widget.sizes.padding / 2;
    final spacing = widget.sizes.spacing / 2;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _nameController,
            hintText: 'Search Exercises...',
            fontSize: widget.sizes.smallFontSize,
            padding: padding,
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
                horizontal: padding,
              ),
              child: Icon(
                Icons.search,
                size: widget.sizes.smallFontSize,
              ),
            ),
            suffixIcon: _data.name.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.clear,
                      size: widget.sizes.smallFontSize,
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
          SizedBox(height: widget.sizes.spacing / 2),
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
              SizedBox(width: spacing),
              Expanded(
                child: AppDropdown<MuscleGroup>(
                  value: _data.muscleGroup,
                  label: 'All Muscle Groups',
                  items: MuscleGroup.values,
                  fontSize: widget.sizes.smallFontSize,
                  padding: padding,
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
              SizedBox(width: spacing),
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
                        muscleGroup: _data.muscleGroup,
                        isFavorite: _data.isFavorite,
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

class _FormData {
  String name;
  MuscleGroup? muscleGroup;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.muscleGroup,
    required this.isFavorite,
  });
}
