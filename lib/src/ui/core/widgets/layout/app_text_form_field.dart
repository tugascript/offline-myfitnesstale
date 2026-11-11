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
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController? controller;
  final String? labelText;
  final String? initialValue;
  final String? hintText;
  final double fontSize;
  final double padding;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool filled;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextFormField({
    super.key,
    required this.theme,
    this.controller,
    this.labelText,
    this.initialValue,
    this.hintText,
    required this.fontSize,
    required this.padding,
    required this.isLoading,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.filled = false,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = theme.colorScheme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      enabled: enabled && !isLoading,
      style: TextStyle(fontSize: fontSize),
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: true,
        prefixIconConstraints:
            prefixIconConstraints ??
            BoxConstraints.tightFor(
              width: fontSize * 2,
              height: fontSize * 1.5,
            ),
        prefixIcon: prefixIcon,
        suffixIconConstraints:
            suffixIconConstraints ??
            BoxConstraints.tightFor(
              width: fontSize * 2,
              height: fontSize * 1.5,
            ),
        suffixIcon: suffixIcon,
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
          borderSide: BorderSide(color: greyColor!, width: 1.0),
        ),
        isDense: true,
        filled: filled,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: padding / 2,
          vertical: padding * 0.65,
        ),
      ),
    );
  }
}
