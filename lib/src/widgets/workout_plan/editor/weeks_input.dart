import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_number_wheel.dart';
import '../../layout/app_text_form_field.dart';

const _addWeeks = 11;

class WeeksInput extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int currentWeek;
  final int? initialEndWeek;
  final TextEditingController? startWeekController;
  final ValueChanged<String>? startWeekOnChanged;
  final TextEditingController? endWeekController;
  final ValueChanged<String>? endWeekOnChanged;

  const WeeksInput({
    super.key,
    this.startWeekController,
    this.startWeekOnChanged,
    this.endWeekController,
    this.endWeekOnChanged,
    required this.sizes,
    required this.theme,
    required this.currentWeek,
    this.initialEndWeek,
  });

  @override
  State<WeeksInput> createState() => _WeeksInputState();
}

class _WeeksInputState extends State<WeeksInput> {
  late final TextEditingController _controller;

  static String _displayText(int min, int displayMax) {
    return min == displayMax ? '$min' : '$min - $displayMax';
  }

  void _updateControllerText() {
    final min = widget.currentWeek.clamp(
      widget.currentWeek,
      widget.currentWeek + _addWeeks,
    );
    final max = (widget.initialEndWeek ?? min).clamp(
      widget.currentWeek,
      widget.currentWeek + _addWeeks,
    );
    final displayMax = max >= min ? max : min;
    _controller.text = _displayText(min, displayMax);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant WeeksInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeek != widget.currentWeek ||
        oldWidget.initialEndWeek != widget.initialEndWeek) {
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
    final min = widget.currentWeek.clamp(
      widget.currentWeek,
      widget.currentWeek,
    );
    final max = (widget.initialEndWeek ?? min).clamp(
      widget.currentWeek,
      widget.currentWeek + _addWeeks,
    );
    final displayMax = max >= min ? max : min;

    return AppTextFormField(
      key: ValueKey(widget.currentWeek),
      controller: _controller,
      readOnly: true,
      onTap:
          widget.startWeekOnChanged == null || widget.endWeekOnChanged == null
              ? null
              : () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (sheetContext) => _WeeksWheelSheetContent(
                      theme: widget.theme,
                      sizes: widget.sizes,
                      initialMin: min,
                      initialMax: displayMax,
                      onMinChanged: widget.startWeekOnChanged!,
                      onMaxChanged: widget.endWeekOnChanged!,
                    ),
                  );
                },
      theme: widget.theme,
      labelText: 'Weeks',
      hintText: 'Start - End',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(
        Icons.calendar_month,
        size: widget.sizes.fontSize * 1.2,
      ),
    );
  }
}

class _WeeksWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialMin;
  final int initialMax;
  final ValueChanged<String> onMinChanged;
  final ValueChanged<String> onMaxChanged;

  const _WeeksWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialMin,
    required this.initialMax,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  State<_WeeksWheelSheetContent> createState() =>
      _WeeksWheelSheetContentState();
}

class _WeeksWheelSheetContentState extends State<_WeeksWheelSheetContent> {
  late final FixedExtentScrollController _minController;
  late final FixedExtentScrollController _maxController;

  @override
  void initState() {
    super.initState();
    final min = widget.initialMin.clamp(widget.initialMin, widget.initialMin);
    final max = widget.initialMax.clamp(
      widget.initialMin,
      widget.initialMin + _addWeeks,
    );
    _minController = FixedExtentScrollController(initialItem: min - 1);
    _maxController = FixedExtentScrollController(initialItem: max - 1);
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final minIndex = _minController.selectedItem;
    final maxIndex = _maxController.selectedItem;
    final minVal = widget.initialMin + minIndex;
    final maxVal = widget.initialMin + maxIndex;
    final clampedMax = maxVal >= minVal ? maxVal : minVal;
    widget.onMinChanged(minVal.toString());
    widget.onMaxChanged(clampedMax.toString());
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
                Text(
                  'Weeks',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    minValue: widget.initialMin,
                    maxValue: widget.initialMin,
                    scrollController: _minController,
                    itemExtent: wheelItemExtent,
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                ),
                Text('-', style: TextStyle(fontSize: widget.sizes.fontSize)),
                Expanded(
                  child: AppNumberWheel(
                    minValue: widget.initialMin,
                    maxValue: widget.initialMin + _addWeeks,
                    scrollController: _maxController,
                    itemExtent: wheelItemExtent,
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
