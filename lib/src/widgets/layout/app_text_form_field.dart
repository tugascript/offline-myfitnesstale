import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController? controller;
  final String? labelText;
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
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextFormField({
    super.key,
    required this.theme,
    this.controller,
    this.labelText,
    this.hintText,
    required this.fontSize,
    required this.padding,
    required this.isLoading,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.filled = false,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = theme.colorScheme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    return TextFormField(
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      enabled: !isLoading,
      style: TextStyle(
        fontSize: fontSize,
      ),
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: true,
        prefixIconConstraints: BoxConstraints.tightFor(
          width: fontSize * 2,
          height: fontSize * 1.5,
        ),
        prefixIcon: prefixIcon,
        suffixIconConstraints: BoxConstraints.tightFor(
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
          borderSide: BorderSide(
            color: greyColor!,
            width: 1.0,
          ),
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
