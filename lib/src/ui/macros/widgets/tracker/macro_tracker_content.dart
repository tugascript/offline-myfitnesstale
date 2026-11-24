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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/sizes/data_display_sizes.dart';
import '../../utils/tacker_scope.dart';
import 'macro_tacker_scope_widget.dart';
import 'macro_tracker_date_navigator.dart';
import 'macro_tracker_day_widget.dart';
import 'macro_tracker_scope_selection.dart';

class MacroTrackerContent extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final TrackerScope scope;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool isLoading;
  final ValueChanged<TrackerScope> onScopeChanged;
  final VoidCallback onLoadRange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDatePicked;
  final VoidCallback onGoToToday;
  final ValueChanged<DateTime> onSelectDay;

  const MacroTrackerContent({
    super.key,
    required this.sizes,
    required this.theme,
    required this.scope,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    this.isLoading = false,
    required this.onScopeChanged,
    required this.onLoadRange,
    required this.onPrevious,
    required this.onNext,
    required this.onDatePicked,
    required this.onGoToToday,
    required this.onSelectDay,
  });

  @override
  State<MacroTrackerContent> createState() => _MacroTrackerContentState();
}

class _MacroTrackerContentState extends State<MacroTrackerContent> {
  late final PageController _pageController;
  int? _animatingToPage;
  int _animationToken = 0;
  bool _isUserDragging = false;
  bool _pendingRangeLoad = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.scope.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _reconcileAndLoadSettledScope() {
    if (!_pageController.hasClients) return;
    final settledPage = _pageController.page?.round();
    if (settledPage != null &&
        settledPage >= 0 &&
        settledPage < TrackerScope.values.length) {
      final settledScope = TrackerScope.values[settledPage];
      if (settledScope != widget.scope) {
        widget.onScopeChanged(settledScope);
        _pendingRangeLoad = settledScope != TrackerScope.day;
      }
    }
    if (_pendingRangeLoad) {
      _pendingRangeLoad = false;
      widget.onLoadRange();
    }
  }

  void _animateToScope(TrackerScope targetScope) {
    if (!_pageController.hasClients) return;
    final targetPage = targetScope.index;
    final token = ++_animationToken;
    _animatingToPage = targetPage;
    _isUserDragging = false;
    _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (!mounted || token != _animationToken) return;
          _animatingToPage = null;
          if (_isUserDragging) return;
          final page = _pageController.hasClients ? _pageController.page : null;
          if (page != null && (page - page.round()).abs() > 0.01) {
            return;
          }
          _reconcileAndLoadSettledScope();
        });
  }

  void _onScopeSelected(TrackerScope newScope) {
    if (widget.scope == newScope) return;
    _pendingRangeLoad = newScope != TrackerScope.day;
    widget.onScopeChanged(newScope);
    if (_pageController.hasClients) {
      _animateToScope(newScope);
    } else if (_pendingRangeLoad) {
      _pendingRangeLoad = false;
      widget.onLoadRange();
    }
  }

  void _onUserScrollStart() {
    if (!_isUserDragging || _animatingToPage != null) {
      _isUserDragging = true;
      _animatingToPage = null;
      _animationToken++;
    }
  }

  void _onPageChanged(TrackerScope newScope) {
    if (_animatingToPage != null || widget.scope == newScope) return;
    _pendingRangeLoad = newScope != TrackerScope.day;
    widget.onScopeChanged(newScope);
  }

  void _onScopeScrollSettled() {
    _isUserDragging = false;
    if (_animatingToPage != null) return;
    _reconcileAndLoadSettledScope();
  }

  void _handlePeriodAction(VoidCallback action) {
    _pendingRangeLoad = false;
    action();
  }

  void _handleSelectDay(DateTime date) {
    final targetDate = DateUtils.dateOnly(date);
    if (targetDate.isAfter(widget.lastDate) ||
        targetDate.isBefore(widget.firstDate)) {
      return;
    }
    _pendingRangeLoad = false;
    widget.onSelectDay(targetDate);
    _animateToScope(TrackerScope.day);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = widget.sizes;
    return Skeletonizer(
      enabled: widget.isLoading,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.viewPadding,
              sizes.viewPadding,
              sizes.viewPadding,
              0,
            ),
            child: Column(
              children: [
                MacroTrackerScopeSelection(
                  sizes: sizes,
                  theme: widget.theme,
                  scope: widget.scope,
                  onScopeChanged: _onScopeSelected,
                  onGoToToday: () => _handlePeriodAction(widget.onGoToToday),
                  pageController: widget.isLoading ? null : _pageController,
                ),
                SizedBox(height: sizes.halfSpacing),
                MacroTrackerDateNavigator(
                  sizes: sizes,
                  scope: widget.scope,
                  selectedDate: widget.selectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  canGoPrevious:
                      !widget.isLoading &&
                      widget.scope.canGoPrevious(
                        widget.selectedDate,
                        widget.firstDate,
                      ),
                  canGoNext:
                      !widget.isLoading &&
                      widget.scope.canGoNext(
                        widget.selectedDate,
                        widget.lastDate,
                      ),
                  onPrevious: () => _handlePeriodAction(widget.onPrevious),
                  onNext: () => _handlePeriodAction(widget.onNext),
                  onDatePicked: (date) =>
                      _handlePeriodAction(() => widget.onDatePicked(date)),
                ),
              ],
            ),
          ),
          SizedBox(height: sizes.spacing),
          ColoredBox(
            color: widget.theme.colorScheme.surface,
            child: SizedBox(
              height: sizes.quarterSpacing,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: widget.isLoading
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      sizes.viewPadding,
                      0,
                      sizes.viewPadding,
                      sizes.viewPadding,
                    ),
                    child: MacroTrackerDayWidget(
                      theme: widget.theme,
                      sizes: sizes,
                      selectedDate: widget.selectedDate,
                    ),
                  )
                : MacroTackerScopeWidget(
                    sizes: sizes,
                    theme: widget.theme,
                    selectedDate: widget.selectedDate,
                    onSelectDate: _handleSelectDay,
                    pageController: _pageController,
                    onScopeChanged: _onPageChanged,
                    onUserScrollStart: _onUserScrollStart,
                    onScrollSettled: _onScopeScrollSettled,
                  ),
          ),
        ],
      ),
    );
  }
}
