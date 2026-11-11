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

import '../../../../data/repositories/profile/dtos/profile_dto.dart';
import '../../../../data/repositories/profile/dtos/system_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';

class ProfileInfo extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ProfileDto profile;
  final SystemDto system;

  const ProfileInfo({
    super.key,
    required this.sizes,
    required this.profile,
    required this.system,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Information",
              style: TextStyle(
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: sizes.padding, // Spacing between title and info rows
            ),
            _InfoRow(
              name: "Name",
              isDarkTheme: isDarkTheme,
              value: profile.name,
              padding: sizes.padding,
              fontSize: sizes.subtitleFontSize,
              nameWidth: sizes.subtitleFontSize * 7,
            ),
            _InfoRow(
              name: "Height",
              isDarkTheme: isDarkTheme,
              value: system.units == Units.metric
                  ? "${profile.height}cm"
                  : Converters.formatImperialHeight(profile.height),
              padding: sizes.padding,
              fontSize: sizes.subtitleFontSize,
              nameWidth: sizes.subtitleFontSize * 7,
            ),
            _InfoRow(
              name: "Gender",
              isDarkTheme: isDarkTheme,
              value: profile.gender.name,
              padding: sizes.padding,
              fontSize: sizes.subtitleFontSize,
              nameWidth: sizes.subtitleFontSize * 7,
            ),
            _InfoRow(
              name: "Birthdate",
              isDarkTheme: isDarkTheme,
              value: Converters.formatDate(
                profile.birthdate,
                imperial: system.units == Units.imperial,
              ),
              padding: sizes.padding,
              fontSize: sizes.subtitleFontSize,
              nameWidth: sizes.subtitleFontSize * 7,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String name;
  final bool isDarkTheme;
  final String value;
  final double padding;
  final double fontSize;
  final double nameWidth;

  const _InfoRow({
    required this.name,
    required this.isDarkTheme,
    required this.value,
    required this.padding,
    required this.fontSize,
    required this.nameWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: nameWidth,
            child: Text(
              name,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }
}
