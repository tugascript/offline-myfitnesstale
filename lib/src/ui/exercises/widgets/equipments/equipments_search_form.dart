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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/created_by_checkbox.dart';
import '../../../core/widgets/favourite_checkbox.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/search_form_button.dart';

class EquipmentsSearchForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final bool isLoading;
  final String initialName;
  final bool initialIsFavorite;
  final CreatedBy? initialCreatedBy;
  final void Function({
    required String name,
    required bool isFavorite,
    required CreatedBy? createdBy,
  })
  onSubmit;

  const EquipmentsSearchForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.initialName,
    required this.initialIsFavorite,
    this.initialCreatedBy,
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
      isFavorite: widget.initialIsFavorite,
      createdBy: widget.initialCreatedBy,
    );
    _nameController.text = _data.name;
  }

  @override
  void didUpdateWidget(EquipmentsSearchForm oldWidget) {
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
    if (oldWidget.initialCreatedBy != widget.initialCreatedBy &&
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
    final loadingSize = widget.sizes.fontSize * 2;
    return Form(
      key: _formKey,
      child: Row(
        children: [
          HeartCheckbox(
            value: _data.isFavorite,
            onChanged: (value) {
              setState(() {
                _data.isFavorite = value;
              });
            },
          ),
          SizedBox(width: widget.sizes.inputSpacing),
          CreatedByCheckbox(
            value: _data.createdBy,
            onChanged: (value) {
              setState(() {
                _data.createdBy = value;
              });
            },
          ),
          SizedBox(width: widget.sizes.inputSpacing),
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
              onFieldSubmitted: (_) => _submit(),
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
    widget.onSubmit(
      name: _data.name,
      isFavorite: _data.isFavorite,
      createdBy: _data.createdBy,
    );
  }
}

final class _FormData {
  String name;
  bool isFavorite;
  CreatedBy? createdBy;

  _FormData({
    required this.name,
    required this.isFavorite,
    required this.createdBy,
  });
}
