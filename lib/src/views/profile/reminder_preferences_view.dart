import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/profile/reminders_settings_config.dart';

class ReminderPreferencesView extends StatelessWidget {
  static const routeName = '/settings/reminders';

  const ReminderPreferencesView({super.key});

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
