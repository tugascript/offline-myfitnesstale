import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_number_wheel.dart';
import '../../../layout/app_text_form_field.dart';
import '../../../layout/sharp_switch.dart';

const int _repsMin = 1;
const int _repsMax = 99;

class RepsInput extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int initialMinReps;
  final int? initialMaxReps;
  final TextEditingController? minRepsController;
  final ValueChanged<String>? minRepsOnChanged;
  final TextEditingController? maxRepsController;
  final ValueChanged<String>? maxRepsOnChanged;
  final bool toMaxReps;
  final ValueChanged<bool?>? onToMaxRepsChanged;

  const RepsInput({
    super.key,
    required this.initialMinReps,
    this.initialMaxReps,
    this.minRepsController,
    this.minRepsOnChanged,
    this.maxRepsController,
    this.maxRepsOnChanged,
    required this.sizes,
    required this.theme,
    required this.toMaxReps,
    this.onToMaxRepsChanged,
  });

  @override
  State<RepsInput> createState() => _RepsInputState();
}

class _RepsInputState extends State<RepsInput> {
  late final TextEditingController _controller;

  void _updateControllerText() {
    final min = widget.initialMinReps.clamp(_repsMin, _repsMax);
    final max = (widget.initialMaxReps ?? min).clamp(_repsMin, _repsMax);
    final displayMax = max >= min ? max : min;
    _controller.text = widget.toMaxReps
        ? '$min - MAX'
        : (min == displayMax ? '$min' : '$min - $displayMax');
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant RepsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinReps != widget.initialMinReps ||
        oldWidget.initialMaxReps != widget.initialMaxReps ||
        oldWidget.toMaxReps != widget.toMaxReps) {
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = widget.initialMinReps.clamp(_repsMin, _repsMax);
    final max = (widget.initialMaxReps ?? min).clamp(_repsMin, _repsMax);
    final displayMax = max >= min ? max : min;

    return AppTextFormField(
      controller: _controller,
      readOnly: true,
      onTap: widget.minRepsOnChanged == null
          ? null
          : () {
              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => _RepsWheelSheetContent(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  initialMin: min,
                  initialMax: widget.toMaxReps ? null : displayMax,
                  toMaxReps: widget.toMaxReps,
                  onMinChanged: widget.minRepsOnChanged!,
                  onMaxChanged: widget.maxRepsOnChanged,
                  onToMaxRepsChanged: widget.onToMaxRepsChanged,
                ),
              );
            },
      theme: widget.theme,
      labelText: 'Reps',
      hintText: 'Min - Max',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(
        Icons.repeat_one,
        size: widget.sizes.fontSize * 1.2,
      ),
    );
  }
}

class _RepsWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialMin;
  final int? initialMax;
  final bool toMaxReps;
  final ValueChanged<String> onMinChanged;
  final ValueChanged<String>? onMaxChanged;
  final ValueChanged<bool?>? onToMaxRepsChanged;

  const _RepsWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialMin,
    this.initialMax,
    required this.toMaxReps,
    required this.onMinChanged,
    this.onMaxChanged,
    this.onToMaxRepsChanged,
  });

  @override
  State<_RepsWheelSheetContent> createState() => _RepsWheelSheetContentState();
}

class _RepsWheelSheetContentState extends State<_RepsWheelSheetContent> {
  late FixedExtentScrollController _minController;
  FixedExtentScrollController? _maxController;
  late bool _toMaxReps;

  @override
  void initState() {
    super.initState();
    _toMaxReps = widget.toMaxReps;
    final min = widget.initialMin.clamp(_repsMin, _repsMax);
    _minController = FixedExtentScrollController(initialItem: min - _repsMin);
    if (!_toMaxReps) {
      final max = (widget.initialMax ?? min).clamp(_repsMin, _repsMax);
      _maxController = FixedExtentScrollController(initialItem: max - _repsMin);
    } else {
      _maxController = null;
    }
  }

  @override
  void didUpdateWidget(covariant _RepsWheelSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toMaxReps != widget.toMaxReps &&
        widget.toMaxReps != _toMaxReps) {
      _toMaxReps = widget.toMaxReps;
      if (_toMaxReps) {
        _maxController?.dispose();
        _maxController = null;
      } else {
        _createMaxController();
      }
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController?.dispose();
    super.dispose();
  }

  void _createMaxController() {
    final minIndex = _minController.selectedItem;
    final minVal = _repsMin + minIndex;
    // Restore previous max when available, otherwise use current min
    final maxVal = (widget.initialMax ?? minVal).clamp(_repsMin, _repsMax);
    final clampedMax = maxVal >= minVal ? maxVal : minVal;
    final initialItem = (clampedMax - _repsMin).clamp(0, _repsMax - _repsMin);
    _maxController = FixedExtentScrollController(initialItem: initialItem);
  }

  void _onToMaxRepsChanged(bool? value) {
    final newToMaxReps = value ?? false;
    if (newToMaxReps == _toMaxReps) return;
    setState(() {
      _toMaxReps = newToMaxReps;
      if (_toMaxReps) {
        _maxController?.dispose();
        _maxController = null;
      } else {
        _createMaxController();
      }
    });
    // widget.onToMaxRepsChanged?.call(value);
  }

  void _onConfirm() {
    final minIndex = _minController.selectedItem;
    final minVal = _repsMin + minIndex;
    widget.onMinChanged(minVal.toString());
    widget.onToMaxRepsChanged?.call(_toMaxReps);
    if (!_toMaxReps && _maxController != null) {
      final maxIndex = _maxController!.selectedItem;
      final maxVal = _repsMin + maxIndex;
      final clampedMax = maxVal >= minVal ? maxVal : minVal;
      widget.onMaxChanged?.call(clampedMax.toString());
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final wheelItemExtent = widget.sizes.subtitleFontSize * 3;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(widget.sizes.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Text('Reps',
                    style: TextStyle(
                        fontSize: widget.sizes.subtitleFontSize,
                        fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: _onConfirm,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: wheelItemExtent * 5,
            child: Row(
              children: [
                Expanded(
                  child: AppNumberWheel(
                    minValue: _repsMin,
                    maxValue: _repsMax,
                    scrollController: _minController,
                    itemExtent: wheelItemExtent,
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                ),
                if (!_toMaxReps && _maxController != null) ...[
                  Text('-', style: TextStyle(fontSize: widget.sizes.fontSize)),
                  Expanded(
                    child: AppNumberWheel(
                      key: ObjectKey(_maxController!),
                      minValue: _repsMin,
                      maxValue: _repsMax,
                      scrollController: _maxController!,
                      itemExtent: wheelItemExtent,
                      fontSize: widget.sizes.subtitleFontSize,
                    ),
                  ),
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "to MAX",
                      style: TextStyle(fontSize: widget.sizes.fontSize),
                    ),
                    SharpSwitch(
                      value: _toMaxReps,
                      onChanged: _onToMaxRepsChanged,
                      thumbSize: widget.sizes.subtitleFontSize * 1.15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
