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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/layout/sharp_switch_title.dart';
import '../../../core/widgets/layout/titled_section.dart';
import '../../view_models/profile_cubit.dart';
import './height_input.dart';

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
  final DataDisplaySizesList sizes;
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
  })
  onSubmit;
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
    _nameController.text = _data.name;
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
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TitledSection(
            sizes: widget.sizes,
            title: "Settings",
            icon: Icons.settings,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdown<Units>(
                  theme: theme,
                  isLoading: widget.isLoading,
                  value: _data.units,
                  emptyLabel: '',
                  showEmptyValue: false,
                  labelText: 'Units',
                  items: Units.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  prefixIcon: Icon(
                    Icons.straighten,
                    size: widget.sizes.iconFontSize,
                  ),
                  labelBuilder: (units) => units == Units.imperial
                      ? 'Imperial (lbs, ft)'
                      : 'Metric (kg, cm)',
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
                SizedBox(height: widget.sizes.halfSpacing),
                AppDropdown<ThemeType>(
                  theme: theme,
                  isLoading: widget.isLoading,
                  value: _data.themeMode,
                  emptyLabel: '',
                  showEmptyValue: false,
                  labelText: 'Theme',
                  items: ThemeType.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  prefixIcon: Icon(
                    Icons.palette,
                    size: widget.sizes.iconFontSize,
                  ),
                  labelBuilder: _getThemeDisplayName,
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
                SizedBox(height: widget.sizes.halfSpacing),
                SharpSwitchTitle(
                  contentPadding: EdgeInsets.zero,
                  title: 'Allow Notifications',
                  titleStyle: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                  value: _data.notificationsOn,
                  thumbSize: widget.sizes.subtitleFontSize,
                  switchPadding: EdgeInsets.all(widget.sizes.quarterSpacing),
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
                                'Permission denied. Please enable notifications in settings.',
                              ),
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
          ),
          SizedBox(height: widget.sizes.betweenSpacing),
          TitledSection(
            sizes: widget.sizes,
            title: 'Profile Information',
            icon: Icons.person,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextFormField(
                  theme: theme,
                  isLoading: widget.isLoading,
                  controller: _nameController,
                  labelText: 'Name',
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    size: widget.sizes.iconFontSize,
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
                  onFieldSubmitted: (_) {
                    // Move focus to next field instead of submitting form
                    FocusScope.of(context).nextFocus();
                  },
                ),
                SizedBox(height: widget.sizes.halfSpacing),
                HeightInput(
                  theme: theme,
                  sizes: widget.sizes,
                  isLoading: widget.isLoading,
                  initialHeight: _data.height,
                  isMetric: _data.units == Units.metric,
                  onChanged: (int cm) {
                    if (widget.isLoading) return;

                    setState(() {
                      _data.height = cm;
                    });
                  },
                  onSaved: (int cm) {
                    if (widget.isLoading) return;

                    setState(() {
                      _data.height = cm;
                    });
                  },
                ),
                SizedBox(height: widget.sizes.halfSpacing),
                AppTextFormField(
                  theme: theme,
                  isLoading: widget.isLoading,
                  controller: _birthdayController,
                  labelText: 'Birthday',
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  readOnly: true,
                  prefixIcon: Icon(
                    Icons.cake_outlined,
                    size: widget.sizes.iconFontSize,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    size: widget.sizes.iconFontSize,
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
                SizedBox(height: widget.sizes.halfSpacing),
                AppDropdown<Gender>(
                  theme: theme,
                  isLoading: widget.isLoading,
                  value: _data.gender,
                  emptyLabel: '',
                  showEmptyValue: false,
                  labelText: 'Gender',
                  items: Gender.values,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  prefixIcon: Icon(
                    Icons.people_outline,
                    size: widget.sizes.iconFontSize,
                  ),
                  labelBuilder: (gender) =>
                      "${gender.name[0].toUpperCase()}${gender.name.substring(1)}",
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _data.gender = value;
                      });
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      setState(() {
                        _data.gender = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: widget.sizes.betweenSpacing),
          TitledSection(
            sizes: widget.sizes,
            title: 'Initial Data',
            icon: Icons.fitness_center,
            child: SharpSwitchTitle(
              key: const ValueKey('onboarding-preload-workouts'),
              contentPadding: EdgeInsets.zero,
              title: 'Pre-built Workout & Plans',
              titleStyle: TextStyle(fontSize: widget.sizes.subtitleFontSize),
              value: _data.preLoadWorkouts,
              thumbSize: widget.sizes.subtitleFontSize,
              switchPadding: EdgeInsets.all(widget.sizes.quarterSpacing),
              enabled: !widget.isLoading,
              onChanged: (checked) {
                setState(() {
                  _data.preLoadWorkouts = checked;
                });
              },
            ),
          ),
          SizedBox(height: widget.sizes.betweenSpacing),
          AppElevatedButton(
            key: const ValueKey('onboarding-submit'),
            theme: theme,
            isLoading: widget.isLoading,
            sizes: widget.sizes,
            icon: Icons.check,
            label: widget.submitButtonLabel,
            onPressed: () {
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
            },
          ),
        ],
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
