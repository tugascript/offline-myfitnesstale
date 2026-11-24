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

import '../../../data/repositories/meal_plans/dtos/meal_plan_record_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../meal_plans/view_models/meal_plan_cubit.dart';
import '../../meal_plans/view_models/meal_plan_record_cubit.dart';
import '../../meal_plans/view_models/states/meal_plan_record_state.dart';
import '../utils/tacker_scope.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';
import '../widgets/log_food_modal.dart';
import '../widgets/tracker/macro_tacker_scope_widget.dart';
import '../widgets/tracker/macro_tracker_date_navigator.dart';
import '../widgets/tracker/macro_tracker_scope_selection.dart';

class MacroTrackerScreen extends StatefulWidget {
  static const name = 'macro_tracker';
  final bool isVisible;
  final DateTime Function()? now;

  const MacroTrackerScreen({super.key, this.isVisible = true, this.now});

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
  bool _hasMountedListeners = false;

  DateTime _currentNow() => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentNow();
    _pageController = PageController(initialPage: _scope.index);
    _reconcileTrackerData(
      retryFailedGoal: widget.isVisible,
      retryFailedMealPlanRecord: widget.isVisible,
    );
  }

  @override
  void didUpdateWidget(MacroTrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        retryFailedMealPlanRecord: true,
        reconcileRange: _scope != TrackerScope.day,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncActiveMealPlanRecord({required bool retryFailedRecord}) {
    final recordCubit = context.read<MealPlanRecordCubit>();
    final recordState = recordCubit.state;
    if (recordState.hasLoadedActiveRecord) {
      _syncActiveMealPlan(recordState.activeRecord);
    } else if (!recordState.isLoading &&
        (recordState.error == null || retryFailedRecord)) {
      final previousRecord = recordState.activeRecord;
      final loadFuture = recordCubit.getActiveMealPlanRecord();
      final changedBeforeListenerMount =
          !_hasMountedListeners &&
          recordCubit.state.activeRecord != previousRecord;
      loadFuture.then((_) {
        if (!mounted) return;
        final latestRecord = recordCubit.state.activeRecord;
        if (changedBeforeListenerMount || latestRecord == previousRecord) {
          _syncActiveMealPlan(latestRecord);
        }
      });
    }
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

  Future<void> _reconcileTrackerData({
    required bool retryFailedGoal,
    required bool retryFailedMealPlanRecord,
    bool reconcileRange = false,
  }) async {
    _syncActiveMealPlanRecord(retryFailedRecord: retryFailedMealPlanRecord);

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

    final macroState = macroCubit.state;
    final needsDailyLog =
        macroState.selectedDailyLog == null ||
        (widget.isVisible &&
            !DateUtils.isSameDay(macroState.selectedDate, _selectedDate));
    if (needsDailyLog) {
      macroCubit.getDailyLog(_selectedDate);
    }
    if (rangeToken != null &&
        rangeToken == _rangeLoadToken &&
        _scope != TrackerScope.day) {
      _dispatchRangeLoad(macroCubit);
    }
  }

  void _syncActiveMealPlan(MealPlanRecordDto? record) {
    if (record == null) return;
    final mealPlanCubit = context.read<MealPlanCubit>();
    final plan = mealPlanCubit.state.activeMealPlan;
    if (plan?.id != record.mealPlanId ||
        plan?.version != record.mealPlanVersion) {
      mealPlanCubit.getActiveMealPlan(
        record.mealPlanId,
        version: record.mealPlanVersion,
      );
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
        rangeToken != _rangeLoadToken ||
        _scope == TrackerScope.day) {
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
    if (!mounted || periodToken != _periodLoadToken) return;
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
    _hasMountedListeners = true;
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    final today = _today;
    final minDate = _minDate(today);

    return MultiBlocListener(
      listeners: [
        BlocListener<MealPlanRecordCubit, MealPlanRecordState>(
          listenWhen: (previous, current) =>
              previous.activeRecord != current.activeRecord,
          listener: (context, state) {
            _syncActiveMealPlan(state.activeRecord);
          },
        ),
        BlocListener<MacroTrackingCubit, MacroTrackingState>(
          listenWhen: (previous, current) =>
              !previous.hasLoadedActiveGoal && current.hasLoadedActiveGoal,
          listener: (context, state) {
            if (!_deferredInitialLogLoad) return;
            _deferredInitialLogLoad = false;
            final latest = context.read<MacroTrackingCubit>().state;
            if (latest.isLoadingActiveGoal) return;
            final needsDailyLog =
                latest.selectedDailyLog == null ||
                (widget.isVisible &&
                    !DateUtils.isSameDay(latest.selectedDate, _selectedDate));
            final needsRange = widget.isVisible && _scope != TrackerScope.day;
            if (needsDailyLog || needsRange) {
              _reconcileTrackerData(
                retryFailedGoal: false,
                retryFailedMealPlanRecord: false,
                reconcileRange: needsRange,
              );
            }
          },
        ),
      ],
      child: AppScaffold(
        title: 'Macro Tracker',
        body: Column(
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
        ),
        floatingActionButton: FloatingActionButton(
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
        ),
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
