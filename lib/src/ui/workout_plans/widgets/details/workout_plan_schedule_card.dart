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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../workout_plan_week_group_selector.dart';
import '../workout_plan_week_strip.dart';
import '../workout_plan_weeks_strip.dart';
import './workout_plan_workout_card.dart';

class WorkoutPlanScheduleCard extends StatefulWidget {
  final ThemeData theme;
  final bool isDarkTheme;
  final DataDisplaySizesList sizes;
  final List<WorkoutPlanWeekDto> weeks;

  const WorkoutPlanScheduleCard({
    super.key,
    required this.theme,
    required this.isDarkTheme,
    required this.sizes,
    required this.weeks,
  });

  @override
  State<WorkoutPlanScheduleCard> createState() =>
      _WorkoutPlanScheduleCardState();
}

class _WorkoutPlanScheduleCardState extends State<WorkoutPlanScheduleCard> {
  late int _selectedGroupIndex;
  late int _selectedWeek;
  final Map<int, int> _selectedDayByWeek = {};
  late final ScrollController _carouselController = ScrollController();
  double _lastWidth = 0;
  bool _initializedScroll = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupIndex = 0;
    _selectedWeek = _initialSelectedWeek(0);
    _selectedDayByWeek[_selectedWeek] = _initialSelectedDay(0);
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WorkoutPlanScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeks != widget.weeks) {
      if (_selectedGroupIndex >= widget.weeks.length) {
        _selectedGroupIndex = 0;
      }
      final currentGroup = widget.weeks[_selectedGroupIndex];
      if (_selectedWeek < currentGroup.startWeek ||
          _selectedWeek > currentGroup.endWeek) {
        _selectedWeek = _initialSelectedWeek(_selectedGroupIndex);
      }
      if (!_selectedDayByWeek.containsKey(_selectedWeek)) {
        _selectedDayByWeek[_selectedWeek] = _initialSelectedDay(
          _selectedGroupIndex,
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

  int _initialSelectedWeek(int groupIndex) {
    if (widget.weeks.isEmpty) return 1;
    final group = widget.weeks[groupIndex.clamp(0, widget.weeks.length - 1)];
    return group.startWeek;
  }

  int _initialSelectedDay(int groupIndex) {
    if (widget.weeks.isEmpty) return 1;
    final group = widget.weeks[groupIndex.clamp(0, widget.weeks.length - 1)];
    final byDay = {for (final d in group.days) d.day: d};

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

    return Card(
      margin: EdgeInsets.only(bottom: widget.sizes.margins),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                    );
                  }
                });
                if (_carouselController.hasClients) {
                  _carouselController.jumpTo(0);
                }
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
                    );
                  }
                });
              },
              sizes: widget.sizes,
              theme: widget.theme,
              isDarkTheme: widget.isDarkTheme,
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
                            child: _buildWeekContent(
                              context,
                              currentGroup,
                              currentGroup.startWeek + i,
                              byDay,
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
        _selectedDayByWeek[weekNum] ?? _initialSelectedDay(_selectedGroupIndex);

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
        ),
        SizedBox(height: widget.sizes.spacing),
        _buildSelectedDayDetail(byDay[selectedDay], selectedDay),
      ],
    );
  }

  Widget _buildSelectedDayDetail(WorkoutPlanDayDto? day, int selectedDayNum) {
    if (day == null) {
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

    if (day.isRestDay) {
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
        child: Row(
          children: [
            Icon(
              Icons.snooze,
              size: widget.sizes.subtitleFontSize * 1.5,
              color: widget.isDarkTheme
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            SizedBox(width: widget.sizes.spacing / 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.day} • Rest Day',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Recovery day',
                  style: TextStyle(
                    fontSize: widget.sizes.smallFontSize,
                    color: widget.isDarkTheme
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...(day.planWorkouts?.map(
              (planWorkout) => WorkoutPlanWorkoutCard(
                isDarkTheme: widget.isDarkTheme,
                sizes: widget.sizes,
                workoutPlanWorkout: planWorkout,
              ),
            ) ??
            []),
      ],
    );
  }
}
