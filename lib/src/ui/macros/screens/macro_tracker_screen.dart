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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/utils/dates.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../utils/macro_goal_form_defaults.dart';
import '../utils/tacker_scope.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';
import '../widgets/goals/macro_goal_form_modal.dart';
import '../widgets/log_food_modal.dart';
import '../widgets/tracker/macro_tacker_scope_widget.dart';
import '../widgets/tracker/macro_tracker_date_navigator.dart';
import '../widgets/tracker/macro_tracker_placeholder.dart';
import '../widgets/tracker/macro_tracker_scope_selection.dart';

class MacroTrackerScreen extends StatefulWidget {
  static const name = 'macro_tracker';
  final bool isVisible;
  final int goalPromptTrigger;
  final DateTime Function()? now;

  const MacroTrackerScreen({
    super.key,
    this.isVisible = true,
    this.goalPromptTrigger = 0,
    this.now,
  });

  @override
  State<MacroTrackerScreen> createState() => _MacroTrackerScreenState();
}

class _MacroTrackerScreenState extends State<MacroTrackerScreen> {
  TrackerScope _scope = TrackerScope.day;
  late DateTime _selectedDate;
  bool _hasCustomSelectedDate = false;
  late final PageController _pageController;
  int? _animatingToPage;
  int _animationToken = 0;
  bool _isUserDragging = false;
  bool _pendingRangeLoad = false;
  int _periodLoadToken = 0;
  int _rangeLoadToken = 0;
  bool _deferredInitialLogLoad = false;
  int _handledGoalPromptTrigger = 0;
  bool _isGoalModalOpen = false;

