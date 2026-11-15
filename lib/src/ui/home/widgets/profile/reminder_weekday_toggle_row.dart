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
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/layout/sharp_switch.dart';

class ReminderWeekdayToggleRow extends StatefulWidget {
  final bool value;
  final String label;
  final DayOfWeek dayOfWeek;
  final String timeLabel;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Color titleColor;
  final bool isLoading;
  final ValueChanged<bool> onChanged;
  final ValueChanged<DayOfWeek> onDayChanged;
  final VoidCallback onTimeTap;
  final Key switchKey;
  final Key dayKey;
  final Key timeKey;

  const ReminderWeekdayToggleRow({
    super.key,
    required this.switchKey,
    required this.dayKey,
    required this.timeKey,
    required this.value,
    required this.label,
    required this.dayOfWeek,
    required this.timeLabel,
    required this.sizes,
    required this.theme,
    required this.titleColor,
    required this.isLoading,
    required this.onChanged,
    required this.onDayChanged,
    required this.onTimeTap,
  });

  static String abbreviateDay(DayOfWeek day) {
    final name = day.name;
    return '${name[0].toUpperCase()}${name.substring(1, 3)}';
  }

  @override
  State<ReminderWeekdayToggleRow> createState() =>
      _ReminderWeekdayToggleRowState();
}

class _ReminderWeekdayToggleRowState extends State<ReminderWeekdayToggleRow> {
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.timeLabel);
  }

  @override
  void didUpdateWidget(ReminderWeekdayToggleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeLabel != widget.timeLabel &&
        _timeController.text != widget.timeLabel) {
      _timeController.text = widget.timeLabel;
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: widget.sizes.profileLabelWidth,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: widget.titleColor,
            ),
          ),
        ),
        SharpSwitch(
          key: widget.switchKey,
          value: widget.value,
          onChanged: widget.onChanged,
          thumbSize: widget.sizes.subtitleFontSize,
          padding: EdgeInsets.all(widget.sizes.halfSpacing),
        ),
        SizedBox(width: widget.sizes.halfSpacing),
        Expanded(
          child: KeyedSubtree(
            key: widget.dayKey,
            child: AppDropdown<DayOfWeek>(
              key: ValueKey(widget.dayOfWeek),
              theme: widget.theme,
              filled: true,
              value: widget.dayOfWeek,
              emptyLabel: '',
              showEmptyValue: false,
              items: DayOfWeek.values,
              labelBuilder: ReminderWeekdayToggleRow.abbreviateDay,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.halfSpacing,
              isLoading: widget.isLoading,
              enabled: widget.value,
              prefixIcon: Icon(
                Icons.calendar_today,
                size: widget.sizes.iconFontSize,
              ),
              onChanged: (day) {
                if (day != null) {
                  widget.onDayChanged(day);
                }
              },
              onSaved: (_) {},
            ),
          ),
        ),
        SizedBox(width: widget.sizes.halfSpacing),
        Expanded(
          child: AppTextFormField(
            key: widget.timeKey,
            theme: widget.theme,
            controller: _timeController,
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.halfSpacing,
            isLoading: widget.isLoading,
            enabled: widget.value,
            readOnly: true,
            filled: true,
            onTap: widget.value ? widget.onTimeTap : null,
            prefixIcon: Icon(
              Icons.access_time,
              size: widget.sizes.iconFontSize,
            ),
          ),
        ),
      ],
    );
  }
}
