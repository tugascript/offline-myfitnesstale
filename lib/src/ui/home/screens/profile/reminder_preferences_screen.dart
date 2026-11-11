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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../view_models/profile_cubit.dart';
import '../../view_models/states/profile_state.dart';
import '../../widgets/profile/reminders_settings_config.dart';

class ReminderPreferencesScreen extends StatelessWidget {
  const ReminderPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return AppScaffold(
      title: 'Reminder Preferences',
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.remindersConfig == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          final remindersConfig = state.remindersConfig;
          if (profile == null || remindersConfig == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: const Text(
                  'Reminder preferences are unavailable until a profile has been created.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(sizes.viewPadding),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(sizes.padding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: sizes.spacing),
                      const Expanded(
                        child: Text(
                          'These preferences are saved on this device. Notification delivery is not scheduled in this build.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sizes.spacing),
              Card(
                child: RemindersSettingsConfig(
                  remindersConfig: remindersConfig,
                  isLoading: state.isLoading,
                  profileId: profile.id,
                  sizes: sizes,
                  theme: theme,
                  isDarkTheme: isDarkTheme,
                  initiallyExpanded: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
