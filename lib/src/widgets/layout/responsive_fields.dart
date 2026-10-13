import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

/// Keeps fields usable when the available width or text scale changes.
class ResponsiveFields extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final List<Widget> children;

  const ResponsiveFields(
      {super.key, required this.sizes, required this.children});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (children.isEmpty) return const SizedBox.shrink();
        final fieldWidth =
            MediaQuery.textScalerOf(context).scale(sizes.formFieldMinWidth);
        final columns = ((constraints.maxWidth + sizes.spacing) /
                (fieldWidth + sizes.spacing))
            .floor()
            .clamp(1, children.length);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var start = 0;
                  start < children.length;
                  start += columns) ...[
                if (start > 0) SizedBox(height: sizes.inputSpacing),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (var index = start;
                      index < start + columns && index < children.length;
                      index++) ...[
                    if (index > start) SizedBox(width: sizes.spacing),
                    Expanded(child: children[index]),
                  ],
                ]),
              ],
            ]);
      });
}
