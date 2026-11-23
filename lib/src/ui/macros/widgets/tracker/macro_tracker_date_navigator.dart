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

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/sizes/data_display_sizes.dart';
import '../../utils/tacker_scope.dart';

class MacroTrackerDateNavigator extends StatelessWidget {
  static final _dayFormat = DateFormat('EEE, MMM d, yyyy');
  static final _weekBoundFormat = DateFormat('MMM d');
  static final _monthFormat = DateFormat('MMMM yyyy');

  final DataDisplaySizesList sizes;
  final TrackerScope scope;
  final DateTime selectedDate;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDatePicked;

  const MacroTrackerDateNavigator({
    super.key,
    required this.sizes,
    required this.scope,
    required this.selectedDate,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onDatePicked,
  });

  String _formatHeaderDate() {
    switch (scope) {
      case TrackerScope.day:
        return _dayFormat.format(selectedDate);
      case TrackerScope.week:
        final start = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - (selectedDate.weekday - 1),
        );
        final end = DateTime(start.year, start.month, start.day + 6);
        return '${_weekBoundFormat.format(start)} - ${_weekBoundFormat.format(end)}';
      case TrackerScope.month:
        return _monthFormat.format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const ValueKey('macro-tracker-prev-btn'),
          icon: Icon(Icons.chevron_left, size: sizes.buttonIconSize),
          onPressed: onPrevious,
        ),
        Expanded(
          child: TextButton(
            key: const ValueKey('macro-tracker-date-btn'),
            onPressed: () async {
              final now = DateTime.now();
              final today = DateUtils.dateOnly(now);
              final initialDate = selectedDate.isAfter(today)
                  ? today
                  : selectedDate;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now,
              );
              if (picked != null) {
                onDatePicked(picked);
              }
            },
            child: Text(
              _formatHeaderDate(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('macro-tracker-next-btn'),
          icon: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}