  DateTime _currentNow() => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentNow();
    _pageController = PageController(initialPage: _scope.index);
    _reconcileTrackerData(retryFailedGoal: widget.isVisible);
  }

  @override
  void didUpdateWidget(MacroTrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isVisible && oldWidget.isVisible) {
      _handledGoalPromptTrigger = widget.goalPromptTrigger;
      return;
    }
    if (widget.isVisible && !oldWidget.isVisible) {
      final currentNow = _currentNow();
      final today = DateUtils.dateOnly(currentNow);
      final minDate = _minDate(today);
      if (!_hasCustomSelectedDate &&
          !DateUtils.isSameDay(_selectedDate, today)) {
        _selectedDate = currentNow;
      } else if (DateUtils.dateOnly(_selectedDate).isBefore(minDate)) {
        _selectedDate = minDate;
      } else if (DateUtils.dateOnly(_selectedDate).isAfter(today)) {
        _selectedDate = currentNow;
        _hasCustomSelectedDate = false;
      }
      _reconcileTrackerData(
        retryFailedGoal: true,
        reconcileRange: _scope != TrackerScope.day,
      );
    } else if (widget.isVisible &&
        widget.goalPromptTrigger != oldWidget.goalPromptTrigger) {
      _reconcileTrackerData(
        retryFailedGoal: true,
        reconcileRange: _scope != TrackerScope.day,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCreateMacroGoalModal() async {
    if (!mounted || _isGoalModalOpen) return;
    _isGoalModalOpen = true;
    final theme = Theme.of(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      BreakPoint.fromContext(context).screenSize,
    );
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => MacroGoalFormModal(
          theme: theme,
          sizes: sizes,
          defaults: MacroGoalFormDefaults.recommended2000Kcal,
        ),
      );
    } finally {
      _isGoalModalOpen = false;
    }
  }

  void _scheduleGoalPromptIfNeeded(MacroTrackingState state) {
    if (!mounted || !widget.isVisible) return;
    if (widget.goalPromptTrigger <= _handledGoalPromptTrigger) return;
    if (!state.hasLoadedActiveGoal ||
        state.isLoadingActiveGoal ||
        state.isLoading) {
      return;
    }

    _handledGoalPromptTrigger = widget.goalPromptTrigger;
    if (state.activeGoal != null || _isGoalModalOpen) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isVisible || _isGoalModalOpen) return;
      final latest = context.read<MacroTrackingCubit>().state;
      if (!latest.hasLoadedActiveGoal ||
          latest.isLoadingActiveGoal ||
          latest.isLoading ||
          latest.activeGoal != null) {
        return;
      }
      _openCreateMacroGoalModal();
    });
  }

  Future<bool> _ensureActiveGoalReady(
    MacroTrackingCubit macroCubit, {
    required bool retryFailedGoal,
  }) async {
    final waitedForInFlight = macroCubit.state.isLoadingActiveGoal;
    if (waitedForInFlight) {
      await macroCubit.stream.firstWhere(
        (state) => !state.isLoadingActiveGoal,
        orElse: () => macroCubit.state,
      );
      if (!mounted || macroCubit.isClosed) return false;
    }

    var macroState = macroCubit.state;
    if (!waitedForInFlight &&
        !macroState.hasLoadedActiveGoal &&
        !macroState.isLoadingActiveGoal &&
        (macroState.error == null || retryFailedGoal)) {
      _deferredInitialLogLoad = false;
      await macroCubit.getActiveMacroGoal();
      if (!mounted) return false;
      macroState = macroCubit.state;
    }

    // Do not issue daily or range log queries while active-goal loading is in
    // an error state; a successful log query clears MacroTrackingState.error
    // and would dismiss Home's active-load retry card.
    if (!macroState.hasLoadedActiveGoal && macroState.error != null) {
      _deferredInitialLogLoad = true;
      return false;
    }
    _deferredInitialLogLoad = false;
    return true;
  }

  bool _hasMatchingDailyLog(MacroTrackingState state) {
    final dailyLog = state.selectedDailyLog;
    return dailyLog != null &&
        dailyLog.date == DateUtilities.getNumericDate(_selectedDate) &&
        DateUtils.isSameDay(state.selectedDate, _selectedDate);
  }

  Future<void> _reconcileTrackerData({
    required bool retryFailedGoal,
    bool reconcileRange = false,
  }) async {
    final periodToken = ++_periodLoadToken;
    final rangeToken = reconcileRange ? ++_rangeLoadToken : null;
    final macroCubit = context.read<MacroTrackingCubit>();
    if (!await _ensureActiveGoalReady(
      macroCubit,
      retryFailedGoal: retryFailedGoal,
    )) {
      return;
    }
    if (!mounted || periodToken != _periodLoadToken) return;
    if (!widget.isVisible) return;

    final macroState = macroCubit.state;
    if (macroState.activeGoal == null) {
      _scheduleGoalPromptIfNeeded(macroState);
      return;
    }
    if (widget.goalPromptTrigger > _handledGoalPromptTrigger) {
      _handledGoalPromptTrigger = widget.goalPromptTrigger;
    }

    if (!_hasMatchingDailyLog(macroState)) {
      macroCubit.getDailyLog(_selectedDate);
    }
    if (rangeToken != null &&
        rangeToken == _rangeLoadToken &&
        _scope != TrackerScope.day) {
      _dispatchRangeLoad(macroCubit);
    }
  }

  void _dispatchRangeLoad(MacroTrackingCubit macroCubit) {
    if (_scope == TrackerScope.week) {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day - (_selectedDate.weekday - 1),
      );
      final end = DateTime(start.year, start.month, start.day + 6);
      macroCubit.getDailyLogsForRange(start: start, end: end);
    } else if (_scope == TrackerScope.month) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      macroCubit.getDailyLogsForRange(start: start, end: end);
    }
  }

  Future<void> _loadRangeForCurrentScope() async {
    if (_scope == TrackerScope.day) return;
    final rangeToken = ++_rangeLoadToken;
    final macroCubit = context.read<MacroTrackingCubit>();
    if (!await _ensureActiveGoalReady(
      macroCubit,
      retryFailedGoal: widget.isVisible,
    )) {
      return;
    }
    if (!mounted ||
        !widget.isVisible ||
        rangeToken != _rangeLoadToken ||
        _scope == TrackerScope.day ||
        macroCubit.state.activeGoal == null) {
      return;
    }
    _dispatchRangeLoad(macroCubit);
  }

  Future<void> _loadPeriodData() async {
    _pendingRangeLoad = false;
    final periodToken = ++_periodLoadToken;
    final rangeToken = ++_rangeLoadToken;
    final macroCubit = context.read<MacroTrackingCubit>();
    if (!await _ensureActiveGoalReady(
      macroCubit,
      retryFailedGoal: widget.isVisible,
    )) {
      return;
    }
    if (!mounted ||
        !widget.isVisible ||
        periodToken != _periodLoadToken ||
        macroCubit.state.activeGoal == null) {
      return;
    }
    macroCubit.getDailyLog(_selectedDate);
    if (rangeToken == _rangeLoadToken && _scope != TrackerScope.day) {
      _dispatchRangeLoad(macroCubit);
    }
  }

  void _reconcileAndLoadSettledScope() {
    if (!_pageController.hasClients) return;
    final settledPage = _pageController.page?.round();
    if (settledPage != null &&
        settledPage >= 0 &&
        settledPage < TrackerScope.values.length) {
      final settledScope = TrackerScope.values[settledPage];
      if (settledScope != _scope) {
        setState(() {
          _scope = settledScope;
        });
        _pendingRangeLoad = settledScope != TrackerScope.day;
      }
    }
    if (_pendingRangeLoad) {
      _pendingRangeLoad = false;
      _loadRangeForCurrentScope();
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

  void _onScopeChanged(TrackerScope newScope) {
    if (_scope == newScope) return;
    _pendingRangeLoad = newScope != TrackerScope.day;
    setState(() {
      _scope = newScope;
    });
    if (_pageController.hasClients) {
      _animateToScope(newScope);
    } else if (_pendingRangeLoad) {
      _pendingRangeLoad = false;
      _loadRangeForCurrentScope();
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
    if (_animatingToPage != null) {
      return;
    }
    if (_scope == newScope) return;
    _pendingRangeLoad = newScope != TrackerScope.day;
    setState(() {
      _scope = newScope;
    });
  }

  void _onScopeScrollSettled() {
    _isUserDragging = false;
    if (_animatingToPage != null) return;
    _reconcileAndLoadSettledScope();
  }

  DateTime get _today => DateUtils.dateOnly(_currentNow());

  DateTime _minDate(DateTime today) =>
      MacroTrackerDateNavigator.defaultFirstDate(today);

  bool get _canGoPrevious {
    final today = _today;
    final minDate = _minDate(today);
    final selected = DateUtils.dateOnly(_selectedDate);
    final DateTime previousPeriodEnd;
    switch (_scope) {
      case TrackerScope.day:
        previousPeriodEnd = DateTime(
          selected.year,
          selected.month,
          selected.day - 1,
        );
      case TrackerScope.week:
        final weekStart = DateTime(
          selected.year,
          selected.month,
          selected.day - (selected.weekday - 1),
        );
        previousPeriodEnd = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day - 1,
        );
      case TrackerScope.month:
        previousPeriodEnd = DateTime(selected.year, selected.month, 0);
    }
    return !previousPeriodEnd.isBefore(minDate);
  }

  bool get _canGoNext {
    final today = _today;
    final selected = DateUtils.dateOnly(_selectedDate);
    final DateTime nextPeriodStart;
    switch (_scope) {
      case TrackerScope.day:
        nextPeriodStart = DateTime(
          selected.year,
          selected.month,
          selected.day + 1,
        );
      case TrackerScope.week:
        final weekStart = DateTime(
          selected.year,
          selected.month,
          selected.day - (selected.weekday - 1),
        );
        nextPeriodStart = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 7,
        );
      case TrackerScope.month:
        nextPeriodStart = DateTime(selected.year, selected.month + 1, 1);
    }
    return !nextPeriodStart.isAfter(today);
  }

  void _prevPeriod() {
    if (!_canGoPrevious) return;
    final today = _today;
    final minDate = _minDate(today);
    DateTime prevDate;
    switch (_scope) {
      case TrackerScope.day:
        prevDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 1,
        );
      case TrackerScope.week:
        prevDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 7,
        );
      case TrackerScope.month:
        prevDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    }
    if (prevDate.isBefore(minDate)) {
      prevDate = minDate;
    }
    setState(() {
      _selectedDate = prevDate;
      _hasCustomSelectedDate = !DateUtils.isSameDay(prevDate, today);
    });
    _loadPeriodData();
  }

  void _nextPeriod() {
    if (!_canGoNext) return;
    final today = _today;
    final minDate = _minDate(today);
    DateTime nextDate;
    switch (_scope) {
      case TrackerScope.day:
        nextDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + 1,
        );
      case TrackerScope.week:
        nextDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + 7,
        );
      case TrackerScope.month:
        nextDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }
    if (nextDate.isAfter(today)) {
      nextDate = today;
    } else if (nextDate.isBefore(minDate)) {
      nextDate = minDate;
    }
    setState(() {
      _selectedDate = nextDate;
      _hasCustomSelectedDate = !DateUtils.isSameDay(nextDate, today);
    });
    _loadPeriodData();
  }

  void _onDatePicked(DateTime picked) {
    final today = _today;
    final minDate = _minDate(today);
    final pickedDate = DateUtils.dateOnly(picked);
    if (pickedDate.isAfter(today) || pickedDate.isBefore(minDate)) return;
    setState(() {
      _selectedDate = pickedDate;
      _hasCustomSelectedDate = !DateUtils.isSameDay(pickedDate, today);
    });
    _loadPeriodData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = _currentNow();
      _hasCustomSelectedDate = false;
    });
    _loadPeriodData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    final today = _today;
    final minDate = _minDate(today);

    return MultiBlocListener(
      listeners: [
        BlocListener<MacroTrackingCubit, MacroTrackingState>(
          listenWhen: (previous, current) =>
              !previous.hasLoadedActiveGoal && current.hasLoadedActiveGoal,
          listener: (context, state) {
            if (state.activeGoal == null) {
              _deferredInitialLogLoad = false;
              if (!widget.isVisible) return;
              final latest = context.read<MacroTrackingCubit>().state;
              if (latest.isLoadingActiveGoal) return;
              _scheduleGoalPromptIfNeeded(latest);
              return;
            }

            if (!_deferredInitialLogLoad) return;
            _deferredInitialLogLoad = false;
            if (!widget.isVisible) return;
            final latest = context.read<MacroTrackingCubit>().state;
            if (latest.isLoadingActiveGoal) return;
            final needsDailyLog = !_hasMatchingDailyLog(latest);
            final needsRange = _scope != TrackerScope.day;
            if (needsDailyLog || needsRange) {
              _reconcileTrackerData(
                retryFailedGoal: false,
                reconcileRange: needsRange,
              );
            }
          },
        ),
        BlocListener<MacroTrackingCubit, MacroTrackingState>(
          listenWhen: (previous, current) =>
              previous.hasLoadedActiveGoal &&
              ((previous.activeGoal == null) != (current.activeGoal == null)),
          listener: (context, state) {
            if (state.activeGoal == null) {
              if (_scope != TrackerScope.day) {
                setState(() {
                  _scope = TrackerScope.day;
                });
              }
              return;
            }

            if (!widget.isVisible) return;
            final latest = context.read<MacroTrackingCubit>().state;
            if (latest.isLoadingActiveGoal) return;
            final needsDailyLog = !_hasMatchingDailyLog(latest);
            final needsRange = _scope != TrackerScope.day;
            if (needsDailyLog || needsRange) {
              _reconcileTrackerData(
                retryFailedGoal: false,
                reconcileRange: needsRange,
              );
            }
          },
        ),
        BlocListener<MacroTrackingCubit, MacroTrackingState>(
          listenWhen: (previous, current) =>
              previous.error != current.error &&
              current.error != null &&
              current.hasLoadedActiveGoal &&
              !current.isLoading,
          listener: (context, state) {
            if (!widget.isVisible) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!.description,
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
        buildWhen: (previous, current) =>
            (previous.activeGoal == null) != (current.activeGoal == null) ||
            previous.hasLoadedActiveGoal != current.hasLoadedActiveGoal ||
            previous.isLoadingActiveGoal != current.isLoadingActiveGoal ||
            previous.isLoading != current.isLoading ||
            previous.error != current.error,
        builder: (context, state) {
          final hasActiveGoal = state.activeGoal != null;
          final hasInitialGoalError =
              !hasActiveGoal &&
              !state.hasLoadedActiveGoal &&
              state.error != null;
          final isWaitingForGoal =
              !hasActiveGoal &&
              !state.hasLoadedActiveGoal &&
              state.isLoadingActiveGoal;

          final Widget body;
          if (hasActiveGoal) {
            body = Column(
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
                        theme: theme,
                        scope: _scope,
                        onScopeChanged: _onScopeChanged,
                        onGoToToday: _goToToday,
                        pageController: _pageController,
                      ),
                      SizedBox(height: sizes.halfSpacing),
                      MacroTrackerDateNavigator(
                        sizes: sizes,
                        scope: _scope,
                        selectedDate: _selectedDate,
                        firstDate: minDate,
                        lastDate: today,
                        canGoPrevious: _canGoPrevious,
                        canGoNext: _canGoNext,
                        onPrevious: _prevPeriod,
                        onNext: _nextPeriod,
                        onDatePicked: _onDatePicked,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                // Scope Body
                Expanded(
                  child: MacroTackerScopeWidget(
                    sizes: sizes,
                    theme: theme,
                    selectedDate: _selectedDate,
                    onSelectDate: _selectDay,
                    pageController: _pageController,
                    onScopeChanged: _onPageChanged,
                    onUserScrollStart: _onUserScrollStart,
                    onScrollSettled: _onScopeScrollSettled,
                  ),
                ),
              ],
            );
          } else if (hasInitialGoalError) {
            body = Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: MacroTrackerPlaceholder(
                sizes: sizes,
                errorDescription: state.error!.description,
                isLoading: state.isLoadingActiveGoal,
                onRetry: () => _reconcileTrackerData(
                  retryFailedGoal: true,
                  reconcileRange: _scope != TrackerScope.day,
                ),
              ),
            );
          } else if (isWaitingForGoal) {
            body = const Center(child: CircularProgressIndicator());
          } else {
            body = Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: MacroTrackerPlaceholder(
                sizes: sizes,
                isLoading: state.isLoading,
                onCreateGoal: _openCreateMacroGoalModal,
              ),
            );
          }

          return AppScaffold(
            title: 'Macro Tracker',
            body: body,
            floatingActionButton: hasActiveGoal
                ? FloatingActionButton(
                    key: const ValueKey('macro-tracker-log-food-fab'),
                    tooltip: 'Log Food',
                    shape: BeveledRectangleBorder(),
                    child: Icon(Icons.add, size: sizes.buttonIconSize),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => LogFoodModal(
                          theme: theme,
                          sizes: sizes,
                          selectedDate: _selectedDate,
                        ),
                      );
                    },
                  )
                : null,
          );
        },
      ),
    );
  }

  void _selectDay(DateTime date) {
    final today = _today;
    final minDate = _minDate(today);
    final targetDate = DateUtils.dateOnly(date);
    if (targetDate.isAfter(today) || targetDate.isBefore(minDate)) return;
    setState(() {
      _selectedDate = targetDate;
      _hasCustomSelectedDate = !DateUtils.isSameDay(targetDate, today);
      _scope = TrackerScope.day;
    });
    _animateToScope(TrackerScope.day);
    _loadPeriodData();
  }
}
