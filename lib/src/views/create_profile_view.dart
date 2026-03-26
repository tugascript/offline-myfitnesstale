import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/profile/profile_form.dart';
import '../widgets/profile/system_form.dart';
import 'home/home_view.dart';

class CreateProfileView extends StatefulWidget {
  static const routeName = "/setup/create-profile";
  static const name = "create_profile";

  const CreateProfileView({super.key});

  @override
  State<CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
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
                onSubmit: ({
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

          context.go(HomeView.routeName);
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
            onSubmit: ({
              required String name,
              required int height,
              required Gender gender,
            }) {
              context
                  .read<ProfileCubit>()
                  .createProfile(name: name, height: height, gender: gender);
            },
            submitButtonLabel: "Create Profile",
            isLoading: state.isLoading,
          );
        },
      ),
    );
  }
}
