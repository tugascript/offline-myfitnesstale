import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../services/dtos/system_dto.dart';
import '../utilities/theme_generator.dart';
import '../widgets/layout/responsive_scaffold.dart';

class SettingsView extends StatefulWidget {
  static const routeName = "/settings";
  static const name = "settings";

  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Settings",
      showBackButton: true,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // Show success message when settings are updated
          if (!state.isLoading && state.error == null && state.system != null) {
            // This will be triggered when settings are successfully updated
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().loadInitialData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Settings
                _buildAppSettingsCard(state.system, state.isLoading),
                const SizedBox(height: 16),

                // Notification Settings
                _buildNotificationSettingsCard(),
                const SizedBox(height: 16),

                // Data & Backup
                _buildDataBackupCard(),
                const SizedBox(height: 16),

                // About & Support
                _buildAboutSupportCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppSettingsCard(SystemDto? system, bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "App Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Units Setting
            ListTile(
              leading: const Icon(Icons.straighten_outlined),
              title: const Text("Units"),
              subtitle: Text(
                system?.units == Units.imperial
                    ? "Imperial (lbs, ft)"
                    : "Metric (kg, cm)",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getThemePreviewColor(
                          system?.theme ?? ThemeType.system, context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      system?.units == Units.imperial
                          ? Icons.square_foot_outlined
                          : Icons.straighten_outlined,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<Units>(
                    value: system?.units ?? Units.metric,
                    onChanged: isLoading
                        ? null
                        : (Units? newValue) {
                            if (newValue != null) {
                              context
                                  .read<ProfileCubit>()
                                  .updateSystem(units: newValue);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Units changed to ${newValue == Units.imperial ? "Imperial" : "Metric"}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    items: Units.values
                        .map<DropdownMenuItem<Units>>((Units units) {
                      return DropdownMenuItem<Units>(
                        value: units,
                        child: Text(
                            units == Units.imperial ? "Imperial" : "Metric"),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Theme Setting
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text("Theme"),
              subtitle: Text(
                _getThemeDisplayName(system?.theme ?? ThemeType.system),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Theme preview indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getThemePreviewColor(
                          system?.theme ?? ThemeType.system, context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getThemePreviewIcon(system?.theme ?? ThemeType.system),
                      size: 12,
                      color: _getThemePreviewIconColor(
                          system?.theme ?? ThemeType.system, context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<ThemeType>(
                    value: system?.theme ?? ThemeType.system,
                    onChanged: isLoading
                        ? null
                        : (ThemeType? newValue) {
                            if (newValue != null) {
                              context
                                  .read<ProfileCubit>()
                                  .updateSystem(theme: newValue);
                              // Set global theme
                              ThemeGenerator.setGlobalTheme(newValue);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Theme changed to ${_getThemeDisplayName(newValue)}. Hot reload to see changes.'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Hot Reload',
                                    onPressed: () {
                                      // This will trigger a hot reload
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        // Force a rebuild by accessing the theme
                                        Theme.of(context);
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                    items: ThemeType.values
                        .map<DropdownMenuItem<ThemeType>>((ThemeType theme) {
                      return DropdownMenuItem<ThemeType>(
                        value: theme,
                        child: Text(_getThemeDisplayName(theme)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Workout Reminders"),
              subtitle:
                  const Text("Get reminded about your scheduled workouts"),
              value: true, // TODO: Implement actual notification settings
              onChanged: (bool value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? "Workout reminders enabled"
                          : "Workout reminders disabled",
                    ),
                  ),
                );
              },
            ),
            SwitchListTile(
              title: const Text("Progress Updates"),
              subtitle: const Text("Weekly progress summaries"),
              value: false, // TODO: Implement actual notification settings
              onChanged: (bool value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? "Progress updates enabled"
                          : "Progress updates disabled",
                    ),
                  ),
                );
              },
            ),
            SwitchListTile(
              title: const Text("Achievement Notifications"),
              subtitle: const Text("Celebrate your fitness milestones"),
              value: true, // TODO: Implement actual notification settings
              onChanged: (bool value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? "Achievement notifications enabled"
                          : "Achievement notifications disabled",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBackupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data & Backup",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text("Export Data"),
              subtitle: const Text("Download your fitness data as JSON"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data export coming soon!"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text("Import Data"),
              subtitle: const Text("Restore your data from backup"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data import coming soon!"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text("Cloud Sync"),
              subtitle: const Text("Sync data across devices"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cloud sync coming soon!"),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Clear All Data"),
              subtitle: const Text("Permanently delete all your data"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showClearDataDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSupportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About & Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About My Fitness Tale"),
              subtitle: const Text("Version 1.0.0"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & FAQ"),
              subtitle: const Text("Get help with the app"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Help & FAQ coming soon!"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Send Feedback"),
              subtitle: const Text("Report bugs or suggest features"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Feedback system coming soon!"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Policy"),
              subtitle: const Text("How we handle your data"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Privacy policy coming soon!"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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

  Color _getThemePreviewColor(ThemeType theme, BuildContext context) {
    switch (theme) {
      case ThemeType.light:
        return Theme.of(context).colorScheme.surface;
      case ThemeType.dark:
        return Theme.of(context).colorScheme.surface;
      case ThemeType.system:
        return Theme.of(context).colorScheme.surface;
    }
  }

  IconData _getThemePreviewIcon(ThemeType theme) {
    switch (theme) {
      case ThemeType.light:
        return Icons.lightbulb_outline;
      case ThemeType.dark:
        return Icons.dark_mode;
      case ThemeType.system:
        return Icons.settings_brightness;
    }
  }

  Color _getThemePreviewIconColor(ThemeType theme, BuildContext context) {
    switch (theme) {
      case ThemeType.light:
        return Theme.of(context).colorScheme.onSurface;
      case ThemeType.dark:
        return Theme.of(context).colorScheme.onSurface;
      case ThemeType.system:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear All Data"),
          content: const Text(
            "This action will permanently delete all your workout data, progress, and settings. This cannot be undone. Are you sure you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data clear functionality coming soon!"),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Clear Data"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("About My Fitness Tale"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Fitness Tale",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text("Version: 1.0.0"),
              SizedBox(height: 8),
              Text(
                "A comprehensive fitness tracking app designed to help you achieve your fitness goals. Track workouts, monitor progress, and stay motivated on your fitness journey.",
              ),
              SizedBox(height: 16),
              Text(
                "Features:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("• Workout tracking and management"),
              Text("• Progress monitoring"),
              Text("• Exercise database"),
              Text("• Weight tracking"),
              Text("• Workout plans"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
