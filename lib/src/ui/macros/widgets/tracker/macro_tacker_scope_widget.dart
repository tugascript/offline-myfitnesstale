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
import '../../utils/tacker_scope.dart';
import 'macro_tracker_day_widget.dart';
import 'macro_tracker_month_widget.dart';
import 'macro_tracker_week_widget.dart';

class MacroTackerScopeWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final PageController pageController;
  final ValueChanged<TrackerScope> onScopeChanged;
  final VoidCallback onScrollSettled;

  const MacroTackerScopeWidget({
    super.key,
    required this.sizes,
    required this.theme,
    required this.selectedDate,
    required this.onSelectDate,
    required this.pageController,
    required this.onScopeChanged,
    required this.onScrollSettled,
  });

  @override
  Widget build(BuildContext context) {
    final pagePadding = EdgeInsets.fromLTRB(
      sizes.viewPadding,
      0,
      sizes.viewPadding,
      sizes.viewPadding,
    );

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification.metrics.axis == Axis.horizontal) {
          onScrollSettled();
        }
        return false;
      },
      child: PageView(
        key: const ValueKey('macro-tracker-scope-pager'),
        controller: pageController,
        allowImplicitScrolling: true,
        onPageChanged: (index) => onScopeChanged(TrackerScope.values[index]),
        children: [
          _KeepAliveScopePage(
            padding: pagePadding,
            child: MacroTrackerDayWidget(
              theme: theme,
              sizes: sizes,
              selectedDate: selectedDate,
            ),
          ),
          _KeepAliveScopePage(
            padding: pagePadding,
            child: MacroTrackerWeekWidget(
              theme: theme,
              sizes: sizes,
              selectedDate: selectedDate,
              onSelectDate: onSelectDate,
            ),
          ),
          _KeepAliveScopePage(
            padding: pagePadding,
            child: MacroTrackerMonthWidget(
              theme: theme,
              sizes: sizes,
              selectedDate: selectedDate,
              onSelectDate: onSelectDate,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepAliveScopePage extends StatefulWidget {
  final EdgeInsets padding;
  final Widget child;

  const _KeepAliveScopePage({required this.padding, required this.child});

  @override
  State<_KeepAliveScopePage> createState() => _KeepAliveScopePageState();
}

class _KeepAliveScopePageState extends State<_KeepAliveScopePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: Padding(padding: widget.padding, child: widget.child),
    );
  }
}
