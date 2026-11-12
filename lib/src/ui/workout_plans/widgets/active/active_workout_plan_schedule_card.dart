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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import '../../../../data/repositories/workout_plans/utils/workout_plan_schedule_utils.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/mutation_button.dart';
import '../../view_models/workout_plan_record_cubit.dart';
import '../workout_plan_week_group_selector.dart';
import '../workout_plan_week_strip.dart';
import '../workout_plan_weeks_strip.dart';
import './active_workout_plan_day_tile.dart';

class ActiveWorkoutPlanScheduleCard extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final List<WorkoutPlanWeekDto> weeks;
  final int currentWeekNum;
  final int relativeDayIndex;
  final WorkoutPlanRecordDto? workoutPlanRecord;

  const ActiveWorkoutPlanScheduleCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.weeks,
    required this.currentWeekNum,
    required this.relativeDayIndex,
    required this.workoutPlanRecord,
  });

  @override
  State<ActiveWorkoutPlanScheduleCard> createState() =>
      _ActiveWorkoutPlanScheduleCardState();
}

class _ActiveWorkoutPlanScheduleCardState
    extends State<ActiveWorkoutPlanScheduleCard> {
  late int _selectedGroupIndex;
  late int _selectedWeek;
  final Map<int, int> _selectedDayByWeek = {};
  late final ScrollController _carouselController = ScrollController();
  double _lastWidth = 0;
  bool _initializedScroll = false;

  ({int currentWeekNum, int relativeDayIndex}) get _effectiveProgress =>
      WorkoutPlanScheduleUtils.resolveEffectiveProgress(
        weeks: widget.weeks,
        calendarWeekNum: widget.currentWeekNum,
        calendarDayNum: widget.relativeDayIndex,
        workoutPlanRecord: widget.workoutPlanRecord,
      );

  @override
  void initState() {
    super.initState();
    _selectedGroupIndex = _initialGroupIndex();
    _selectedWeek = _initialSelectedWeek(_selectedGroupIndex);
    _selectedDayByWeek[_selectedWeek] = _initialSelectedDay(
      _selectedGroupIndex,
      _selectedWeek,
    );
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ActiveWorkoutPlanScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeekNum != widget.currentWeekNum ||
        oldWidget.relativeDayIndex != widget.relativeDayIndex ||
        oldWidget.weeks != widget.weeks ||
        oldWidget.workoutPlanRecord != widget.workoutPlanRecord) {
      if (_selectedGroupIndex >= widget.weeks.length) {
        _selectedGroupIndex = _initialGroupIndex();
      }
      final currentGroup = widget.weeks[_selectedGroupIndex];
      if (_selectedWeek < currentGroup.startWeek ||
          _selectedWeek > currentGroup.endWeek) {
        _selectedWeek = _initialSelectedWeek(_selectedGroupIndex);
      }
      if (!_selectedDayByWeek.containsKey(_selectedWeek)) {
        _selectedDayByWeek[_selectedWeek] = _initialSelectedDay(
          _selectedGroupIndex,
          _selectedWeek,
        );
      }
      if (_carouselController.hasClients && _lastWidth > 0) {
        final targetPage = (_selectedWeek - currentGroup.startWeek).clamp(
          0,
          currentGroup.endWeek - currentGroup.startWeek,
        );
        _carouselController.jumpTo(targetPage * _lastWidth);
      }
    }
  }

  int _initialGroupIndex() {
    final effectiveWeek = _effectiveProgress.currentWeekNum;
    final matchIndex = widget.weeks.indexWhere(
      (w) => effectiveWeek >= w.startWeek && effectiveWeek <= w.endWeek,
    );
    return matchIndex != -1 ? matchIndex : 0;
  }

  int _initialSelectedWeek(int groupIndex) {
    if (widget.weeks.isEmpty) return 1;
    final group = widget.weeks[groupIndex.clamp(0, widget.weeks.length - 1)];
    final effectiveWeek = _effectiveProgress.currentWeekNum;
    if (effectiveWeek >= group.startWeek && effectiveWeek <= group.endWeek) {
      return effectiveWeek;
    }
    return group.startWeek;
  }

  int _initialSelectedDay(int groupIndex, int weekNum) {
    if (widget.weeks.isEmpty) return 1;
    final group = widget.weeks[groupIndex.clamp(0, widget.weeks.length - 1)];
    final byDay = {for (final d in group.days) d.day: d};
    final effective = _effectiveProgress;
    final isCurrentWeek = effective.currentWeekNum == weekNum;

    if (isCurrentWeek && byDay.containsKey(effective.relativeDayIndex)) {
      return effective.relativeDayIndex;
    }
    for (int dayNum = 1; dayNum <= 7; dayNum++) {
      final day = byDay[dayNum];
      if (day != null && !day.isRestDay) {
        return dayNum;
      }
    }
    if (group.days.isNotEmpty) {
      return group.days.first.day;
    }
    return 1;
  }

  DayProgressStatus _getDayProgressStatus(int dayNum, int weekNum) {
    final effective = _effectiveProgress;
    if (effective.currentWeekNum > weekNum) {
      return DayProgressStatus.past;
    } else if (effective.currentWeekNum < weekNum) {
      return DayProgressStatus.future;
    } else {
      if (dayNum < effective.relativeDayIndex) {
        return DayProgressStatus.past;
      } else if (dayNum == effective.relativeDayIndex) {
        return DayProgressStatus.current;
      } else {
        return DayProgressStatus.future;
      }
    }
  }

  bool _isDayCompleted(int dayNum, int weekNum) {
    final group = widget.weeks
        .where((g) => weekNum >= g.startWeek && weekNum <= g.endWeek)
        .firstOrNull;
    final day = group?.days.where((d) => d.day == dayNum).firstOrNull;
    if (day == null) return false;
    return WorkoutPlanScheduleUtils.isDayFinished(
      day: day,
      weekNum: weekNum,
      workoutPlanRecord: widget.workoutPlanRecord,
    );
  }

  bool _isDayMissed(int dayNum, int weekNum) {
    final group = widget.weeks
        .where((g) => weekNum >= g.startWeek && weekNum <= g.endWeek)
        .firstOrNull;
    final day = group?.days.where((d) => d.day == dayNum).firstOrNull;
    if (day == null || day.isRestDay) return false;
    final status = _getDayProgressStatus(dayNum, weekNum);
    return status == DayProgressStatus.past &&
        !_isDayCompleted(dayNum, weekNum);
  }

  bool _isWeekCompleted(int weekNum) {
    return WorkoutPlanScheduleUtils.isWeekFinished(
      weeks: widget.weeks,
      weekNum: weekNum,
      workoutPlanRecord: widget.workoutPlanRecord,
    );
  }

  bool _canSkipWeek(WorkoutPlanWeekDto currentGroup, int weekNum) {
    if (_effectiveProgress.currentWeekNum != weekNum ||
        _selectedWeek != weekNum) {
      return false;
    }
    if (_isWeekCompleted(weekNum)) return false;
    if (widget.workoutPlanRecord == null) return false;
    return currentGroup.days.any(
      (day) => !day.isRestDay && (day.planWorkouts?.isNotEmpty ?? false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeks.isEmpty) return const SizedBox.shrink();

    final safeGroupIndex = _selectedGroupIndex.clamp(
      0,
      widget.weeks.length - 1,
    );
    final currentGroup = widget.weeks[safeGroupIndex];
    final weekCount = currentGroup.endWeek >= currentGroup.startWeek
        ? (currentGroup.endWeek - currentGroup.startWeek + 1)
        : 0;
    final byDay = {for (final d in currentGroup.days) d.day: d};
    final effectiveWeekNum = _effectiveProgress.currentWeekNum;
    final isCurrentWeek = effectiveWeekNum == _selectedWeek;

    return Card(
      margin: EdgeInsets.only(bottom: widget.sizes.margins),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: isCurrentWeek
            ? BorderSide(
                color: widget.theme.primaryColor.withValues(alpha: 0.5),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WorkoutPlanWeekGroupSelector(
              weekGroups: widget.weeks,
              selectedGroupIndex: safeGroupIndex,
              onSelectGroup: (newIndex) {
                setState(() {
                  _selectedGroupIndex = newIndex;
                  _selectedWeek = _initialSelectedWeek(newIndex);
                  if (!_selectedDayByWeek.containsKey(_selectedWeek)) {
                    _selectedDayByWeek[_selectedWeek] = _initialSelectedDay(
                      newIndex,
                      _selectedWeek,
                    );
                  }
                });
                // Reposition after the new group's pages have been laid out.
                _initializedScroll = false;
                _lastWidth = 0;
              },
              sizes: widget.sizes,
              theme: widget.theme,
              isDarkTheme: widget.isDarkTheme,
            ),
            SizedBox(height: widget.sizes.spacing),
            WorkoutPlanWeeksStrip(
              startWeek: currentGroup.startWeek,
              endWeek: currentGroup.endWeek,
              selectedWeek: _selectedWeek,
              onSelectWeek: (weekNum) {
                final targetPage = (weekNum - currentGroup.startWeek).clamp(
                  0,
                  weekCount - 1,
                );
                if (_carouselController.hasClients && _lastWidth > 0) {
                  _carouselController.animateTo(
                    targetPage * _lastWidth,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
                setState(() {
                  _selectedWeek = weekNum;
                  if (!_selectedDayByWeek.containsKey(weekNum)) {
                    _selectedDayByWeek[weekNum] = _initialSelectedDay(
                      _selectedGroupIndex,
                      weekNum,
                    );
                  }
                });
              },
              sizes: widget.sizes,
              theme: widget.theme,
              isDarkTheme: widget.isDarkTheme,
              currentWeekNum: effectiveWeekNum,
              isWeekCompleted: _isWeekCompleted,
              getWeekWorkoutCount: (_) => currentGroup.totalWorkouts,
            ),
            SizedBox(height: widget.sizes.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (width <= 0) return const SizedBox.shrink();

                if (_lastWidth != width) {
                  _lastWidth = width;
                  if (_carouselController.hasClients) {
                    final targetPage = (_selectedWeek - currentGroup.startWeek)
                        .clamp(0, weekCount - 1);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || !_carouselController.hasClients) return;
                      _carouselController.jumpTo(targetPage * width);
                    });
                  }
                }

                if (!_initializedScroll) {
                  _initializedScroll = true;
                  final targetPage = (_selectedWeek - currentGroup.startWeek)
                      .clamp(0, weekCount - 1);
                  if (targetPage > 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || !_carouselController.hasClients) return;
                      _carouselController.jumpTo(targetPage * width);
                    });
                  }
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (_selectedGroupIndex != safeGroupIndex) return false;
                    if (notification.depth == 0 &&
                        notification.metrics.axis == Axis.horizontal &&
                        width > 0) {
                      final page = (notification.metrics.pixels / width)
                          .round()
                          .clamp(0, weekCount - 1);
                      final newWeek = currentGroup.startWeek + page;
                      if (newWeek != _selectedWeek) {
                        setState(() {
                          _selectedWeek = newWeek;
                          if (!_selectedDayByWeek.containsKey(newWeek)) {
                            _selectedDayByWeek[newWeek] = _initialSelectedDay(
                              _selectedGroupIndex,
                              newWeek,
                            );
                          }
                        });
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _carouselController,
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < weekCount; i++)
                          SizedBox(
                            width: width,
                            child: IgnorePointer(
                              ignoring:
                                  currentGroup.startWeek + i != _selectedWeek,
                              child: ExcludeSemantics(
                                excluding:
                                    currentGroup.startWeek + i != _selectedWeek,
                                child: _buildWeekContent(
                                  context,
                                  currentGroup,
                                  currentGroup.startWeek + i,
                                  byDay,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekContent(
    BuildContext context,
    WorkoutPlanWeekDto currentGroup,
    int weekNum,
    Map<int, WorkoutPlanDayDto> byDay,
  ) {
    final selectedDay =
        _selectedDayByWeek[weekNum] ??
        _initialSelectedDay(_selectedGroupIndex, weekNum);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WorkoutPlanWeekStrip(
          days: currentGroup.days,
          selectedDay: selectedDay,
          onSelectDay: (dayNum) {
            setState(() {
              _selectedDayByWeek[weekNum] = dayNum;
            });
          },
          sizes: widget.sizes,
          theme: widget.theme,
          isDarkTheme: widget.isDarkTheme,
          getDayProgressStatus: (d) => _getDayProgressStatus(d, weekNum),
          isDayCompleted: (d) => _isDayCompleted(d, weekNum),
          isDayMissed: (d) => _isDayMissed(d, weekNum),
        ),
        if (_canSkipWeek(currentGroup, weekNum)) ...[
          SizedBox(height: widget.sizes.spacing),
          MutationButton(
            theme: widget.theme,
            sizes: widget.sizes,
            isLoading: false,
            isDense: true,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ConfirmationDialog(
                title: 'Skip Week',
                content:
                    'Skip all unfinished workouts for Week $weekNum? Completed workouts will be kept.',
                confirmLabel: 'Skip Week',
                onConfirm: () => _skipWeek(context, currentGroup, weekNum),
              ),
            ),
            label: 'Skip Week',
            icon: Icons.skip_next,
            color: widget.theme.colorScheme.secondary,
          ),
        ],
        SizedBox(height: widget.sizes.spacing),
        _buildSelectedDayPanel(context, byDay, weekNum, selectedDay),
      ],
    );
  }

  Widget _buildSelectedDayPanel(
    BuildContext context,
    Map<int, WorkoutPlanDayDto> byDay,
    int weekNum,
    int selectedDayNum,
  ) {
    final selectedDay = byDay[selectedDayNum];

    if (selectedDay == null) {
      return Container(
        padding: EdgeInsets.all(widget.sizes.padding),
        decoration: BoxDecoration(
          color: widget.isDarkTheme
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          border: Border.all(
            color: widget.isDarkTheme
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.zero,
        ),
        child: Center(
          child: Text(
            'No workout scheduled for Day $selectedDayNum',
            style: TextStyle(
              fontSize: widget.sizes.fontSize,
              color: widget.isDarkTheme
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final status = _getDayProgressStatus(selectedDay.day, weekNum);
    final workoutRecords = _recordsForDay(weekNum, selectedDay.day);
    final planRecordId = widget.workoutPlanRecord?.id ?? 0;

    return ActiveWorkoutPlanDayTile(
      sizes: widget.sizes,
      day: selectedDay,
      theme: widget.theme,
      isDarkTheme: widget.isDarkTheme,
      status: status,
      week: weekNum,
      workoutPlanRecordId: planRecordId,
      workoutRecords: workoutRecords,
      onSkipWorkout: planRecordId == 0
          ? null
          : (planWorkout) => _skipWorkout(
              context,
              weekNum: weekNum,
              day: selectedDay.day,
              planWorkout: planWorkout,
              existingRecords: workoutRecords,
            ),
      onSkipDay: planRecordId == 0
          ? null
          : () => _skipDay(
              context,
              weekNum: weekNum,
              day: selectedDay,
              existingRecords: workoutRecords,
            ),
    );
  }

  List<WorkoutPlanWorkoutRecordDto> _recordsForDay(int weekNum, int dayNum) {
    return widget.workoutPlanRecord?.weeks
            .where((recordWeek) => recordWeek.week == weekNum)
            .expand((recordWeek) => recordWeek.days)
            .where((recordDay) => recordDay.day == dayNum)
            .expand((recordDay) => recordDay.workouts)
            .toList() ??
        const [];
  }

  Future<void> _skipWorkout(
    BuildContext context, {
    required int weekNum,
    required int day,
    required WorkoutPlanWorkoutDto planWorkout,
    required List<WorkoutPlanWorkoutRecordDto> existingRecords,
  }) async {
    final planRecordId = widget.workoutPlanRecord?.id;
    if (planRecordId == null) return;
    final existing = existingRecords
        .where((record) => record.position == planWorkout.position)
        .firstOrNull;
    await context.read<WorkoutPlanRecordCubit>().skipPlanWorkout(
      workoutPlanRecordId: planRecordId,
      week: weekNum,
      day: day,
      workoutPosition: planWorkout.position,
      workoutId: planWorkout.workoutId,
      existingWorkoutRecordId: existing?.workoutRecordId,
    );
  }

  Future<void> _skipDay(
    BuildContext context, {
    required int weekNum,
    required WorkoutPlanDayDto day,
    required List<WorkoutPlanWorkoutRecordDto> existingRecords,
  }) async {
    final planRecordId = widget.workoutPlanRecord?.id;
    final planWorkouts = day.planWorkouts;
    if (planRecordId == null || planWorkouts == null || planWorkouts.isEmpty) {
      return;
    }
    await context.read<WorkoutPlanRecordCubit>().skipPlanDay(
      workoutPlanRecordId: planRecordId,
      week: weekNum,
      day: day.day,
      planWorkouts: planWorkouts,
      existingRecords: existingRecords,
    );
  }

  Future<void> _skipWeek(
    BuildContext context,
    WorkoutPlanWeekDto currentGroup,
    int weekNum,
  ) async {
    final planRecordId = widget.workoutPlanRecord?.id;
    if (planRecordId == null || !_canSkipWeek(currentGroup, weekNum)) return;

    final workoutsByDay = <int, List<WorkoutPlanWorkoutDto>>{};
    final recordsByDay = <int, List<WorkoutPlanWorkoutRecordDto>>{};
    for (final day in currentGroup.days) {
      final workouts = day.planWorkouts;
      if (day.isRestDay || workouts == null || workouts.isEmpty) continue;
      workoutsByDay[day.day] = workouts;
      recordsByDay[day.day] = _recordsForDay(weekNum, day.day);
    }

    await context.read<WorkoutPlanRecordCubit>().skipPlanWeek(
      workoutPlanRecordId: planRecordId,
      week: weekNum,
      workoutsByDay: workoutsByDay,
      existingRecordsByDay: recordsByDay,
    );
  }
}
