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

import 'package:flutter/material.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/search_form_button.dart';
import '../../core/widgets/layout/app_text_form_field.dart';

class EquipmentsSearchForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final String initialName;
  final void Function({required String name}) onSubmit;

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
    _data = _FormData(name: widget.initialName);
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
                child: Icon(Icons.search, size: widget.sizes.fontSize),
              ),
              suffixIcon: _data.name.isNotEmpty
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.clear, size: widget.sizes.fontSize),
                      onPressed: () {
                        setState(() {
                          _data.name = '';
                        });
                        _nameController.clear();
                      },
                    )
                  : null,
              theme: widget.theme,
              isLoading: widget.isLoading,
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
                  widget.onSubmit(name: _data.name);
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

  _FormData({required this.name});
}
