import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'muscle_badge.dart';

class MusclesWrap extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final Widget? leading;
  final String title;
  final Set<Muscle> muscles;

  const MusclesWrap({
    super.key,
    required this.theme,
    required this.sizes,
    this.leading,
    required this.title,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) leading!,
            Flexible(
              child: Text(
                leading != null ? " $title" : title,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: sizes.spacing / 2,
        ),
        Wrap(
          spacing: sizes.spacing / 4,
          children: muscles.map((m) {
            return MuscleBadge(
              muscle: m,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}
