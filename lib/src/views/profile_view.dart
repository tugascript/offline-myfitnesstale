import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../services/dtos/profile_dto.dart';
import '../services/dtos/system_dto.dart';
import '../utilities/converters.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/profile/height_input.dart';
import 'settings_view.dart';

class ProfileView extends StatefulWidget {
  static const routeName = "/profile";
  static const name = "profile";

  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _height = 0;
  Gender _selectedGender = Gender.male;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing(ProfileDto profile) {
    setState(() {
      _isEditing = true;
      _nameController.text = profile.name;
      _selectedGender = profile.gender;
      _height = profile.height;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
            name: _nameController.text,
            height: _height,
            gender: _selectedGender,
          );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Profile",
      body: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          // Only rebuild when the profile data changes, not on minor UI updates.
          return previous.profile != current.profile ||
              previous.isLoading != current.isLoading ||
              previous.error != current.error;
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
                ],
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
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
                // Profile Header
                _buildProfileHeader(profile, state.system),
                const SizedBox(height: 24),

                // Profile Form
                if (_isEditing) _buildEditForm(profile, state.system),
                if (!_isEditing) _buildProfileInfo(profile, state.system),

                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(state.system),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileDto profile, SystemDto? system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${system?.units == Units.metric ? "${profile.height}cm" : Converters.formatImperialHeight(profile.height)} • ${profile.gender.name}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isEditing)
              IconButton(
                onPressed: () => _startEditing(profile),
                icon: const Icon(Icons.edit),
                tooltip: "Edit Profile",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ProfileDto profile, SystemDto? system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Name", profile.name),
            _buildInfoRow(
                "Height",
                system?.units == Units.metric
                    ? "${profile.height}cm"
                    : Converters.formatImperialHeight(profile.height)),
            _buildInfoRow("Gender", profile.gender.name),
            _buildInfoRow("Birthdate",
                _formatDate(profile.birthdate.millisecondsSinceEpoch ~/ 1000)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(ProfileDto profile, SystemDto? system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
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
              const SizedBox(height: 16),
              HeightInput(
                initialHeight: profile.height,
                isMetric: system?.units == Units.metric,
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
              const SizedBox(height: 16),
              DropdownButtonFormField<Gender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
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
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEditing,
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(SystemDto? system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("App Settings"),
              subtitle: Text(
                system != null
                    ? "${system.units.name} units • ${system.theme.name} theme"
                    : "Not configured",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push(SettingsView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              subtitle: const Text("Configure app notifications"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Notification settings coming soon!"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text("Data & Backup"),
              subtitle: const Text("Export/import your data"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data management coming soon!"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day}/${date.month}/${date.year}";
  }
}
