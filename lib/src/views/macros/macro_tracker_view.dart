import '../../widgets/macros/macro_tracker_day_widget.dart';
import '../../widgets/macros/macro_tracker_week_widget.dart';
import '../../widgets/macros/macro_tracker_month_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/meal_plan_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/macros/log_food_modal.dart';

enum TrackerScope { day, week, month }

class MacroTrackerView extends StatefulWidget {
  static const routeName = '/macro-tracker';
  static const name = 'macro_tracker';

  const MacroTrackerView({super.key});

  @override
  State<MacroTrackerView> createState() => _MacroTrackerViewState();
}

class _MacroTrackerViewState extends State<MacroTrackerView> {
  TrackerScope _scope = TrackerScope.day;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final macroCubit = context.read<MacroTrackingCubit>();
    macroCubit.getActiveMacroGoal();
    macroCubit.getDailyLog(_selectedDate);

    // Also get active meal plan record
    final recordCubit = context.read<MealPlanRecordCubit>();
    recordCubit.getActiveMealPlanRecord().then((_) {
      if (!mounted) return;
      final record = recordCubit.state.activeRecord;
      final plan = context.read<MealPlanCubit>().state.selectedMealPlan;
      if (record != null &&
          (plan?.id != record.mealPlanId ||
              plan?.version != record.mealPlanVersion)) {
        context
            .read<MealPlanCubit>()
            .getMealPlan(record.mealPlanId, version: record.mealPlanVersion);
      }
    });

    // If week or month, load date range
    if (_scope == TrackerScope.week) {
      final start =
          _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      macroCubit.getDailyLogsForRange(start: start, end: end);
    } else if (_scope == TrackerScope.month) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      macroCubit.getDailyLogsForRange(start: start, end: end);
    }
  }

  void _onScopeChanged(TrackerScope newScope) {
    setState(() {
      _scope = newScope;
    });
    _loadData();
  }

  void _prevPeriod() {
    setState(() {
      switch (_scope) {
        case TrackerScope.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case TrackerScope.week:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case TrackerScope.month:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
      }
    });
    _loadData();
  }

  void _nextPeriod() {
    setState(() {
      switch (_scope) {
        case TrackerScope.day:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case TrackerScope.week:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case TrackerScope.month:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
      }
    });
    _loadData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Macro Tracker',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          children: [
            // Scope & Date Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: sizes.spacing / 2,
              children: [
                SegmentedButton<TrackerScope>(
                  key: const ValueKey('macro-tracker-scope-selector'),
                  segments: [
                    ButtonSegment(
                        value: TrackerScope.day,
                        label: Text('Day',
                            style: TextStyle(fontSize: sizes.fontSize))),
                    ButtonSegment(
                        value: TrackerScope.week,
                        label: Text('Week',
                            style: TextStyle(fontSize: sizes.fontSize))),
                    ButtonSegment(
                        value: TrackerScope.month,
                        label: Text('Month',
                            style: TextStyle(fontSize: sizes.fontSize))),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (val) {
                    _onScopeChanged(val.first);
                  },
                ),
                TextButton(
                  key: const ValueKey('macro-tracker-today-btn'),
                  onPressed: _goToToday,
                  child:
                      Text('Today', style: TextStyle(fontSize: sizes.fontSize)),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            // Date Navigator
            Row(
              children: [
                IconButton(
                  key: const ValueKey('macro-tracker-prev-btn'),
                  icon: Icon(Icons.chevron_left, size: sizes.buttonIconSize),
                  onPressed: _prevPeriod,
                ),
                Expanded(
                  child: TextButton(
                    key: const ValueKey('macro-tracker-date-btn'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _loadData();
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
                  onPressed: _nextPeriod,
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            // Scope Body
            Expanded(
              child: _buildScopeBody(theme, sizes),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('macro-tracker-log-food-fab'),
        icon: Icon(Icons.add, size: sizes.buttonIconSize),
        label: Text('Log Food', style: TextStyle(fontSize: sizes.fontSize)),
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
    );
  }

  String _formatHeaderDate() {
    switch (_scope) {
      case TrackerScope.day:
        return DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
      case TrackerScope.week:
        final start =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
      case TrackerScope.month:
        return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  void _selectDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _scope = TrackerScope.day;
    });
    _loadData();
  }

  Widget _buildScopeBody(ThemeData theme, DataDisplaySizesList sizes) {
    switch (_scope) {
      case TrackerScope.day:
        return MacroTrackerDayWidget(
            theme: theme, sizes: sizes, selectedDate: _selectedDate);
      case TrackerScope.week:
        return MacroTrackerWeekWidget(
            theme: theme,
            sizes: sizes,
            selectedDate: _selectedDate,
            onSelectDate: _selectDay);
      case TrackerScope.month:
        return MacroTrackerMonthWidget(
            theme: theme,
            sizes: sizes,
            selectedDate: _selectedDate,
            onSelectDate: _selectDay);
    }
  }
}
