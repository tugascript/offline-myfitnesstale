import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/sizes/profile/onboarding_sizes.dart';
import 'height_input.dart';

final class _FormData {
  Units units;
  ThemeType themeMode;
  String name;
  int height;
  Gender gender;
  bool preLoadWorkouts;

  _FormData({
    required this.units,
    required this.themeMode,
    required this.name,
    required this.height,
    required this.gender,
    required this.preLoadWorkouts,
  });
}

class OnboardingForm extends StatefulWidget {
  final OnboardingSizesList sizes;
  final Units initialUnits;
  final ThemeType initialThemeMode;
  final String initialName;
  final int initialHeight;
  final Gender initialGender;
  final bool initialPreLoadWorkouts;
  final void Function({
    required Units units,
    required ThemeType theme,
    required String name,
    required int height,
    required Gender gender,
    required bool preLoadWorkouts,
  }) onSubmit;
  final String submitButtonLabel;
  final bool isLoading;

  const OnboardingForm({
    super.key,
    required this.sizes,
    required this.initialUnits,
    required this.initialThemeMode,
    required this.initialName,
    required this.initialHeight,
    required this.initialGender,
    required this.initialPreLoadWorkouts,
    required this.onSubmit,
    required this.submitButtonLabel,
    required this.isLoading,
  });

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      units: widget.initialUnits,
      themeMode: widget.initialThemeMode,
      name: widget.initialName,
      height: widget.initialHeight,
      gender: widget.initialGender,
      preLoadWorkouts: widget.initialPreLoadWorkouts,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            sizes: widget.sizes,
            title: 'App Settings',
            icon: Icons.settings,
            children: [
              DropdownButtonFormField<Units>(
                initialValue: _data.units,
                decoration: const InputDecoration(
                  labelText: 'Units',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: Units.values.map((units) {
                  return DropdownMenuItem(
                    value: units,
                    child: Text(
                      units == Units.imperial
                          ? 'Imperial (lbs, ft)'
                          : 'Metric (kg, cm)',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _data.units = value;
                    });
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.units = value;
                    });
                  }
                },
              ),
              SizedBox(height: widget.sizes.breaks),
              DropdownButtonFormField<ThemeType>(
                initialValue: _data.themeMode,
                decoration: const InputDecoration(
                  labelText: 'Theme',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                items: ThemeType.values.map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(_getThemeDisplayName(theme)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _data.themeMode = value;
                    });
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.themeMode = value;
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: widget.sizes.breaks * 2),
          _Section(
            sizes: widget.sizes,
            title: 'Profile Information',
            icon: Icons.person,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
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
              ),
              SizedBox(height: widget.sizes.formBreaks),
              HeightInput(
                initialHeight: _data.height,
                isMetric: _data.units == Units.metric,
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
              SizedBox(height: widget.sizes.formBreaks),
              DropdownButtonFormField<Gender>(
                initialValue: _data.gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people_outline),
                ),
                items: Gender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _data.gender = value;
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: widget.sizes.breaks * 2),
          _Section(
            sizes: widget.sizes,
            title: 'Initial Data',
            icon: Icons.fitness_center,
            children: [
              CheckboxListTile(
                value: _data.preLoadWorkouts,
                onChanged: (checked) {
                  if (checked != null) {
                    setState(() {
                      _data.preLoadWorkouts = checked;
                    });
                  }
                },
                title: const Text("Pre-built Workout & Plans"),
              ),
            ],
          ),
          SizedBox(height: widget.sizes.breaks * 4),
          ElevatedButton(
            onPressed: () {
              if (!widget.isLoading) {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(
                    units: _data.units,
                    theme: _data.themeMode,
                    name: _nameController.text,
                    gender: _data.gender,
                    height: _data.height,
                    preLoadWorkouts: _data.preLoadWorkouts,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: widget.sizes.padding / 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.sizes.breaks),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: widget.sizes.breaks * 1.75,
                    width: widget.sizes.breaks * 1.75,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.submitButtonLabel,
                    style: TextStyle(
                      fontSize: widget.sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final OnboardingSizesList sizes;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.sizes,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding / 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                SizedBox(width: sizes.breaks),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.breaks / 0.6),
            ...children,
          ],
        ),
      ),
    );
  }
}

String _getThemeDisplayName(ThemeType theme) {
  switch (theme) {
    case ThemeType.light:
      return "Light";
    case ThemeType.dark:
      return "Dark";
    case ThemeType.system:
      return "System";
  }
}
