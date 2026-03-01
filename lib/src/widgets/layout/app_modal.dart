import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class AppModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Widget child;

  const AppModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      insetPadding: EdgeInsets.all(sizes.margins),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: sizes.padding * 2,
            horizontal: sizes.padding,
          ),
          child: child,
        ),
      ),
    );
  }
}
