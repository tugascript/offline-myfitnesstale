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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_number_wheel.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';

class CardioRpeInput extends StatefulWidget {
  final int initialRpe;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<int> onChanged;

  const CardioRpeInput({
    super.key,
    required this.initialRpe,
    required this.theme,
    required this.sizes,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  State<CardioRpeInput> createState() => _CardioRpeInputState();
}

class _CardioRpeInputState extends State<CardioRpeInput> {
  static final int _minRpe = WorkoutSetExerciseDifficultyType.rpe.minValue;
  static final int _maxRpe = WorkoutSetExerciseDifficultyType.rpe.maxValue;

  late int _value;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialRpe.clamp(_minRpe, _maxRpe);
    _controller = TextEditingController(text: '$_value');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(_value);
    });
  }

  @override
  void didUpdateWidget(covariant CardioRpeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRpe != widget.initialRpe) {
      _value = widget.initialRpe.clamp(_minRpe, _maxRpe);
      final formatted = '$_value';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.text != formatted) {
          _controller.text = formatted;
        }
        widget.onChanged(_value);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWheel() {
    if (widget.isLoading) return;
    final controller = FixedExtentScrollController(
      initialItem: _value - _minRpe,
    );
    showModalBottomSheet<void>(
      context: context,
      shape: const BeveledRectangleBorder(),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  Flexible(
                    child: Text(
                      'Effort (RPE)',
                      style: TextStyle(
                        fontSize: widget.sizes.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final val = _minRpe + controller.selectedItem;
                      setState(() {
                        _value = val;
                        _controller.text = '$val';
                      });
                      widget.onChanged(val);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: AppNumberWheel(
                minValue: _minRpe,
                maxValue: _maxRpe,
                scrollController: controller,
                itemExtent: widget.sizes.subtitleFontSize * 3,
                fontSize: widget.sizes.subtitleFontSize,
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      theme: widget.theme,
      controller: _controller,
      readOnly: true,
      onTap: _openWheel,
      labelText: 'RPE (1-10)',
      hintText: '${WorkoutSetExerciseDifficultyType.rpe.defaultValue}',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      isLoading: widget.isLoading,
      filled: true,
      prefixIcon: Icon(Icons.bolt, size: widget.sizes.fontSize * 1.2),
    );
  }
}
