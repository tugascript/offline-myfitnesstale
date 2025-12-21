import 'package:flutter/material.dart';

import '../../models/enums.dart';
import 'height_input.dart';

final class _FormData {
  String name;
  int height;
  Gender gender;

  _FormData({
    required this.name,
    required this.height,
    required this.gender,
  });
}

final class ProfileForm extends StatefulWidget {
  final String initialName;
  final int initialHeight;
  final Gender initialGender;
  final Units units;
  final void Function({
    required String name,
    required int height,
    required Gender gender,
  }) onSubmit;
  final void Function(Units unit) onUnitsChanged;
  final String submitButtonLabel;
  final bool isLoading;

  const ProfileForm({
    super.key,
    required this.initialName,
    required this.initialHeight,
    required this.initialGender,
    required this.units,
    required this.onUnitsChanged,
    required this.onSubmit,
    required this.submitButtonLabel,
    required this.isLoading,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      height: widget.initialHeight,
      gender: widget.initialGender,
    );
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
        children: [
          TextFormField(
            controller: _nameController,
            initialValue: _data.name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
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
            enabled: !widget.isLoading,
          ),
          DropdownButtonFormField<Gender>(
            initialValue: _data.gender,
            decoration: InputDecoration(labelText: 'Gender'),
            items: Gender.values.map((Gender gender) {
              return DropdownMenuItem<Gender>(
                value: gender,
                child: Text(gender.value),
              );
            }).toList(),
            onChanged: (Gender? newValue) {
              if (widget.isLoading) return;

              if (newValue != null) {
                setState(() {
                  _data.gender = newValue;
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text('Use Metric Units'),
            value: widget.units == Units.metric,
            onChanged: (bool value) {
              if (widget.isLoading) return;

              widget.onUnitsChanged(value ? Units.metric : Units.imperial);
            },
          ),
          HeightInput(
            initialHeight: _data.height,
            isMetric: widget.units == Units.metric,
            onChanged: (int cm) {
              if (widget.isLoading) return;

              setState(() {
                _data.height = cm;
              });
            },
            onSaved: (int cm) {
              setState(() {
                _data.height = cm;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.isLoading) return;

              if (_formKey.currentState == null) return;

              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onSubmit(
                  name: _data.name,
                  height: _data.height,
                  gender: _data.gender,
                );
              }
            },
            child: widget.isLoading
                ? CircularProgressIndicator()
                : Text(widget.submitButtonLabel),
          ),
        ],
      ),
    );
  }
}
