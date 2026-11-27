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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_outlined_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import './cardio_rpe_input.dart';

class ActiveCardioUnitsExercise extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int workoutCardioSetExerciseId;
  final int roundNumber;
  final int initialQuantity;
  final String? unit;
  final int initialRpe;
  final bool isLoading;
  final String completeLabel;
  final void Function({
    required int quantity,
    required int elapsedSecs,
    required int rpe,
  })
  onComplete;

  const ActiveCardioUnitsExercise({
    super.key,
    required this.sizes,
    required this.theme,
    required this.workoutCardioSetExerciseId,
    required this.roundNumber,
    required this.initialQuantity,
    this.unit,
    this.initialRpe = 8,
    required this.isLoading,
    this.completeLabel = 'Complete & Next',
    required this.onComplete,
  });

  @override
  State<ActiveCardioUnitsExercise> createState() =>
      _ActiveCardioUnitsExerciseState();
}

class _ActiveCardioUnitsExerciseState extends State<ActiveCardioUnitsExercise> {
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  late int _rpe;
  late final TextEditingController _quantityController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rpe = widget.initialRpe.clamp(
      WorkoutSetExerciseDifficultyType.rpe.minValue,
      WorkoutSetExerciseDifficultyType.rpe.maxValue,
    );
    _quantityController = TextEditingController(
      text: widget.initialQuantity > 0 ? '${widget.initialQuantity}' : '',
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ActiveCardioUnitsExercise oldWidget) {
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
      _quantityController.text = widget.initialQuantity > 0
          ? '${widget.initialQuantity}'
          : '';
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quantityController.dispose();
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

  void _submit() {
    final parsed = int.tryParse(_quantityController.text.trim());
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid completed amount'),
          backgroundColor: widget.theme.colorScheme.error,
        ),
      );
      return;
    }
    widget.onComplete(
      quantity: parsed,
      elapsedSecs: _elapsedSeconds,
      rpe: _rpe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colorScheme;
    final trimmedUnit = widget.unit?.trim();
    final quantityLabel = trimmedUnit != null && trimmedUnit.isNotEmpty
        ? 'Completed ($trimmedUnit)'
        : 'Completed Units';

    return Card(
      margin: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(widget.sizes.padding),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  Text(
                    _isPaused ? 'Elapsed Time (Paused)' : 'Elapsed Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.sizes.fontSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: widget.sizes.quarterSpacing),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatElapsed(_elapsedSeconds),
                      style: TextStyle(
                        fontSize: widget.sizes.titleFontSize * 1.25,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.sizes.inputSpacing),
            AppTextFormField(
              theme: widget.theme,
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              labelText: quantityLabel,
              hintText: '${widget.initialQuantity}',
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              filled: true,
              prefixIcon: Icon(
                Icons.straighten,
                size: widget.sizes.fontSize * 1.2,
              ),
            ),
            SizedBox(height: widget.sizes.inputSpacing),
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
                color: colors.secondary,
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
                onPressed: _submit,
              ),
            ),
          ],
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
