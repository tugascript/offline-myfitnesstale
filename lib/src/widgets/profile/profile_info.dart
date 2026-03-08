import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/profile_dto.dart';
import '../../services/dtos/system_dto.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';

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
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
