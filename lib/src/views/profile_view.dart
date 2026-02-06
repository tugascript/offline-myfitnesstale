import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../services/dtos/profile_dto.dart';
import '../services/dtos/system_dto.dart';
import '../utilities/sizes/data_display_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/profile/height_input.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_info.dart';
import '../widgets/profile/settings_config.dart';

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
    final breakPoints = BreakPoint.fromContext(context);
    final sizes =
        DataDisplaySizes.getWorkoutDetailSizes(breakPoints.screenSize);

    return AppScaffold(
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
          final system = state.system;
          final remindersConfig = state.remindersConfig;
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
                ProfileHeader(
                  profile: profile,
                  system: system,
                  sizes: sizes,
                  isEditing: _isEditing,
                  editOnPress: () => _startEditing(profile),
                ),
                SizedBox(height: sizes.spacing * 2),

                // Profile Form
                if (_isEditing) _buildEditForm(profile, system),
                if (!_isEditing)
                  ProfileInfo(
                    sizes: sizes,
                    profile: profile,
                    system: system,
                  ),

                SizedBox(height: sizes.spacing * 2),

                // Settings Section
                SettingsConfig(
                  profileId: profile.id,
                  isLoading: state.isLoading,
                  sizes: sizes,
                  system: system,
                  remindersConfig: remindersConfig,
                ),
              ],
            ),
          );
        },
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
}
