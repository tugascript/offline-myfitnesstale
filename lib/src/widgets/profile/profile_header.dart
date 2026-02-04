import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../../services/dtos/profile_dto.dart';
import '../../services/dtos/system_dto.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileDto profile;
  final SystemDto? system;
  final DataDisplaySizesList sizes;
  final bool isEditing;
  final void Function() editOnPress;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.system,
    required this.sizes,
    required this.isEditing,
    required this.editOnPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final grey = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: sizes.titleFountSize * 1.65,
              backgroundColor:
                  theme.primaryColor.withValues(alpha: isDarkTheme ? 0.2 : 0.1),
              child: Text(
                _getNameInitials(profile.name),
                style: TextStyle(
                  fontSize: sizes.titleFountSize,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            SizedBox(width: sizes.spacing * 2.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: sizes.titleFountSize,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sizes.spacing / 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.height,
                        size: sizes.subtitleFontSize,
                        color: grey,
                      ),
                      Text(
                        " ${system?.units == Units.metric ? "${profile.height}cm" : Converters.formatImperialHeight(profile.height)} • ",
                        style: TextStyle(
                          fontSize: sizes.subtitleFontSize,
                          color: grey,
                        ),
                      ),
                      Icon(
                        _getGenderIcon(profile.gender),
                        size: sizes.subtitleFontSize,
                        color: grey,
                      ),
                      Text(
                        " ${EnumDisplayNames.getGenderDisplayName(profile.gender)}",
                        style: TextStyle(
                          fontSize: sizes.subtitleFontSize,
                          color: grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isEditing)
              IconButton(
                onPressed: editOnPress,
                icon: Icon(
                  Icons.edit,
                  size: sizes.titleFountSize,
                ),
                color: theme.primaryColor,
                tooltip: "Edit Profile",
              ),
          ],
        ),
      ),
    );
  }

  IconData _getGenderIcon(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      case Gender.other:
        return Icons.transgender;
      case null:
        return Icons.person;
    }
  }

  String _getNameInitials(String name) {
    final names = name.trim().split(RegExp(r'\s+'));
    final len = names.length;

    if (len == 1) {
      return name.length > 1
          ? '${name[0].toUpperCase()}${name[1].toUpperCase()}'
          : name.toUpperCase();
    }

    return '${names[0][0].toUpperCase()}${names[len - 1][0].toUpperCase()}';
  }
}
