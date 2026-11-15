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

import '../../themes/colors.dart';

/// Matches Flutter's private `_kDenseButtonHeight` in `dropdown.dart`.
const double _kDenseButtonHeight = 24.0;

/// How much of the dense-height overflow to claw back from vertical padding.
/// `1.0` matched text-field math but read too small; `0.0` left dropdowns tall.
const double _kDenseHeightCompensation = 0.7;

class AppDropdown<T> extends StatelessWidget {
  final ThemeData theme;
  final bool filled;
  final T? value;
  final String emptyLabel;
  final String? labelText;
  final List<T> items;
  final void Function(T?) onChanged;
  final void Function(T?) onSaved;
  final String? Function(T?)? validator;
  final bool showEmptyValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final bool isLoading;

  final String Function(T) labelBuilder;
  final double fontSize;
  final double padding;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.theme,
    this.filled = false,
    required this.value,
    required this.emptyLabel,
    this.labelText,
    required this.items,
    required this.onChanged,
    required this.onSaved,
    required this.labelBuilder,
    required this.fontSize,
    required this.padding,
    required this.isLoading,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.showEmptyValue = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = ThemedColors.themedGrey.fromBrightness(theme.brightness);
    final isEnabled = enabled && !isLoading;
    // Explicit height 1.0 avoids inheriting `titleMedium.height`.
    final textStyle = TextStyle(
      fontSize: fontSize,
      height: 1.0,
      color: isEnabled ? theme.colorScheme.onSurface : greyColor,
    );
    // Dense dropdowns still floor content at 24px; partially reduce padding so
    // the outer box sits just above the fully-compensated (too small) size.
    final scaledFontSize = MediaQuery.textScalerOf(context).scale(fontSize);
    final denseContentHeight = math.max(
      scaledFontSize,
      math.max(fontSize, _kDenseButtonHeight),
    );
    final baseVerticalPadding = padding * 0.9;
    final verticalPadding = math.max(
      0.0,
      baseVerticalPadding -
          _kDenseHeightCompensation * (denseContentHeight - scaledFontSize) / 2,
    );

    return DropdownButtonFormField<T?>(
      isExpanded: true,
      isDense: true,
      iconSize: fontSize,
      iconDisabledColor: greyColor,
      enabled: isEnabled,
      style: textStyle,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        prefixIconConstraints:
            prefixIconConstraints ??
            BoxConstraints.tightFor(
              width: fontSize * 2,
              height: fontSize * 1.5,
            ),
        suffixIcon: suffixIcon,
        suffixIconConstraints:
            suffixIconConstraints ??
            BoxConstraints.tightFor(
              width: fontSize * 2,
              height: fontSize * 1.5,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: theme.colorScheme.secondary,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: theme.colorScheme.secondary,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: theme.colorScheme.secondary,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: greyColor, width: 1.0),
        ),
        isDense: true,
        filled: filled,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: padding / 2,
          vertical: verticalPadding,
        ),
      ),
      initialValue: value,
      items: [
        if (showEmptyValue)
          DropdownMenuItem<T?>(
            value: null,
            child: Text(
              emptyLabel,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ...items.map(
          (i) => DropdownMenuItem<T?>(
            value: i,
            child: Text(
              labelBuilder(i),
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ),
      ],
      onChanged: isEnabled ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
