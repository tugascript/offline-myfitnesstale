import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../editor/create_weight_goal_modal.dart';

class EmptyWeightGoal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const EmptyWeightGoal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => CreateWeightGoalModal(
                  theme: theme,
                  sizes: sizes,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizes.padding * 2,
                horizontal: sizes.padding,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.scale,
                    size: sizes.titleFontSize * 2,
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    'No Weight Goal',
                    style: TextStyle(
                      fontSize: sizes.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[200]
                          : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    'Create a weight goal',
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
