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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../details/cardio_editor/cardio_duration_input.dart';
import './cardio_rpe_input.dart';

class WorkoutCardioSetExerciseRecordForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final CardioBaseMode mode;
  final String? unit;
  final int initialQuantity;
  final int initialDurationSecs;
  final int initialRpe;
  final bool showExerciseRest;
  final int initialExerciseRestSecs;
  final bool showRoundRest;
  final int initialRoundRestSecs;
  final ValueChanged<int>? onRoundRestSecsChanged;
  final void Function({
    required int quantity,
    required int durationSecs,
    required int restSecs,
    required int rpe,
  })
  onValuesChanged;

  const WorkoutCardioSetExerciseRecordForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.mode,
    this.unit,
    required this.initialQuantity,
    required this.initialDurationSecs,
    this.initialRpe = 8,
    this.showExerciseRest = false,
    this.initialExerciseRestSecs = 0,
    this.showRoundRest = false,
    this.initialRoundRestSecs = 0,
    this.onRoundRestSecsChanged,
    required this.onValuesChanged,
  });

  @override
  State<WorkoutCardioSetExerciseRecordForm> createState() =>
      _WorkoutCardioSetExerciseRecordFormState();
}

class _WorkoutCardioSetExerciseRecordFormState
    extends State<WorkoutCardioSetExerciseRecordForm> {
  late int _quantity;
  late int _durationSecs;
  late int _exerciseRestSecs;
  late int _roundRestSecs;
  late int _rpe;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
    _quantityController = TextEditingController(
      text: _quantity > 0 ? '$_quantity' : '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _emitValues();
    });
  }

  @override
  void didUpdateWidget(covariant WorkoutCardioSetExerciseRecordForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuantity != widget.initialQuantity ||
        oldWidget.initialDurationSecs != widget.initialDurationSecs ||
        oldWidget.showExerciseRest != widget.showExerciseRest ||
        oldWidget.initialExerciseRestSecs != widget.initialExerciseRestSecs ||
        oldWidget.initialRoundRestSecs != widget.initialRoundRestSecs ||
        oldWidget.initialRpe != widget.initialRpe ||
        oldWidget.mode != widget.mode) {
      _syncFromWidget();
      final text = _quantity > 0 ? '$_quantity' : '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_quantityController.text != text) {
          _quantityController.text = text;
        }
        _emitValues();
      });
    }
  }

  void _syncFromWidget() {
    _quantity = widget.initialQuantity;
    _durationSecs = widget.mode == CardioBaseMode.time
        ? (widget.initialDurationSecs >= 0
              ? widget.initialDurationSecs
              : widget.initialQuantity)
        : widget.initialDurationSecs;
    if (widget.mode == CardioBaseMode.time) {
      _quantity = _durationSecs;
    }
    _exerciseRestSecs = widget.showExerciseRest
        ? widget.initialExerciseRestSecs
        : 0;
    _roundRestSecs = widget.initialRoundRestSecs;
    _rpe = widget.initialRpe.clamp(
      WorkoutSetExerciseDifficultyType.rpe.minValue,
      WorkoutSetExerciseDifficultyType.rpe.maxValue,
    );
  }

  void _emitValues() {
    widget.onValuesChanged(
      quantity: _quantity,
      durationSecs: _durationSecs,
      restSecs: _exerciseRestSecs,
      rpe: _rpe,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmedUnit = widget.unit?.trim();
    final unitsLabel = trimmedUnit != null && trimmedUnit.isNotEmpty
        ? 'Completed ($trimmedUnit)'
        : 'Completed Units';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.mode == CardioBaseMode.time)
          CardioDurationInput(
            theme: widget.theme,
            sizes: widget.sizes,
            seconds: _durationSecs,
            labelText: 'Duration',
            sheetTitle: 'Duration',
            allowHours: true,
            minSeconds: 0,
            enabled: !widget.isLoading,
            icon: Icons.schedule,
            onChanged: (secs) {
              setState(() {
                _durationSecs = secs;
                _quantity = secs;
              });
              _emitValues();
            },
          )
        else ...[
          AppTextFormField(
            theme: widget.theme,
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            labelText: unitsLabel,
            hintText: '${widget.initialQuantity}',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            isLoading: widget.isLoading,
            filled: true,
            prefixIcon: Icon(
              Icons.straighten,
              size: widget.sizes.fontSize * 1.2,
            ),
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value.trim()) ?? 0;
              });
              _emitValues();
            },
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          CardioDurationInput(
            theme: widget.theme,
            sizes: widget.sizes,
            seconds: _durationSecs,
            labelText: 'Elapsed Time',
            sheetTitle: 'Elapsed Time',
            allowHours: true,
            minSeconds: 0,
            enabled: !widget.isLoading,
            icon: Icons.schedule,
            onChanged: (secs) {
              setState(() {
                _durationSecs = secs;
              });
              _emitValues();
            },
          ),
        ],
        SizedBox(height: widget.sizes.inputSpacing),
        CardioRpeInput(
          initialRpe: _rpe,
          theme: widget.theme,
          sizes: widget.sizes,
          isLoading: widget.isLoading,
          onChanged: (value) {
            if (_rpe == value) return;
            _rpe = value;
            _emitValues();
          },
        ),
        if (widget.showExerciseRest) ...[
          SizedBox(height: widget.sizes.inputSpacing),
          CardioDurationInput(
            theme: widget.theme,
            sizes: widget.sizes,
            seconds: _exerciseRestSecs,
            labelText: 'Exercise Rest',
            sheetTitle: 'Exercise Rest',
            allowHours: false,
            minSeconds: 0,
            enabled: !widget.isLoading,
            icon: Icons.timer_outlined,
            onChanged: (secs) {
              setState(() {
                _exerciseRestSecs = secs;
              });
              _emitValues();
            },
          ),
        ],
        if (widget.showRoundRest && widget.onRoundRestSecsChanged != null) ...[
          SizedBox(height: widget.sizes.inputSpacing),
          CardioDurationInput(
            theme: widget.theme,
            sizes: widget.sizes,
            seconds: _roundRestSecs,
            labelText: 'Round Rest',
            sheetTitle: 'Round Rest',
            allowHours: false,
            minSeconds: 0,
            enabled: !widget.isLoading,
            icon: Icons.timer,
            onChanged: (secs) {
              setState(() {
                _roundRestSecs = secs;
              });
              widget.onRoundRestSecsChanged!(secs);
            },
          ),
        ],
      ],
    );
  }
}
