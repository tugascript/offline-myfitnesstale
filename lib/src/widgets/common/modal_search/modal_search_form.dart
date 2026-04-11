import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../favourite_checkbox.dart';
import '../../layout/app_dropdown.dart';
import '../../layout/app_text_form_field.dart';

class ModalSearchForm extends StatefulWidget {
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

  const ModalSearchForm({
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
  State<ModalSearchForm> createState() => _ModalSearchFormState();
}

class _ModalSearchFormState extends State<ModalSearchForm> {
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
            fontSize: widget.sizes.fontSize,
            maxLines: 1,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
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
                size: widget.sizes.fontSize,
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
                size: widget.sizes.fontSize * 2,
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
                  emptyLabel: 'All Muscle Groups',
                  items: MuscleGroup.values,
                  fontSize: widget.sizes.fontSize,
                  padding: padding / 5,
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
              _SmallSearchButton(
                widget: widget,
                formKey: _formKey,
                data: _data,
                padding: padding,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSearchButton extends StatelessWidget {
  const _SmallSearchButton({
    required this.widget,
    required GlobalKey<FormState> formKey,
    required _FormData data,
    required this.padding,
  })  : _formKey = formKey,
        _data = data;

  final ModalSearchForm widget;
  final GlobalKey<FormState> _formKey;
  final _FormData _data;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(double.infinity),
      onTap: () {
        if (widget.isLoading) {
          return;
        }

        if (_formKey.currentState != null &&
            _formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          widget.onSubmit(
            name: _data.name,
            muscleGroup: _data.muscleGroup,
            isFavorite: _data.isFavorite,
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding / 2,
        ),
        child: widget.isLoading
            ? SizedBox(
                width: widget.sizes.fontSize * 2,
                height: widget.sizes.fontSize * 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.theme.primaryColor,
                  ),
                ),
              )
            : Icon(
                Icons.search,
                size: widget.sizes.fontSize * 2,
                color: widget.theme.primaryColor,
              ),
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
