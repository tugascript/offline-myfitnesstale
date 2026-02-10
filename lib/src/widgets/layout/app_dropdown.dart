import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final bool filled;
  final T? value;
  final String label;
  final List<T> items;
  final void Function(T?) onChanged;
  final void Function(T?) onSaved;
  final String? Function(T?)? validator;

  final String Function(T) labelBuilder;
  final double fontSize;
  final double padding;

  const AppDropdown({
    super.key,
    this.filled = false,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.onSaved,
    required this.labelBuilder,
    required this.fontSize,
    required this.padding,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T?>(
      isExpanded: true,
      isDense: true,
      iconSize: fontSize,
      style: TextStyle(
        fontSize: fontSize,
        color: theme.textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        filled: filled,
        fillColor: filled ? theme.scaffoldBackgroundColor : null,
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
          horizontal: padding,
          vertical: padding,
        ),
      ),
      initialValue: value,
      items: [
        DropdownMenuItem<T?>(
          value: null,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        ...items.map(
          (i) => DropdownMenuItem<T?>(
            value: i,
            child: Text(
              labelBuilder(i),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        )
      ],
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
