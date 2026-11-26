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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/utils/converters.dart';
import '../../../../core/widgets/layout/app_number_wheel.dart';
import '../../../../core/widgets/layout/app_text_form_field.dart';

const int _maxHours = 23;
const int _maxMinutes = 59;
const int _maxSeconds = 59;

class CardioDurationInput extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int seconds;
  final String labelText;
  final String sheetTitle;
  final bool allowHours;
  final int minSeconds;
  final bool enabled;
  final IconData icon;
  final ValueChanged<int>? onChanged;

  const CardioDurationInput({
    super.key,
    required this.theme,
    required this.sizes,
    required this.seconds,
    required this.labelText,
    required this.sheetTitle,
    this.allowHours = false,
    this.minSeconds = 0,
    this.enabled = true,
    this.icon = Icons.timer,
    this.onChanged,
  });

  @override
  State<CardioDurationInput> createState() => _CardioDurationInputState();
}

class _CardioDurationInputState extends State<CardioDurationInput> {
  late final TextEditingController _controller;

  int get _maxTotalSeconds => widget.allowHours
      ? (_maxHours * 3600) + (_maxMinutes * 60) + _maxSeconds
      : (_maxMinutes * 60) + _maxSeconds;

  int _clampedSeconds(int value) {
    return value.clamp(widget.minSeconds, _maxTotalSeconds);
  }

  void _updateText() {
    _controller.text = Converters.formatDuration(
      _clampedSeconds(widget.seconds),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateText();
  }

  @override
  void didUpdateWidget(covariant CardioDurationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds ||
        oldWidget.allowHours != widget.allowHours ||
        oldWidget.minSeconds != widget.minSeconds) {
      _updateText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWheelSheet() {
    if (!widget.enabled || widget.onChanged == null) {
      return;
    }

    final initialSeconds = _clampedSeconds(widget.seconds);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const BeveledRectangleBorder(),
      builder: (sheetContext) => _CardioDurationWheelSheet(
        sizes: widget.sizes,
        title: widget.sheetTitle,
        initialSeconds: initialSeconds,
        allowHours: widget.allowHours,
        minSeconds: widget.minSeconds,
        onConfirm: widget.onChanged!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      onTap: !widget.enabled || widget.onChanged == null
          ? null
          : _openWheelSheet,
      theme: widget.theme,
      labelText: widget.labelText,
      hintText: widget.allowHours ? '1m' : '0s',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(widget.icon, size: widget.sizes.fontSize * 1.2),
    );
  }
}

class _CardioDurationWheelSheet extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final String title;
  final int initialSeconds;
  final bool allowHours;
  final int minSeconds;
  final ValueChanged<int> onConfirm;

  const _CardioDurationWheelSheet({
    required this.sizes,
    required this.title,
    required this.initialSeconds,
    required this.allowHours,
    required this.minSeconds,
    required this.onConfirm,
  });

  @override
  State<_CardioDurationWheelSheet> createState() =>
      _CardioDurationWheelSheetState();
}

class _CardioDurationWheelSheetState extends State<_CardioDurationWheelSheet> {
  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;
  late final FixedExtentScrollController _secondsController;

  @override
  void initState() {
    super.initState();
    final hours = widget.allowHours
        ? (widget.initialSeconds ~/ 3600).clamp(0, _maxHours)
        : 0;
    final minutes = ((widget.initialSeconds % 3600) ~/ 60).clamp(
      0,
      _maxMinutes,
    );
    final seconds = (widget.initialSeconds % 60).clamp(0, _maxSeconds);

    _hoursController = FixedExtentScrollController(initialItem: hours);
    _minutesController = FixedExtentScrollController(initialItem: minutes);
    _secondsController = FixedExtentScrollController(initialItem: seconds);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _confirm() {
    final hours = widget.allowHours ? _hoursController.selectedItem : 0;
    final minutes = _minutesController.selectedItem;
    final seconds = _secondsController.selectedItem;
    final total = (hours * 3600) + (minutes * 60) + seconds;
    final resolved = total < widget.minSeconds ? widget.minSeconds : total;
    widget.onConfirm(resolved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final textScaler = MediaQuery.textScalerOf(context);
    final wheelItemExtent = math.max(
      widget.sizes.subtitleFontSize * 3,
      textScaler.scale(widget.sizes.subtitleFontSize) * 1.5,
    );
    final unitStyle = TextStyle(
      fontSize: widget.sizes.smallFontSize,
      fontWeight: FontWeight.w500,
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.sizes.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: _confirm,
                      child: const Text(
                        'Confirm',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.sizes.padding),
              child: Row(
                children: [
                  if (widget.allowHours)
                    Expanded(
                      child: Text(
                        'Hours',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: unitStyle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      'Min',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: unitStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Sec',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: unitStyle,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SizedBox(
                height: wheelItemExtent * 5,
                child: Row(
                  children: [
                    if (widget.allowHours) ...[
                      Expanded(
                        child: AppNumberWheel(
                          minValue: 0,
                          maxValue: _maxHours,
                          scrollController: _hoursController,
                          itemExtent: wheelItemExtent,
                          fontSize: widget.sizes.subtitleFontSize,
                        ),
                      ),
                      Text(
                        ':',
                        style: TextStyle(fontSize: widget.sizes.fontSize),
                      ),
                    ],
                    Expanded(
                      child: AppNumberWheel(
                        minValue: 0,
                        maxValue: _maxMinutes,
                        scrollController: _minutesController,
                        itemExtent: wheelItemExtent,
                        fontSize: widget.sizes.subtitleFontSize,
                      ),
                    ),
                    Text(
                      ':',
                      style: TextStyle(fontSize: widget.sizes.fontSize),
                    ),
                    Expanded(
                      child: AppNumberWheel(
                        minValue: 0,
                        maxValue: _maxSeconds,
                        scrollController: _secondsController,
                        itemExtent: wheelItemExtent,
                        fontSize: widget.sizes.subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
