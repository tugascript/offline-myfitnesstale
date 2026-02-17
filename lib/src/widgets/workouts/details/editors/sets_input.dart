import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_number_wheel.dart';
import '../../../layout/app_text_form_field.dart';

const int _setsMin = 1;
const int _setsMax = 50;

class SetsInput extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int initialMinSets;
  final int? initialMaxSets;
  final TextEditingController? minSetsController;
  final ValueChanged<String>? minSetsOnChanged;
  final TextEditingController? maxSetsController;
  final ValueChanged<String>? maxSetsOnChanged;

  const SetsInput({
    super.key,
    this.minSetsController,
    this.minSetsOnChanged,
    this.maxSetsController,
    this.maxSetsOnChanged,
    required this.sizes,
    required this.theme,
    required this.initialMinSets,
    this.initialMaxSets,
  });

  @override
  State<SetsInput> createState() => _SetsInputState();
}

class _SetsInputState extends State<SetsInput> {
  late final TextEditingController _controller;

  static String _displayText(int min, int displayMax) {
    return min == displayMax ? '$min' : '$min - $displayMax';
  }

  void _updateControllerText() {
    final min = widget.initialMinSets.clamp(_setsMin, _setsMax);
    final max = (widget.initialMaxSets ?? min).clamp(_setsMin, _setsMax);
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
  void didUpdateWidget(covariant SetsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinSets != widget.initialMinSets ||
        oldWidget.initialMaxSets != widget.initialMaxSets) {
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
    final min = widget.initialMinSets.clamp(_setsMin, _setsMax);
    final max = (widget.initialMaxSets ?? min).clamp(_setsMin, _setsMax);
    final displayMax = max >= min ? max : min;

    return AppTextFormField(
      controller: _controller,
      readOnly: true,
      onTap: widget.minSetsOnChanged == null || widget.maxSetsOnChanged == null
          ? null
          : () {
              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => _SetsWheelSheetContent(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  initialMin: min,
                  initialMax: displayMax,
                  onMinChanged: widget.minSetsOnChanged!,
                  onMaxChanged: widget.maxSetsOnChanged!,
                ),
              );
            },
      theme: widget.theme,
      labelText: 'Sets',
      hintText: 'Min - Max',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(Icons.repeat, size: widget.sizes.fontSize * 1.2),
    );
  }
}

class _SetsWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialMin;
  final int initialMax;
  final ValueChanged<String> onMinChanged;
  final ValueChanged<String> onMaxChanged;

  const _SetsWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialMin,
    required this.initialMax,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  State<_SetsWheelSheetContent> createState() => _SetsWheelSheetContentState();
}

class _SetsWheelSheetContentState extends State<_SetsWheelSheetContent> {
  late final FixedExtentScrollController _minController;
  late final FixedExtentScrollController _maxController;

  @override
  void initState() {
    super.initState();
    final min = widget.initialMin.clamp(_setsMin, _setsMax);
    final max = widget.initialMax.clamp(_setsMin, _setsMax);
    _minController = FixedExtentScrollController(initialItem: min - _setsMin);
    _maxController = FixedExtentScrollController(initialItem: max - _setsMin);
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
    final minVal = _setsMin + minIndex;
    final maxVal = _setsMin + maxIndex;
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
                Text('Sets',
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
                    minValue: _setsMin,
                    maxValue: _setsMax,
                    scrollController: _minController,
                    itemExtent: wheelItemExtent,
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                ),
                Text('-', style: TextStyle(fontSize: widget.sizes.fontSize)),
                Expanded(
                  child: AppNumberWheel(
                    minValue: _setsMin,
                    maxValue: _setsMax,
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
