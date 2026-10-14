import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';

/// Lets carousel cards stretch while standalone cards keep their heading.
class ActivePlanFrame extends StatelessWidget {
  final String title;
  final bool showTitle;
  final DataDisplaySizesList sizes;
  final Widget child;

  const ActivePlanFrame({
    super.key,
    required this.title,
    required this.showTitle,
    required this.sizes,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTitle) return Column(children: [Expanded(child: child)]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        child,
      ],
    );
  }
}
