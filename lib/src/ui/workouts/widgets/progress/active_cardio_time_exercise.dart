// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/layout/app_outlined_button.dart';
import './cardio_rpe_input.dart';

const double _kProgressRingBase = 100;

class ActiveCardioTimeExercise extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int workoutCardioSetExerciseId;
  final int roundNumber;
  final int targetSecs;
  final int initialRpe;
  final bool isLoading;
  final String completeLabel;
  final void Function({required int elapsedSecs, required int rpe}) onComplete;

  const ActiveCardioTimeExercise({
    super.key,
    required this.sizes,
    required this.theme,
    required this.workoutCardioSetExerciseId,
    required this.roundNumber,
    required this.targetSecs,
    this.initialRpe = 8,
    required this.isLoading,
    this.completeLabel = 'Complete & Next',
    required this.onComplete,
  });

  @override
  State<ActiveCardioTimeExercise> createState() =>
      _ActiveCardioTimeExerciseState();
}

class _ActiveCardioTimeExerciseState extends State<ActiveCardioTimeExercise> {
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  late int _rpe;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rpe = widget.initialRpe.clamp(
      WorkoutSetExerciseDifficultyType.rpe.minValue,
      WorkoutSetExerciseDifficultyType.rpe.maxValue,
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ActiveCardioTimeExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutCardioSetExerciseId !=
            widget.workoutCardioSetExerciseId ||
        oldWidget.roundNumber != widget.roundNumber) {
      _elapsedSeconds = 0;
      _isPaused = false;
      _rpe = widget.initialRpe.clamp(
        WorkoutSetExerciseDifficultyType.rpe.minValue,
        WorkoutSetExerciseDifficultyType.rpe.maxValue,
      );
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused) return;
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  double get _progress {
    if (widget.targetSecs <= 0) return 1.0;
    return (_elapsedSeconds / widget.targetSecs).clamp(0.0, 1.0).toDouble();
  }

  Color get _progressColor {
    final isDarkTheme = widget.theme.colorScheme.brightness == Brightness.dark;
    if (widget.targetSecs > 0 && _elapsedSeconds >= widget.targetSecs) {
      return isDarkTheme ? Colors.green.shade400 : Colors.green.shade600;
    }
    return widget.theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final ringSize = widget.sizes.fontSize * 4 + widget.sizes.padding * 7;
    final progressColor = _progressColor;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: const BeveledRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.all(widget.sizes.padding),
          child: Column(
            children: [
              SizedBox.square(
                dimension: ringSize,
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
                            strokeWidth:
                                ((widget.sizes.spacing / 2) *
                                        (_kProgressRingBase / ringSize))
                                    .clamp(2.0, _kProgressRingBase * 0.22),
                            color: progressColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(widget.sizes.padding * 1.25),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isPaused ? 'Paused' : 'Timer',
                              style: TextStyle(
                                fontSize: widget.sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: progressColor,
                              ),
                            ),
                            SizedBox(height: widget.sizes.quarterSpacing),
                            Text(
                              _formatElapsed(_elapsedSeconds),
                              style: TextStyle(
                                fontSize: widget.sizes.titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                            SizedBox(height: widget.sizes.quarterSpacing),
                            Text(
                              'Target ${Converters.formatDuration(widget.targetSecs)}',
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize,
                                color:
                                    widget.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: widget.sizes.spacing),
              CardioRpeInput(
                key: ValueKey((
                  widget.workoutCardioSetExerciseId,
                  widget.roundNumber,
                )),
                initialRpe: _rpe,
                theme: widget.theme,
                sizes: widget.sizes,
                isLoading: widget.isLoading,
                onChanged: (value) {
                  _rpe = value;
                },
              ),
              SizedBox(height: widget.sizes.inputSpacing),
              SizedBox(
                width: double.infinity,
                child: AppOutlinedButton(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  isLoading: widget.isLoading,
                  isDense: true,
                  color: widget.theme.colorScheme.secondary,
                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
                  label: _isPaused ? 'Resume' : 'Pause',
                  onPressed: _togglePause,
                ),
              ),
              SizedBox(height: widget.sizes.inputSpacing),
              SizedBox(
                width: double.infinity,
                child: AppOutlinedButton(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  isLoading: widget.isLoading,
                  isDense: true,
                  icon: Icons.check,
                  label: widget.completeLabel,
                  onPressed: () {
                    widget.onComplete(elapsedSecs: _elapsedSeconds, rpe: _rpe);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatElapsed(int seconds) {
  if (seconds >= 3600) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}
