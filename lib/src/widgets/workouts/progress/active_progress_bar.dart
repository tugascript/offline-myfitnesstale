import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';

class ActiveProgressBar extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final double progress;
  final int totalSets;
  final int currentSet;

  const ActiveProgressBar({
    super.key,
    required this.sizes,
    required this.theme,
    required this.progress,
    required this.totalSets,
    required this.currentSet,
  });

  @override
  State<ActiveProgressBar> createState() => _ActiveProgressBarState();
}

class _ActiveProgressBarState extends State<ActiveProgressBar> {
  int _elapsedSeconds = 0;
  late final Timer? _workoutTimer;

  @override
  void initState() {
    super.initState();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (context.mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final halfSpacing = widget.sizes.spacing / 2;
    final greyColor = widget.theme.colorScheme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${(widget.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: halfSpacing),
            LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
              minHeight: widget.sizes.fontSize / 2,
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
                      size: widget.sizes.fontSize * 1.2,
                      color: widget.theme.colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      ' Set ${widget.currentSet} of ${widget.totalSets}',
                      style: TextStyle(
                        fontSize: widget.sizes.fontSize,
                        color: widget.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _elapsedSeconds % 2 == 0
                          ? Icons.hourglass_top_outlined
                          : Icons.hourglass_bottom_outlined,
                      size: widget.sizes.fontSize * 1.2,
                      color: greyColor,
                    ),
                    Text(
                      ' ${Formatters.formatTimer(_elapsedSeconds)}',
                      style: TextStyle(
                        fontSize: widget.sizes.fontSize,
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
