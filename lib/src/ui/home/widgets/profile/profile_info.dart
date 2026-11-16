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

import '../../../../data/repositories/profile/dtos/profile_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/titled_section.dart';
import '../../view_models/profile_cubit.dart';
import 'profile_edit_form.dart';
import 'profile_header.dart';
import 'profile_info_display.dart';

class ProfileInfo extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ProfileDto profile;
  final SystemDto system;
  final bool isLoading;

  const ProfileInfo({
    super.key,
    required this.sizes,
    required this.profile,
    required this.system,
    required this.isLoading,
  });

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  bool _isEditing = false;

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveProfile({
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthdate,
  }) async {
    final cubit = context.read<ProfileCubit>();
    if (cubit.state.isLoading) return;

    final saved = await cubit.updateProfile(
      name: name,
      height: height,
      gender: gender,
      birthday: birthdate,
    );
    if (mounted && saved) _cancelEditing();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = widget.sizes;
    final profile = widget.profile;
    final system = widget.system;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeader(
          profile: profile,
          system: system,
          sizes: sizes,
          isEditing: _isEditing,
          editOnPress: _startEditing,
        ),
        SizedBox(height: sizes.betweenSpacing),
        TitledSection(
          sizes: sizes,
          title: "Profile Information",
          child: _isEditing
              ? ProfileEditForm(
                  profile: profile,
                  system: system,
                  sizes: sizes,
                  isLoading: widget.isLoading,
                  onCancel: _cancelEditing,
                  onSave: _saveProfile,
                )
              : ProfileInfoDisplay(
                  sizes: sizes,
                  profile: profile,
                  system: system,
                ),
        ),
      ],
    );
  }
}
