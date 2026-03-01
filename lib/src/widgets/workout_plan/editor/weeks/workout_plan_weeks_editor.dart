import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../cubits/states/workout_plan_state.dart';
import '../../../../cubits/workout_cubit.dart';
import '../../../../cubits/workout_plan_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_plan_week_dto.dart';
import '../../../../services/workout_plan_service.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/editors/save_buttons.dart';
import '../../../layout/dynamic_list_input.dart';
import 'workout_plan_editor_data.dart';
import 'workout_plan_week_editor.dart';

class WorkoutPlanWeeksEditor extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int workoutPlanId;
  final int currentVersion;
  final List<WorkoutPlanWeekDto> initialWeeks;

  const WorkoutPlanWeeksEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.workoutPlanId,
    required this.currentVersion,
    required this.initialWeeks,
  });

  @override
  State<WorkoutPlanWeeksEditor> createState() => _WorkoutPlanWeeksEditorState();
}

class _WorkoutPlanWeeksEditorState extends State<WorkoutPlanWeeksEditor> {
  List<WorkoutPlanWeekEditorData> _weeks = [];
  List<WorkoutPlanWeekEditorData> _baselineWeeks = [];
  String _baselineFingerprint = '';
  String _baselineSeed = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _resetFromWidget();
    context.read<WorkoutCubit>().getSelectionWorkouts();
  }

  @override
  void didUpdateWidget(covariant WorkoutPlanWeeksEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    final seed = _seedFromWidget();
    if (seed != _baselineSeed) {
      _resetFromWidget();
    }
  }

  String _seedFromWidget() {
    return '${widget.workoutPlanId}:${widget.currentVersion}';
  }

  List<WorkoutPlanWeekEditorData> _mapWeeks(List<WorkoutPlanWeekDto> weeks) {
    return weeks.map(WorkoutPlanWeekEditorData.fromDto).toList();
  }

  List<WorkoutPlanWeekEditorData> _cloneWeeks(
    List<WorkoutPlanWeekEditorData> weeks,
  ) {
    return weeks.map((w) => w.copy()).toList();
  }

  void _resetFromWidget() {
    final mappedWeeks = _mapWeeks(widget.initialWeeks);
    _weeks = _cloneWeeks(mappedWeeks);
    _baselineWeeks = _cloneWeeks(mappedWeeks);
    _baselineFingerprint = _buildEditorFingerprint(_baselineWeeks);
    _baselineSeed = _seedFromWidget();
  }

  String _buildEditorFingerprint(List<WorkoutPlanWeekEditorData> weeks) {
    final sortedWeeks = _cloneWeeks(weeks)
      ..sort((a, b) => a.startWeek.compareTo(b.startWeek));

    final weekParts = sortedWeeks.map((week) {
      final sortedDays = week.days.map((d) => d.copy()).toList()
        ..sort((a, b) => a.day.compareTo(b.day));

      final dayParts = sortedDays.map((day) {
        final workoutParts = day.workouts
            .map(
              (workout) =>
                  '${workout.workoutId ?? 0}:${workout.timeOfDay?.value ?? ''}',
            )
            .join(',');
        return '${day.day}|${day.isRestDay ? 1 : 0}|$workoutParts';
      }).join(';');

      return '${week.startWeek}-${week.endWeek}|${week.phase?.value ?? ''}|$dayParts';
    }).join('||');

    return weekParts;
  }

  String? _validateWeeks(List<WorkoutPlanWeekEditorData> weeks) {
    if (weeks.isEmpty) {
      return 'At least one week block is required';
    }

    final sortedWeeks = _cloneWeeks(weeks)
      ..sort((a, b) => a.startWeek.compareTo(b.startWeek));

    for (int i = 0; i < sortedWeeks.length; i++) {
      final week = sortedWeeks[i];

      if (week.startWeek < 1 ||
          week.endWeek < week.startWeek ||
          week.endWeek > week.startWeek + 11) {
        return 'Invalid week range. Each block must span 1 to 12 weeks';
      }

      if (i > 0) {
        final previous = sortedWeeks[i - 1];
        if (week.startWeek != previous.endWeek + 1) {
          return 'Week blocks must be contiguous and cannot overlap or leave gaps';
        }
      }

      if (week.days.length > 7) {
        return 'A week can have at most 7 days';
      }

      final seenDays = <int>{};
      for (final day in week.days) {
        if (day.day < 1 || day.day > 7) {
          return 'Day must be between 1 and 7';
        }
        if (!seenDays.add(day.day)) {
          return 'Day numbers must be unique within a week';
        }

        if (day.isRestDay && day.workouts.isNotEmpty) {
          return 'Rest days cannot have workouts';
        }

        if (!day.isRestDay &&
            (day.workouts.isEmpty || day.workouts.length > 3)) {
          return 'Workout days must include between 1 and 3 workouts';
        }

        if (!day.isRestDay && day.workouts.any((w) => w.workoutId == null)) {
          return 'All workouts must be selected before saving';
        }
      }
    }

    return null;
  }

  List<WorkoutPlanWeekBatchCreateInput> _toBatchInputs(
    List<WorkoutPlanWeekEditorData> weeks,
  ) {
    final sortedWeeks = _cloneWeeks(weeks)
      ..sort((a, b) => a.startWeek.compareTo(b.startWeek));

    return sortedWeeks.map((week) {
      final sortedDays = week.days.map((d) => d.copy()).toList()
        ..sort((a, b) => a.day.compareTo(b.day));

      return WorkoutPlanWeekBatchCreateInput(
        startWeek: week.startWeek,
        endWeek: week.endWeek,
        phase: week.phase,
        scheduleMode: week.days.length == 7
            ? WorkoutPlanWeekScheduleMode.manual
            : week.days.any((d) => d.isRestDay)
                ? WorkoutPlanWeekScheduleMode.hybrid
                : WorkoutPlanWeekScheduleMode.automatic,
        days: sortedDays.map((day) {
          return WorkoutPlanDayBatchCreateInput(
            day: day.day,
            isRestDay: day.isRestDay,
            workouts: day.workouts
                .map((workout) => WorkoutPlanWorkoutBatchCreateInput(
                      workoutId: workout.workoutId!,
                      timeOfDay: workout.timeOfDay,
                    ))
                .toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  void _showSnackBar(
    String message, {
    Color? backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkoutPlan != current.selectedWorkoutPlan ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DynamicListInput<WorkoutPlanWeekEditorData>(
              theme: widget.theme,
              filled: true,
              items: _weeks,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              spacing: widget.sizes.spacing,
              handlesPadding: widget.sizes.padding / 2,
              isLoading: state.isLoading || _isSaving,
              addLabel: 'Add Week Block',
              keyBuilder: (item) => ValueKey(item.internalId),
              onAdd: () {
                final previous = _weeks.lastOrNull;
                final int start = previous != null ? previous.endWeek + 1 : 1;
                final created = WorkoutPlanWeekEditorData(
                  startWeek: start,
                  endWeek: start,
                  initiallyExpanded: true,
                  days: [
                    WorkoutPlanDayEditorData(
                      day: 1,
                      isRestDay: false,
                      workouts: [],
                    ),
                  ],
                );
                setState(() {
                  _weeks.add(created);
                });
              },
              onChanged: (items) {
                final reorderedWeeks = <WorkoutPlanWeekEditorData>[];
                int currentStart = 1;
                for (final week in items) {
                  final span = week.endWeek - week.startWeek;
                  final updated = week.copy()
                    ..startWeek = currentStart
                    ..endWeek = currentStart + span;
                  reorderedWeeks.add(updated);
                  currentStart = updated.endWeek + 1;
                }
                setState(() {
                  _weeks = reorderedWeeks;
                });
              },
              itemBuilder: (context, index, week) {
                return WorkoutPlanWeekEditor(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  isLoading: state.isLoading || _isSaving,
                  index: index,
                  week: week,
                  onChanged: (updatedWeek) {
                    final updatedWeeks =
                        List<WorkoutPlanWeekEditorData>.from(_weeks);
                    updatedWeeks[index] = updatedWeek;

                    // Cascade the week changes forward to maintain contiguous blocks
                    int currentStart = updatedWeek.endWeek + 1;
                    for (int i = index + 1; i < updatedWeeks.length; i++) {
                      final nextWeek = updatedWeeks[i];
                      final span = nextWeek.endWeek - nextWeek.startWeek;
                      updatedWeeks[i] = nextWeek.copy()
                        ..startWeek = currentStart
                        ..endWeek = currentStart + span;
                      currentStart = updatedWeeks[i].endWeek + 1;
                    }

                    setState(() {
                      _weeks = updatedWeeks;
                    });
                  },
                );
              },
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            SaveButtons(
              theme: widget.theme,
              sizes: widget.sizes,
              isLoading: state.isLoading || _isSaving,
              onCancel: () {
                if (_isSaving || state.isLoading) {
                  return;
                }

                if (context.canPop()) {
                  context.pop();
                }
              },
              onSave: () async {
                if (_isSaving || state.isLoading) {
                  return;
                }

                final validationError = _validateWeeks(_weeks);
                if (validationError != null) {
                  _showSnackBar(validationError, backgroundColor: Colors.red);
                  return;
                }

                final router = GoRouter.of(context);
                final currentFingerprint = _buildEditorFingerprint(_weeks);
                if (currentFingerprint == _baselineFingerprint) {
                  if (router.canPop()) {
                    router.pop();
                    return;
                  }

                  router.go("/workout-plan/${widget.workoutPlanId}");
                  return;
                }

                setState(() {
                  _isSaving = true;
                });

                final cubit = context.read<WorkoutPlanCubit>();
                await cubit.createWorkoutPlanVersionWithWeeks(
                  workoutPlanId: widget.workoutPlanId,
                  weeks: _toBatchInputs(_weeks),
                );

                if (mounted) {
                  if (router.canPop()) {
                    router.pop();
                    return;
                  }

                  router.go("/workout-plan/${widget.workoutPlanId}");
                }
              },
            ),
          ],
        );
      },
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          _showSnackBar(state.error!.description, backgroundColor: Colors.red);
        }
      },
    );
  }
}
