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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../../core/widgets/layout/responsive_scaffold.dart';
import '../../view_models/profile_cubit.dart';
import '../../view_models/states/profile_state.dart';
import '../../widgets/profile/profile_info.dart';
import '../../widgets/profile/settings_config.dart';

class ProfileScreen extends StatelessWidget {
  static const name = "profile";

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoints.screenSize);

    return ResponsiveScaffold(
      title: "Profile",
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading && current.error != null,
          listener: (context, state) {
            final error = state.error;
            if (error == null ||
                state.profile == null ||
                state.system == null ||
                state.remindersConfig == null) {
              return;
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(error.description)));
          },
          buildWhen: (previous, current) {
            // Only rebuild when the profile data changes, not on minor UI updates.
            return previous.profile != current.profile ||
                previous.system != current.system ||
                previous.remindersConfig != current.remindersConfig ||
                previous.isLoading != current.isLoading ||
                previous.error != current.error;
          },
          builder: (context, state) {
            if (state.isLoading &&
                (state.profile == null ||
                    state.system == null ||
                    state.remindersConfig == null)) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = state.profile;
            final system = state.system;
            final remindersConfig = state.remindersConfig;

            if (state.error != null &&
                (profile == null ||
                    system == null ||
                    remindersConfig == null)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (profile == null || system == null || remindersConfig == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No Profile Found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Create a profile to get started",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileInfo(
                  sizes: sizes,
                  profile: profile,
                  system: system,
                  isLoading: state.isLoading,
                ),
                SizedBox(height: sizes.betweenSpacing),
                SettingsConfig(
                  profileId: profile.id,
                  isLoading: state.isLoading,
                  sizes: sizes,
                  system: system,
                  remindersConfig: remindersConfig,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
