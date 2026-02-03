import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final double fontSize;
  final double padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    required this.fontSize,
    required this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      style: TextStyle(
        fontSize: fontSize,
      ),
      controller: controller,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
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
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: padding / 2,
          vertical: padding * 0.65,
        ),
      ),
    );
  }
}
