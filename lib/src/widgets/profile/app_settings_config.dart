import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/system_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/expanding_section.dart';

class AppSettingsConfig extends StatelessWidget {
  final SystemDto system;
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const AppSettingsConfig({
    super.key,
    required this.system,
    required this.isLoading,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final labelWidth = sizes.subtitleFontSize * 7;
    return ExpandingSection(
      icon: Icons.settings,
      title: "App Settings",
      titleFountSize: sizes.titleFountSize,
      subtitle: "${system.units.name} units • ${system.theme.name} theme",
      subtitleFontSize: sizes.subtitleFontSize,
      padding: sizes.padding / 2,
      children: [
        _SettingsSelector<Units>(
          value: system.units,
          values: Units.values,
          label: "Units",
          labelWidth: labelWidth,
          padding: sizes.padding,
          fontSize: sizes.subtitleFontSize,
          spacing: sizes.spacing,
          icon: Icons.straighten,
          isDarkTheme: isDarkTheme,
          onChanged: (Units? newValue) {
            if (!isLoading && newValue != null) {
              cubit.updateSystem(units: newValue);
            }
          },
          getIcon: _getUnitsIcon,
          getText: (Units unit) => unit.name.toUpperCase(),
          iconColor: theme.iconTheme.color,
        ),
        _SettingsSelector<ThemeType>(
          value: system.theme,
          values: ThemeType.values,
          label: "Theme",
          labelWidth: labelWidth,
          fontSize: sizes.subtitleFontSize,
          padding: sizes.padding,
          spacing: sizes.spacing,
          icon: Icons.brightness_auto,
          isDarkTheme: isDarkTheme,
          onChanged: (ThemeType? newValue) {
            if (!isLoading && newValue != null) {
              cubit.updateSystem(theme: newValue);
            }
          },
          getIcon: _getThemeIcon,
          getText: (ThemeType theme) => theme.name.toUpperCase(),
          iconColor: theme.iconTheme.color,
        ),
      ],
    );
  }

  IconData _getThemeIcon(ThemeType theme) {
    switch (theme) {
      case ThemeType.light:
        return Icons.light_mode;
      case ThemeType.dark:
        return Icons.dark_mode;
      case ThemeType.system:
        return Icons.brightness_auto;
    }
  }

  IconData _getUnitsIcon(Units unit) {
    switch (unit) {
      case Units.metric:
        return Icons.straighten;
      case Units.imperial:
        return Icons.square_foot;
    }
  }
}

class _SettingsSelector<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String label;
  final double labelWidth;
  final double fontSize;
  final double spacing;
  final double padding;
  final IconData icon;
  final bool isDarkTheme;
  final Function(T?) onChanged;
  final IconData Function(T) getIcon;
  final Color? iconColor;
  final String Function(T) getText;

  const _SettingsSelector({
    super.key,
    required this.value,
    required this.values,
    required this.label,
    required this.labelWidth,
    required this.fontSize,
    required this.padding,
    required this.spacing,
    required this.icon,
    required this.isDarkTheme,
    required this.onChanged,
    required this.getIcon,
    required this.getText,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          DropdownButton<T>(
            value: value,
            isDense: true,
            underline: Container(), // Remove underline
            items: values.map((T v) {
              return DropdownMenuItem<T>(
                value: v,
                child: SizedBox(
                  width: labelWidth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getIcon(v),
                        size: fontSize * 1.2,
                        color: iconColor,
                      ),
                      SizedBox(width: spacing),
                      Text(
                        getText(v),
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
