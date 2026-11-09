import 'package:flutter/material.dart';

import '../layout/app_text_form_field.dart';
import 'favourite_checkbox.dart';
import 'search_form_button.dart';

class SearchFavoriteForm extends StatefulWidget {
  final ThemeData theme;
  final String nameLabel;
  final double fontSize;
  final double padding;
  final double spacing;

  final bool isLoading;
  final String initialName;
  final bool initialIsFavorite;
  final void Function({required String name, required bool isFavorite})
  onSubmit;

  const SearchFavoriteForm({
    super.key,
    required this.theme,
    required this.nameLabel,
    required this.padding,
    required this.fontSize,
    required this.spacing,
    required this.isLoading,
    required this.initialName,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<SearchFavoriteForm> createState() => _SearchFavoriteFormState();
}

class _SearchFavoriteFormState extends State<SearchFavoriteForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      isFavorite: widget.initialIsFavorite,
    );
    _nameController.text = _data.name;
  }

  @override
  void didUpdateWidget(SearchFavoriteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName &&
        widget.initialName != _data.name) {
      _data.name = widget.initialName;
      _nameController.text = widget.initialName;
    }
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite &&
        widget.initialIsFavorite != _data.isFavorite) {
      _data.isFavorite = widget.initialIsFavorite;
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
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
            child: AppTextFormField(
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
                padding: EdgeInsets.symmetric(
                  horizontal: widget.padding * 0.65,
                ),
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
          ),
          SearchFormButton(
            theme: widget.theme,
            loadingSize: loadingSize,
            isLoading: widget.isLoading,
            onPressed: _submit,
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
    widget.onSubmit(name: _data.name, isFavorite: _data.isFavorite);
  }
}

final class _FormData {
  String name;
  bool isFavorite;

  _FormData({required this.name, required this.isFavorite});
}
