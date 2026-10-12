import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../cubits/states/meal_plan_record_state.dart';
import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/macros/log_food_modal.dart';
import '../macro_goals/macro_goals_view.dart';

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
    context.read<MealPlanRecordCubit>().getActiveMealPlanRecord();

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
              runSpacing: 4,
              children: [
                SegmentedButton<TrackerScope>(
                  key: const ValueKey('macro-tracker-scope-selector'),
                  segments: const [
                    ButtonSegment(value: TrackerScope.day, label: Text('Day')),
                    ButtonSegment(
                        value: TrackerScope.week, label: Text('Week')),
                    ButtonSegment(
                        value: TrackerScope.month, label: Text('Month')),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (val) {
                    _onScopeChanged(val.first);
                  },
                ),
                TextButton(
                  key: const ValueKey('macro-tracker-today-btn'),
                  onPressed: _goToToday,
                  child: const Text('Today'),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            // Date Navigator
            Row(
              children: [
                IconButton(
                  key: const ValueKey('macro-tracker-prev-btn'),
                  icon: const Icon(Icons.chevron_left),
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
                  icon: const Icon(Icons.chevron_right),
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
        icon: const Icon(Icons.add),
        label: const Text('Log Food'),
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

  Widget _buildScopeBody(ThemeData theme, DataDisplaySizesList sizes) {
    switch (_scope) {
      case TrackerScope.day:
        return _buildDayView(theme, sizes);
      case TrackerScope.week:
        return _buildWeekView(theme, sizes);
      case TrackerScope.month:
        return _buildMonthView(theme, sizes);
    }
  }

  Widget _buildDayView(ThemeData theme, DataDisplaySizesList sizes) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final dailyLog = state.selectedDailyLog;
        final activeGoal = state.activeGoal;

        final currentCal = dailyLog?.totalCalories ?? 0;
        final targetCal = activeGoal?.targetCalories ?? 2000;
        final calProgress = (currentCal / targetCal).clamp(0.0, 1.0);

        final currentProtein = dailyLog?.totalProtein ?? 0;
        final targetProtein = activeGoal?.targetProtein ?? 150;

        final currentCarbs = dailyLog?.totalCarbs ?? 0;
        final targetCarbs = activeGoal?.targetCarbs ?? 200;

        final currentFat = dailyLog?.totalFat ?? 0;
        final targetFat = activeGoal?.targetFat ?? 65;

        final currentWater = dailyLog?.waterIntakeMl ?? 0;
        final targetWater = activeGoal?.targetWaterIntakeMl ?? 2500;

        return ListView(
          children: [
            // Active Meal Plan Integration Banner
            _buildActiveMealPlanBanner(sizes),
            SizedBox(height: sizes.spacing),
            // Macro Target Summary Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Calories: $currentCal / $targetCal kcal',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (activeGoal == null)
                          TextButton(
                            onPressed: () =>
                                context.push(MacroGoalsView.routeName),
                            child: const Text('Set Goal'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: calProgress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      children: [
                        _MacroProgressBar(
                          label: 'Protein',
                          current: currentProtein,
                          target: targetProtein,
                          unit: 'g',
                          color: Colors.blue,
                          sizes: sizes,
                        ),
                        SizedBox(width: sizes.spacing),
                        _MacroProgressBar(
                          label: 'Carbs',
                          current: currentCarbs,
                          target: targetCarbs,
                          unit: 'g',
                          color: Colors.amber,
                          sizes: sizes,
                        ),
                        SizedBox(width: sizes.spacing),
                        _MacroProgressBar(
                          label: 'Fat',
                          current: currentFat,
                          target: targetFat,
                          unit: 'g',
                          color: Colors.red,
                          sizes: sizes,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing),
            // Water Intake Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop,
                            color: Colors.cyan, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Water: $currentWater / $targetWater ml',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {
                            final newWater =
                                (currentWater - 250).clamp(0, 100000);
                            context
                                .read<MacroTrackingCubit>()
                                .updateWaterIntake(newWater);
                          },
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            context
                                .read<MacroTrackingCubit>()
                                .updateWaterIntake(currentWater + 250);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (currentWater / targetWater).clamp(0.0, 1.0),
                      color: Colors.cyan,
                      backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizes.spacing * 1.5),
            // Meal Logs by MealType
            ...MealType.values.map((type) {
              final mealLog = dailyLog?.meals.where((m) => m.mealType == type);
              final hasLog = mealLog != null && mealLog.isNotEmpty;
              final meal = hasLog ? mealLog.first : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(sizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type.value[0].toUpperCase() +
                                type.value.substring(1),
                            style: TextStyle(
                              fontSize: sizes.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (meal != null)
                                Text(
                                  '${meal.totalCalories} kcal',
                                  style: TextStyle(
                                    fontSize: sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => LogFoodModal(
                                      theme: theme,
                                      sizes: sizes,
                                      initialMealType: type,
                                      selectedDate: _selectedDate,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (meal != null && meal.items.isNotEmpty) ...[
                        const Divider(height: 16),
                        ...meal.items.map((item) {
                          final portionText = item.portionName != null
                              ? '${item.amount} × ${item.portionName}'
                              : '${item.amount}g';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.loggedFoodName,
                                        style: TextStyle(
                                          fontSize: sizes.fontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$portionText • ${item.loggedCalories} kcal (P: ${item.loggedProtein}g C: ${item.loggedCarbs}g F: ${item.loggedFat}g)',
                                        style: TextStyle(
                                          fontSize: sizes.fontSize * 0.85,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.grey),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ConfirmationDialog(
                                        title: 'Delete Item',
                                        content:
                                            'Are you sure you want to remove this logged food?',
                                        onConfirm: () {
                                          context
                                              .read<MacroTrackingCubit>()
                                              .deleteMealLogItem(item.id);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildActiveMealPlanBanner(DataDisplaySizesList sizes) {
    return BlocBuilder<MealPlanRecordCubit, MealPlanRecordState>(
      builder: (context, state) {
        final activeRecord = state.activeRecord;
        if (activeRecord == null) return const SizedBox.shrink();

        return Card(
          color: Colors.green.withValues(alpha: 0.1),
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant_menu,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Active Meal Plan: ${activeRecord.planName ?? 'Plan'}',
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'W${activeRecord.currentWeek} D${activeRecord.currentDay}',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete Day Record'),
                      onPressed: () {
                        context
                            .read<MealPlanRecordCubit>()
                            .completeCurrentDay(recordId: activeRecord.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView(ThemeData theme, DataDisplaySizesList sizes) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final logs = state.rangeLogs;
        final startOfWeek =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

        return ListView.separated(
          itemCount: 7,
          separatorBuilder: (_, __) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate = startOfWeek.add(Duration(days: index));
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;

            final isSelectedDay = dayDate.year == _selectedDate.year &&
                dayDate.month == _selectedDate.month &&
                dayDate.day == _selectedDate.day;

            return Card(
              color: isSelectedDay
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEEE, MMM d').format(dayDate),
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  log != null
                      ? '${log.totalCalories} kcal • P: ${log.totalProtein}g C: ${log.totalCarbs}g F: ${log.totalFat}g'
                      : 'No foods logged',
                  style: TextStyle(
                    fontSize: sizes.fontSize * 0.85,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() {
                    _selectedDate = dayDate;
                    _scope = TrackerScope.day;
                  });
                  _loadData();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthView(ThemeData theme, DataDisplaySizesList sizes) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final logs = state.rangeLogs;
        final daysInMonth =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

        return ListView.separated(
          itemCount: daysInMonth,
          separatorBuilder: (_, __) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate =
                DateTime(_selectedDate.year, _selectedDate.month, index + 1);
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEE, MMM d').format(dayDate),
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                trailing: Text(
                  log != null ? '${log.totalCalories} kcal' : '-',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                    color: log != null ? theme.primaryColor : Colors.grey,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedDate = dayDate;
                    _scope = TrackerScope.day;
                  });
                  _loadData();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final String unit;
  final Color color;
  final DataDisplaySizesList sizes;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: sizes.fontSize * 0.8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            '$current/$target$unit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: sizes.fontSize * 0.75,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
