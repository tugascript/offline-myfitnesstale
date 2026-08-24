import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';

class ActiveRestTimer extends StatefulWidget {
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final int recommendedSecs;
  final int? maxSecs;
  final void Function(int) onNext;

  const ActiveRestTimer({
    super.key,
    required this.breakPoint,
    required this.sizes,
    required this.theme,
    required this.recommendedSecs,
    this.maxSecs,
    required this.onNext,
  });

  @override
  State<ActiveRestTimer> createState() => _ActiveRestTimerState();
}

/// Logical size for the progress ring before [FittedBox] scales it; uniform
/// scale keeps the indicator circular regardless of parent layout quirks.
const double _kProgressRingBase = 100;

class _ActiveRestTimerState extends State<ActiveRestTimer> {
  int _elapsedSeconds = 0;
  late final Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  double get _progress {
    final value = _elapsedSeconds / (widget.maxSecs ?? widget.recommendedSecs);
    return value > 1.0 ? 1.0 : value;
  }

  Color get _progressColor {
    final isDarkTheme = widget.theme.colorScheme.brightness == Brightness.dark;
    final greenColor =
        isDarkTheme ? Colors.green.shade400 : Colors.green.shade600;
    final yellowColor =
        isDarkTheme ? Colors.yellow.shade400 : Colors.yellow.shade600;
    final redColor = isDarkTheme ? Colors.red.shade400 : Colors.red.shade600;

    if (widget.maxSecs == null) {
      if (_progress >= 1.0) {
        return redColor;
      } else if (_progress >= 0.8) {
        return yellowColor;
      } else {
        return greenColor;
      }
    }

    if (_elapsedSeconds >= widget.maxSecs!) {
      return redColor;
    } else if (_elapsedSeconds >= widget.recommendedSecs) {
      return yellowColor;
    } else {
      return greenColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final restSize = widget.sizes.fontSize * 4 + widget.sizes.padding * 7;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(widget.sizes.padding),
          child: SizedBox.square(
            dimension: restSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox.square(
                      dimension: _kProgressRingBase,
                      child: CircularProgressIndicator(
                        value: _progress,
                        backgroundColor: widget.theme.colorScheme.onSurface
                            .withValues(alpha: 0.1),
                        strokeWidth: ((widget.sizes.spacing / 2) *
                                (_kProgressRingBase / restSize))
                            .clamp(2.0, _kProgressRingBase * 0.22),
                        color: _progressColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(widget.sizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rest',
                        style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: _progressColor,
                        ),
                      ),
                      SizedBox(height: widget.sizes.spacing / 2),
                      Text(
                        _formatRestTime(_elapsedSeconds),
                        style: TextStyle(
                          fontSize: widget.sizes.fontSize,
                          fontWeight: FontWeight.w600,
                          color: _progressColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNext(_elapsedSeconds),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: widget.sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: _progressColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatRestTime(int seconds) {
  if (seconds < 60) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
