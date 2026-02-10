import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/app_primary_button.dart';
import '../layout/app_text_form_field.dart';

class EquipmentForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final String initialName;
  final bool isLoading;
  final String submitLabel;
  final void Function({required String name}) onSubmit;

  const EquipmentForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.initialName,
    required this.isLoading,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextFormField(
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _nameController,
            labelText: 'Name',
            hintText: 'Enter equipment name',
            fontSize: widget.sizes.subtitleFontSize * 1.25,
            padding: widget.sizes.padding * 1.3,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppPrimaryButton(
            isLoading: widget.isLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(name: _data.name);
              }
            },
            sizes: widget.sizes,
            theme: widget.theme,
            label: widget.submitLabel,
            icon: Icons.check,
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
