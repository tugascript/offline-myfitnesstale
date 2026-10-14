import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import 'quick_action_category.dart';

class QuickActionCategoryCard extends StatelessWidget {
  final QuickActionCategory category;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onTap;

  const QuickActionCategoryCard({
    super.key,
    required this.category,
    required this.sizes,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: sizes.elevation,
    shape: const BeveledRectangleBorder(),
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            ExcludeSemantics(
              child: Text(
                category.emoji,
                style: TextStyle(fontSize: sizes.buttonIconSize),
              ),
            ),
            SizedBox(height: sizes.spacing / 2),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: sizes.spacing / 6),
            Text(
              category.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizes.fontSize,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
