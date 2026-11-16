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

import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/profile/dtos/profile_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/converters.dart';
import 'profile_info_row.dart';

class ProfileInfoDisplay extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ProfileDto profile;
  final SystemDto system;

  const ProfileInfoDisplay({
    super.key,
    required this.sizes,
    required this.profile,
    required this.system,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ThemedColors.themedGrey.fromBrightness(theme.brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileInfoRow(
          name: "Name",
          value: profile.name,
          sizes: sizes,
          titleColor: color,
        ),
        SizedBox(height: sizes.halfSpacing),
        ProfileInfoRow(
          name: "Height",
          value: system.units == Units.metric
              ? "${profile.height}cm"
              : Converters.formatImperialHeight(profile.height),
          sizes: sizes,
          titleColor: color,
        ),
        SizedBox(height: sizes.halfSpacing),
        ProfileInfoRow(
          name: "Gender",
          value: profile.gender.name,
          sizes: sizes,
          titleColor: color,
        ),
        SizedBox(height: sizes.halfSpacing),
        ProfileInfoRow(
          name: "Birthdate",
          value: Converters.formatDate(
            profile.birthdate,
            imperial: system.units == Units.imperial,
          ),
          sizes: sizes,
          titleColor: color,
        ),
      ],
    );
  }
}
