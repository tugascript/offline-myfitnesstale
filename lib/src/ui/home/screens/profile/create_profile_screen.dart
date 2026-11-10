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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/profile_cubit.dart';
import '../../view_models/states/profile_state.dart';
import '../../../../data/utils/enums.dart';
import '../../../../routing/routes.dart';
import '../../../core/widgets/layout/responsive_scaffold.dart';
import '../../widgets/profile/profile_form.dart';
import '../../widgets/profile/system_form.dart';

class CreateProfileScreen extends StatefulWidget {
  static const name = "create_profile";

  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  Units _units = Units.metric;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Create Profile",
      showBackButton: true,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.isLoading || state.profile == null) {
            return;
          }

          if (state.system == null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => SystemForm(
                ctx: ctx,
                initialUnits: _units,
                initialThemeMode: ThemeType.system,
                initialNotificationsOn: false,
                onSubmit:
                    ({
                      required Units units,
                      required ThemeType themeMode,
                      required bool notificationsOn,
                    }) {
                      context.read<ProfileCubit>().createSystem(
                        units: units,
                        theme: themeMode,
                        notificationsOn: notificationsOn,
                      );
                    },
                isLoading: state.isLoading,
              ),
            );
          }

          context.go(Routes.home.name);
        },
        builder: (context, state) {
          return ProfileForm(
            initialName: "",
            initialHeight: 0,
            initialGender: Gender.male,
            units: Units.metric,
            onUnitsChanged: (unit) {
              setState(() {
                _units = unit;
              });
            },
            onSubmit:
                ({
                  required String name,
                  required int height,
                  required Gender gender,
                }) {
                  context.read<ProfileCubit>().createProfile(
                    name: name,
                    height: height,
                    gender: gender,
                  );
                },
            submitButtonLabel: "Create Profile",
            isLoading: state.isLoading,
          );
        },
      ),
    );
  }
}
