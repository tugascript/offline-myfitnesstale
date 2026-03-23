import 'package:flutter/material.dart';

import '../../../models/utilities.dart';
import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';

class ActiveProgressBar extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final double progress;
  final int totalSets;
  final int currentSet;
  final DateTime startedAt;

  const ActiveProgressBar({
    super.key,
    required this.sizes,
    required this.theme,
    required this.progress,
    required this.totalSets,
    required this.currentSet,
    required this.startedAt,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    final greyColor = theme.colorScheme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: halfSpacing),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: sizes.fontSize / 2,
            ),
            SizedBox(height: halfSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: sizes.fontSize * 1.2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      ' Set $currentSet of $totalSets',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_outlined,
                      size: sizes.fontSize * 1.2,
                      color: greyColor,
                    ),
                    Text(
                      ' ${Formatters.formatDuration(DateUtilities.getNowUtcUnix() - DateUtilities.getDateUnix(startedAt))}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
