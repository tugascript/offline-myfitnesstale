import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_number_wheel.dart';
import '../../../layout/app_text_form_field.dart';

const int _restSecsMin = 0;
const int _restSecsMax = 600;

class RestInput extends StatefulWidget {
  final int initialRest;
  final int? initialMaxRest;
  final TextEditingController? restController;
  final ValueChanged<String>? restOnChanged;
  final TextEditingController? maxRestController;
  final ValueChanged<String>? maxRestOnChanged;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const RestInput({
    super.key,
    required this.initialRest,
    this.initialMaxRest,
    this.restController,
    this.restOnChanged,
    this.maxRestController,
    this.maxRestOnChanged,
    required this.sizes,
    required this.theme,
  });

  @override
  State<RestInput> createState() => _RestInputState();
}

class _RestInputState extends State<RestInput> {
  late final TextEditingController _controller;

  void _updateControllerText() {
    final rest = widget.initialRest.clamp(_restSecsMin, _restSecsMax);
    final maxRest =
        (widget.initialMaxRest ?? rest).clamp(_restSecsMin, _restSecsMax);
    final displayMaxRest = maxRest >= rest ? maxRest : rest;
    _controller.text =
        rest == displayMaxRest ? '$rest' : '$rest – $displayMaxRest';
  }

  void _openWheelSheet() {
    if (widget.restOnChanged == null || widget.maxRestOnChanged == null) return;
    final rest = widget.initialRest.clamp(_restSecsMin, _restSecsMax);
    final maxRest =
        (widget.initialMaxRest ?? rest).clamp(_restSecsMin, _restSecsMax);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _RestWheelSheetContent(
        theme: widget.theme,
        sizes: widget.sizes,
        initialRest: rest,
        initialMaxRest: maxRest >= rest ? maxRest : rest,
        onRestChanged: widget.restOnChanged!,
        onMaxRestChanged: widget.maxRestOnChanged!,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant RestInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRest != widget.initialRest ||
        oldWidget.initialMaxRest != widget.initialMaxRest) {
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
    return AppTextFormField(
      controller: _controller,
      readOnly: true,
      onTap: widget.restOnChanged == null || widget.maxRestOnChanged == null
          ? null
          : _openWheelSheet,
      theme: widget.theme,
      labelText: 'Rest',
      hintText: '0 - 0',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(Icons.timer, size: widget.sizes.fontSize * 1.2),
    );
  }
}

class _RestWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialRest;
  final int initialMaxRest;
  final ValueChanged<String> onRestChanged;
  final ValueChanged<String> onMaxRestChanged;

  const _RestWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialRest,
    required this.initialMaxRest,
    required this.onRestChanged,
    required this.onMaxRestChanged,
  });

  @override
  State<_RestWheelSheetContent> createState() => _RestWheelSheetContentState();
}

class _RestWheelSheetContentState extends State<_RestWheelSheetContent> {
  late final FixedExtentScrollController _restController;
  late final FixedExtentScrollController _maxRestController;

  @override
  void initState() {
    super.initState();
    final rest = widget.initialRest.clamp(_restSecsMin, _restSecsMax);
    final maxRest = widget.initialMaxRest.clamp(_restSecsMin, _restSecsMax);
    _restController =
        FixedExtentScrollController(initialItem: rest - _restSecsMin);
    _maxRestController =
        FixedExtentScrollController(initialItem: maxRest - _restSecsMin);
  }

  @override
  void dispose() {
    _restController.dispose();
    _maxRestController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final restVal = _restSecsMin + _restController.selectedItem;
    final maxRestVal = _restSecsMin + _maxRestController.selectedItem;
    final clampedMaxRest = maxRestVal >= restVal ? maxRestVal : restVal;
    widget.onRestChanged(restVal.toString());
    widget.onMaxRestChanged(clampedMaxRest.toString());
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
                Text('Rest (sec)',
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
                    minValue: _restSecsMin,
                    maxValue: _restSecsMax,
                    scrollController: _restController,
                    itemExtent: wheelItemExtent,
                    fontSize: widget.sizes.subtitleFontSize,
                  ),
                ),
                Text('–', style: TextStyle(fontSize: widget.sizes.fontSize)),
                Expanded(
                  child: AppNumberWheel(
                    minValue: _restSecsMin,
                    maxValue: _restSecsMax,
                    scrollController: _maxRestController,
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
