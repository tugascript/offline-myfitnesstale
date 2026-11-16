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

import '../../../../data/repositories/profile/dtos/profile_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/mutation_button.dart';
import 'height_input.dart';

class ProfileEditForm extends StatefulWidget {
  final ProfileDto profile;
  final SystemDto system;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function({
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthdate,
  })
  onSave;

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.system,
    required this.sizes,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthdateController;
  late int _height;
  late Gender _selectedGender;
  late DateTime _birthdate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _height = widget.profile.height;
    _selectedGender = widget.profile.gender;
    _birthdate = widget.profile.birthdate;
    _birthdateController = TextEditingController(
      text: "${_birthdate.day}/${_birthdate.month}/${_birthdate.year}",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        name: _nameController.text,
        height: _height,
        gender: _selectedGender,
        birthdate: _birthdate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = widget.sizes;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !widget.isLoading,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your name";
              }
              return null;
            },
          ),
          SizedBox(height: sizes.spacing),
          HeightInput(
            theme: theme,
            sizes: sizes,
            isLoading: widget.isLoading,
            initialHeight: widget.profile.height,
            isMetric: widget.system.units == Units.metric,
            onChanged: (int cm) {
              setState(() {
                _height = cm;
              });
            },
            onSaved: (int cm) {
              setState(() {
                _height = cm;
              });
            },
          ),
          SizedBox(height: sizes.spacing),
          DropdownButtonFormField<Gender>(
            enabled: !widget.isLoading,
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(),
            ),
            items: Gender.values.map((gender) {
              return DropdownMenuItem(value: gender, child: Text(gender.name));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGender = value;
                });
              }
            },
          ),
          SizedBox(height: sizes.spacing),
          TextFormField(
            controller: _birthdateController,
            enabled: !widget.isLoading,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Birthdate",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake_outlined),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _birthdate,
                firstDate: DateTime.now().subtract(
                  Duration(days: (365.25 * 125).floor()),
                ),
                lastDate: DateTime.now().subtract(
                  Duration(days: (365.25 * 16).floor()),
                ),
              );
              if (mounted && picked != null && picked != _birthdate) {
                setState(() {
                  _birthdate = picked;
                  _birthdateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                });
              }
            },
          ),
          SizedBox(height: sizes.spacing * 1.5),
          LayoutBuilder(
            builder: (context, constraints) {
              final cancel = MutationButton(
                onPressed: widget.onCancel,
                theme: theme,
                sizes: sizes,
                isLoading: widget.isLoading,
                label: "Cancel",
                icon: Icons.close,
              );
              final save = AppElevatedButton(
                onPressed: _save,
                theme: Theme.of(context),
                isLoading: widget.isLoading,
                sizes: sizes,
                label: "Save",
                icon: Icons.save,
              );
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    cancel,
                    SizedBox(height: sizes.spacing / 2),
                    save,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: cancel),
                  SizedBox(width: sizes.spacing),
                  Expanded(child: save),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
