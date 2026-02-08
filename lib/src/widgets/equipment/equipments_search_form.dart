import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../common/search_form_button.dart';
import '../layout/app_text_form_field.dart';

class EquipmentsSearchForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final String initialName;
  final void Function({
    required String name,
  }) onSubmit;

  const EquipmentsSearchForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.initialName,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<EquipmentsSearchForm> createState() => _EquipmentsSearchFormState();
}

class _EquipmentsSearchFormState extends State<EquipmentsSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
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
    final loadingSize = widget.sizes.fontSize * 2;
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: AppTextFormField(
              controller: _nameController,
              hintText: "Search Equipments...",
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
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
                  horizontal: widget.sizes.padding * 0.65,
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
                        size: widget.sizes.fontSize,
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
          ),
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
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;

  _FormData({
    required this.name,
  });
}
