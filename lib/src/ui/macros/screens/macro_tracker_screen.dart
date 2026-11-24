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
import '../../core/view_models/states/common_state.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../utils/macro_goal_form_defaults.dart';
import '../utils/tacker_scope.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';
import '../widgets/goals/macro_goal_form_modal.dart';
import '../widgets/log_food_modal.dart';
import '../widgets/tracker/macro_tracker_body.dart';
import '../widgets/tracker/macro_tracker_date_navigator.dart';

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
  int _dailyLoadToken = 0;
  int _rangeLoadToken = 0;
  bool _deferredInitialLogLoad = false;
  bool _hadLoadedActiveGoal = false;
  bool _hadActiveGoal = false;
  ErrorState? _lastShownError;
  int _handledGoalPromptTrigger = 0;
  bool _isGoalModalOpen = false;
  bool _isGoalPromptScheduled = false;

  DateTime _currentNow() => widget.now?.call() ?? DateTime.now();

  DateTime get _today => DateUtils.dateOnly(_currentNow());

  DateTime _minDate(DateTime today) =>
      MacroTrackerDateNavigator.defaultFirstDate(today);

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentNow();
    final state = context.read<MacroTrackingCubit>().state;
    _hadLoadedActiveGoal = state.hasLoadedActiveGoal;
    _hadActiveGoal = state.activeGoal != null;
    _loadTrackerData(retryFailedGoal: widget.isVisible);
  }

  @override
  void didUpdateWidget(MacroTrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isVisible && oldWidget.isVisible) {
      return;
    }
    if (widget.isVisible && !oldWidget.isVisible) {
      _rebaseSelectedDate();
      _loadTrackerData(
        retryFailedGoal: true,
        loadRange: _scope != TrackerScope.day,
      );
    } else if (widget.isVisible &&
        widget.goalPromptTrigger != oldWidget.goalPromptTrigger) {
      _loadTrackerData(
        retryFailedGoal: true,
        loadRange: _scope != TrackerScope.day,
      );
    }
  }

  void _rebaseSelectedDate() {
    final currentNow = _currentNow();
    final today = DateUtils.dateOnly(currentNow);
    final minDate = _minDate(today);
    if (!_hasCustomSelectedDate && !DateUtils.isSameDay(_selectedDate, today)) {
      _selectedDate = currentNow;
    } else if (DateUtils.dateOnly(_selectedDate).isBefore(minDate)) {
      _selectedDate = minDate;
    } else if (DateUtils.dateOnly(_selectedDate).isAfter(today)) {
      _selectedDate = currentNow;
      _hasCustomSelectedDate = false;
    }
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

    if (state.activeGoal != null || _isGoalModalOpen) {
      _handledGoalPromptTrigger = widget.goalPromptTrigger;
      return;
    }
    if (_isGoalPromptScheduled) return;

    _isGoalPromptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isGoalPromptScheduled = false;
      if (!mounted || !widget.isVisible) return;
      if (widget.goalPromptTrigger <= _handledGoalPromptTrigger) return;
      if (_isGoalModalOpen) {
        _handledGoalPromptTrigger = widget.goalPromptTrigger;
        return;
      }
      final latest = context.read<MacroTrackingCubit>().state;
      if (!latest.hasLoadedActiveGoal ||
          latest.isLoadingActiveGoal ||
          latest.isLoading) {
        return;
      }
      if (latest.activeGoal != null) {
        _handledGoalPromptTrigger = widget.goalPromptTrigger;
        return;
      }
      _handledGoalPromptTrigger = widget.goalPromptTrigger;
      _openCreateMacroGoalModal();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
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

  Future<void> _loadTrackerData({
    required bool retryFailedGoal,
    bool loadDailyLog = true,
    bool forceDailyLog = false,
    bool loadRange = false,
  }) async {
    final dailyToken = loadDailyLog ? ++_dailyLoadToken : null;
    final rangeToken = (forceDailyLog || loadRange) ? ++_rangeLoadToken : null;
    final macroCubit = context.read<MacroTrackingCubit>();
    if (!await _ensureActiveGoalReady(
      macroCubit,
      retryFailedGoal: retryFailedGoal,
    )) {
      return;
    }
    if (!mounted || !widget.isVisible) return;

    final macroState = macroCubit.state;
    if (macroState.activeGoal == null) {
      if (dailyToken == null || dailyToken == _dailyLoadToken) {
        _scheduleGoalPromptIfNeeded(macroState);
      }
      return;
    }
    if (widget.goalPromptTrigger > _handledGoalPromptTrigger) {
      _handledGoalPromptTrigger = widget.goalPromptTrigger;
    }

    if (dailyToken != null &&
        dailyToken == _dailyLoadToken &&
        (forceDailyLog || !_hasMatchingDailyLog(macroState))) {
      macroCubit.getDailyLog(_selectedDate);
    }
    if (loadRange &&
        rangeToken == _rangeLoadToken &&
        _scope != TrackerScope.day) {
      final (:start, :end) = _scope.rangeBounds(_selectedDate);
      macroCubit.getDailyLogsForRange(start: start, end: end);
    }
  }

  void _updateSelectedDate(
    DateTime date, {
    required bool isCustom,
    bool resetToDay = false,
  }) {
    setState(() {
      _selectedDate = date;
      _hasCustomSelectedDate = isCustom;
      if (resetToDay) _scope = TrackerScope.day;
    });
    _loadTrackerData(
      retryFailedGoal: widget.isVisible,
      forceDailyLog: true,
      loadRange: _scope != TrackerScope.day,
    );
  }

  void _onStateChanged(
    BuildContext context,
    MacroTrackingState state,
    DataDisplaySizesList sizes,
  ) {
    final justLoaded = !_hadLoadedActiveGoal && state.hasLoadedActiveGoal;
    final activeChanged = _hadActiveGoal != (state.activeGoal != null);
    _hadLoadedActiveGoal = state.hasLoadedActiveGoal;
    _hadActiveGoal = state.activeGoal != null;

    if (state.error == null) {
      _lastShownError = null;
    } else if (state.error != _lastShownError &&
        state.hasLoadedActiveGoal &&
        !state.isLoading) {
      _lastShownError = state.error;
      if (widget.isVisible && !_isGoalModalOpen) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.error!.description,
              style: TextStyle(fontSize: sizes.fontSize),
            ),
          ),
        );
      }
    }

    if (justLoaded) {
      if (state.activeGoal == null) {
        _deferredInitialLogLoad = false;
        if (widget.isVisible && !state.isLoadingActiveGoal) {
          _scheduleGoalPromptIfNeeded(state);
        }
        return;
      }
      if (!_deferredInitialLogLoad) return;
      _deferredInitialLogLoad = false;
      _reconcileIfVisible(state);
      return;
    }

    if (activeChanged && state.hasLoadedActiveGoal) {
      if (state.activeGoal == null) {
        if (_scope != TrackerScope.day) {
          setState(() => _scope = TrackerScope.day);
        }
        return;
      }
      _reconcileIfVisible(state);
    }
  }

  void _reconcileIfVisible(MacroTrackingState state) {
    if (!widget.isVisible || state.isLoadingActiveGoal) return;
    final needsDailyLog = !_hasMatchingDailyLog(state);
    final needsRange = _scope != TrackerScope.day;
    if (needsDailyLog || needsRange) {
      _loadTrackerData(retryFailedGoal: false, loadRange: needsRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      BreakPoint.fromContext(context).screenSize,
    );
    final today = _today;
    final minDate = _minDate(today);

    return BlocConsumer<MacroTrackingCubit, MacroTrackingState>(
      listenWhen: (previous, current) =>
          (!previous.hasLoadedActiveGoal && current.hasLoadedActiveGoal) ||
          (previous.hasLoadedActiveGoal &&
              (previous.activeGoal == null) != (current.activeGoal == null)) ||
          previous.error != current.error,
      listener: (context, state) => _onStateChanged(context, state, sizes),
      buildWhen: (previous, current) =>
          (previous.activeGoal == null) != (current.activeGoal == null) ||
          previous.hasLoadedActiveGoal != current.hasLoadedActiveGoal ||
          previous.isLoadingActiveGoal != current.isLoadingActiveGoal ||
          previous.isLoading != current.isLoading ||
          previous.error != current.error,
      builder: (context, state) {
        final hasActiveGoal = state.activeGoal != null;

        return AppScaffold(
          title: 'Macro Tracker',
          body: MacroTrackerBody(
            state: state,
            sizes: sizes,
            theme: theme,
            scope: _scope,
            selectedDate: _selectedDate,
            firstDate: minDate,
            lastDate: today,
            onScopeChanged: (scope) => setState(() => _scope = scope),
            onLoadRange: () => _loadTrackerData(
              retryFailedGoal: widget.isVisible,
              loadDailyLog: false,
              loadRange: true,
            ),
            onDateSelected: _updateSelectedDate,
            onGoToToday: () =>
                _updateSelectedDate(_currentNow(), isCustom: false),
            onRetry: () => _loadTrackerData(
              retryFailedGoal: true,
              loadRange: _scope != TrackerScope.day,
            ),
            onCreateGoal: _openCreateMacroGoalModal,
          ),
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
    );
  }
}
