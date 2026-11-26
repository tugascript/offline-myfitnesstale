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

import 'package:material_ui/material_ui.dart';

import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_number_wheel.dart';
import '../../../../core/widgets/layout/app_text_form_field.dart';

const int _roundsMin = 1;
const int _roundsMax = 50;

class CardioRoundsInput extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final int initialRounds;
  final bool enabled;
  final ValueChanged<int>? onChanged;

  const CardioRoundsInput({
    super.key,
    required this.sizes,
    required this.theme,
    required this.initialRounds,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<CardioRoundsInput> createState() => _CardioRoundsInputState();
}

class _CardioRoundsInputState extends State<CardioRoundsInput> {
  late final TextEditingController _controller;

  void _updateText() {
    final rounds = widget.initialRounds.clamp(_roundsMin, _roundsMax);
    _controller.text = '$rounds';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateText();
  }

  @override
  void didUpdateWidget(covariant CardioRoundsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRounds != widget.initialRounds) {
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

    final initial = widget.initialRounds.clamp(_roundsMin, _roundsMax);
    showModalBottomSheet<void>(
      context: context,
      shape: const BeveledRectangleBorder(),
      builder: (sheetContext) => _CardioRoundsWheelSheet(
        sizes: widget.sizes,
        initialRounds: initial,
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
      labelText: 'Rounds',
      hintText: '1',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      filled: true,
      isLoading: false,
      prefixIcon: Icon(Icons.repeat, size: widget.sizes.fontSize * 1.2),
    );
  }
}

class _CardioRoundsWheelSheet extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final int initialRounds;
  final ValueChanged<int> onConfirm;

  const _CardioRoundsWheelSheet({
    required this.sizes,
    required this.initialRounds,
    required this.onConfirm,
  });

  @override
  State<_CardioRoundsWheelSheet> createState() =>
      _CardioRoundsWheelSheetState();
}

class _CardioRoundsWheelSheetState extends State<_CardioRoundsWheelSheet> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem:
          widget.initialRounds.clamp(_roundsMin, _roundsMax) - _roundsMin,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final rounds = _roundsMin + _controller.selectedItem;
    widget.onConfirm(rounds);
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
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Expanded(
                  child: Text(
                    'Rounds',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(onPressed: _confirm, child: const Text('Confirm')),
              ],
            ),
          ),
          SizedBox(
            height: wheelItemExtent * 5,
            child: AppNumberWheel(
              minValue: _roundsMin,
              maxValue: _roundsMax,
              scrollController: _controller,
              itemExtent: wheelItemExtent,
              fontSize: widget.sizes.subtitleFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
