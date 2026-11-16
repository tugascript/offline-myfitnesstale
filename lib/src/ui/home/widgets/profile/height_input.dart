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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';

final class HeightInput extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final bool isMetric;
  final int initialHeight;
  final void Function(int) onChanged;
  final void Function(int) onSaved;

  const HeightInput({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.initialHeight,
    required this.isMetric,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  State<HeightInput> createState() => _HeightInputState();
}

class _HeightInputState extends State<HeightInput> {
  final TextEditingController _cmController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isMetric) {
      _cmController.text = widget.initialHeight.toString();
      final (int feet, int inches) = Converters.cmToFeetAndInches(
        widget.initialHeight,
      );
      _feetController.text = feet.toString();
      _inchesController.text = inches.toString();
      return;
    }

    final (int, int) feetAndInches = Converters.cmToFeetAndInches(
      widget.initialHeight,
    );
    _feetController.text = feetAndInches.$1.toString();
    _inchesController.text = feetAndInches.$2.toString();
  }

  @override
  void dispose() {
    _cmController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMetric
        ? AppTextFormField(
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _cmController,
            labelText: 'Height (cm)',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            keyboardType: TextInputType.number,
            prefixIcon: Icon(Icons.straighten, size: widget.sizes.iconFontSize),
            onChanged: (value) {
              _updateHeightMetric(widget.onChanged);
            },
            onSaved: (value) {
              _updateHeightMetric(widget.onSaved);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a height';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          )
        : Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  theme: widget.theme,
                  isLoading: widget.isLoading,
                  controller: _feetController,
                  labelText: 'Feet',
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.square_foot,
                    size: widget.sizes.iconFontSize,
                  ),
                  onChanged: (value) {
                    _updateHeightImperial(widget.onChanged);
                  },
                  onSaved: (value) {
                    _updateHeightImperial(widget.onSaved);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter feet';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: widget.sizes.halfSpacing),
              Expanded(
                child: AppTextFormField(
                  theme: widget.theme,
                  isLoading: widget.isLoading,
                  controller: _inchesController,
                  labelText: 'Inches',
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.padding,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.straighten,
                    size: widget.sizes.iconFontSize,
                  ),
                  onChanged: (value) {
                    _updateHeightImperial(widget.onChanged);
                  },
                  onSaved: (value) {
                    _updateHeightImperial(widget.onSaved);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter inches';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
  }

  void _updateHeightImperial(void Function(int) onFn) {
    if (widget.isLoading) return;
    final int feet = int.tryParse(_feetController.text) ?? 0;
    final int inches = int.tryParse(_inchesController.text) ?? 0;
    final int totalCm = Converters.feetAndInchesToCm(feet, inches);
    _cmController.text = totalCm.toString();
    onFn(totalCm);
  }

  void _updateHeightMetric(void Function(int) onFn) {
    if (widget.isLoading) return;
    final int cm = int.tryParse(_cmController.text) ?? 0;
    final (int feet, int inches) = Converters.cmToFeetAndInches(cm);
    _feetController.text = feet.toString();
    _inchesController.text = inches.toString();
    onFn(cm);
  }
}
