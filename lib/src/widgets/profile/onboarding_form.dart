import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cubits/profile_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/profile/onboarding_sizes.dart';
import '../layout/sharp_switch_title.dart';
import 'height_input.dart';

final class _FormData {
  Units units;
  ThemeType themeMode;
  String name;
  int height;
  Gender gender;
  DateTime birthday;
  bool preLoadWorkouts;
  bool notificationsOn;

  _FormData({
    required this.units,
    required this.themeMode,
    required this.name,
    required this.height,
    required this.gender,
    required this.birthday,
    required this.preLoadWorkouts,
    required this.notificationsOn,
  });
}

class OnboardingForm extends StatefulWidget {
  final OnboardingSizesList sizes;
  final Units initialUnits;
  final ThemeType initialThemeMode;
  final String initialName;
  final int initialHeight;
  final Gender initialGender;
  final DateTime initialBirthday;
  final bool initialPreLoadWorkouts;
  final bool initialNotificationsOn;
  final void Function({
    required Units units,
    required ThemeType theme,
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthday,
    required bool preLoadWorkouts,
    required bool notificationsOn,
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
    required this.initialBirthday,
    required this.initialPreLoadWorkouts,
    required this.initialNotificationsOn,
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
  final _birthdayController = TextEditingController();
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
      birthday: widget.initialBirthday,
      preLoadWorkouts: widget.initialPreLoadWorkouts,
      notificationsOn: widget.initialNotificationsOn,
    );
    _birthdayController.text =
        "${_data.birthday.day}/${_data.birthday.month}/${_data.birthday.year}";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
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
                      cubit.changeSystem(
                        theme: _data.themeMode,
                        units: value,
                        notificationsOn: _data.notificationsOn,
                      );
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
                      cubit.changeSystem(
                        theme: value,
                        units: _data.units,
                        notificationsOn: _data.notificationsOn,
                      );
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
              SizedBox(height: widget.sizes.breaks),
              SharpSwitchTitle(
                contentPadding: EdgeInsets.zero,
                title: 'Allow Notifications',
                value: _data.notificationsOn,
                thumbSize: widget.sizes.subtitleFontSize,
                switchPadding: EdgeInsets.all(widget.sizes.breaks / 4),
                onChanged: (bool value) async {
                  if (value) {
                    final status = await Permission.notification.request();
                    if (status.isGranted) {
                      setState(() {
                        _data.notificationsOn = true;
                      });
                    } else {
                      setState(() {
                        _data.notificationsOn = false;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Permission denied. Please enable notifications in settings.'),
                          ),
                        );
                      }
                    }
                  } else {
                    setState(() {
                      _data.notificationsOn = false;
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
                textInputAction: TextInputAction.next,
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
                onFieldSubmitted: (_) {
                  // Move focus to next field instead of submitting form
                  FocusScope.of(context).nextFocus();
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
              TextFormField(
                controller: _birthdayController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _data.birthday,
                    firstDate: DateTime.now().subtract(
                      Duration(days: (365.25 * 125).floor()),
                    ),
                    lastDate: DateTime.now().subtract(
                      Duration(days: (365.25 * 16).floor()),
                    ),
                  );
                  if (picked != null && picked != _data.birthday) {
                    setState(() {
                      _data.birthday = picked;
                      _birthdayController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
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
                    child: Text(
                      "${gender.name[0].toUpperCase()}${gender.name.substring(1)}",
                    ),
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
                key: const ValueKey('onboarding-preload-workouts'),
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
          SizedBox(height: widget.sizes.breaks * 2),
          ElevatedButton(
            key: const ValueKey('onboarding-submit'),
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
                    birthday: _data.birthday,
                    preLoadWorkouts: _data.preLoadWorkouts,
                    notificationsOn: _data.notificationsOn,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: widget.sizes.padding / 2),
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
