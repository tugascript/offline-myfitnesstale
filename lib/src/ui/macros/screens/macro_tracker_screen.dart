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
import '../widgets/log_food_modal.dart';
import '../widgets/tracker/macro_tacker_scope_widget.dart';
import '../widgets/tracker/macro_tracker_date_navigator.dart';
import '../widgets/tracker/macro_tracker_scope_selection.dart';

class MacroTrackerScreen extends StatefulWidget {
  static const name = 'macro_tracker';

  const MacroTrackerScreen({super.key});

  @override
  State<MacroTrackerScreen> createState() => _MacroTrackerScreenState();
}

class _MacroTrackerScreenState extends State<MacroTrackerScreen> {
  TrackerScope _scope = TrackerScope.day;
  DateTime _selectedDate = DateTime.now();
  late final PageController _pageController;
  int? _animatingToPage;
  int _animationToken = 0;
  bool _isUserDragging = false;
  bool _pendingRangeLoad = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _scope.index);
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final recordCubit = context.read<MealPlanRecordCubit>();
    final recordState = recordCubit.state;
    if (recordState.hasLoadedActiveRecord) {
      _syncSelectedMealPlan(recordState.activeRecord);
    } else if (!recordState.isLoading && recordState.error == null) {
      recordCubit.getActiveMealPlanRecord().then((_) {
        if (!mounted) return;
        _syncSelectedMealPlan(recordCubit.state.activeRecord);
      });
    }

    final macroCubit = context.read<MacroTrackingCubit>();
    if (macroCubit.state.isLoading) {
      await macroCubit.stream.firstWhere((state) => !state.isLoading);
      if (!mounted) return;
    }

    var macroState = macroCubit.state;
    if (!macroState.hasLoadedActiveGoal &&
        !macroState.isLoading &&
        macroState.error == null) {
      await macroCubit.getActiveMacroGoal();
      if (!mounted) return;
      macroState = macroCubit.state;
    }
    if (macroState.selectedDailyLog == null ||
        !DateUtils.isSameDay(macroState.selectedDate, _selectedDate)) {
      macroCubit.getDailyLog(_selectedDate);
    }
  }

  void _syncSelectedMealPlan(MealPlanRecordDto? record) {
    if (record == null) return;
    final mealPlanCubit = context.read<MealPlanCubit>();
    final plan = mealPlanCubit.state.selectedMealPlan;
    if (plan?.id != record.mealPlanId ||
        plan?.version != record.mealPlanVersion) {
      mealPlanCubit.getMealPlan(
        record.mealPlanId,
        version: record.mealPlanVersion,
      );
    }
  }

  void _loadRangeForCurrentScope() {
    final macroCubit = context.read<MacroTrackingCubit>();
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

  void _loadPeriodData() {
    _pendingRangeLoad = false;
    context.read<MacroTrackingCubit>().getDailyLog(_selectedDate);
    _loadRangeForCurrentScope();
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

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

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
    });
    _loadPeriodData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
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

    return BlocListener<MealPlanRecordCubit, MealPlanRecordState>(
      listenWhen: (previous, current) =>
          previous.activeRecord != current.activeRecord,
      listener: (context, state) {
        _syncSelectedMealPlan(state.activeRecord);
      },
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
      _scope = TrackerScope.day;
    });
    _animateToScope(TrackerScope.day);
    _loadPeriodData();
  }
}
