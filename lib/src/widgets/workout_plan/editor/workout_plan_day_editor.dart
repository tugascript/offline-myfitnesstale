import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/editors/expanding_dynamic_input_wrapper.dart';
import '../../layout/dynamic_list_input.dart';
import '../../layout/sharp_switch.dart';
import 'workout_plan_editor_data.dart';
import 'workout_plan_workout_row_editor.dart';

// TODO: update day based on the order of the days
class WorkoutPlanDayEditor extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final WorkoutPlanDayEditorData day;
  final ValueChanged<WorkoutPlanDayEditorData> onChanged;

  const WorkoutPlanDayEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.day,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizes.padding / 2),
      child: ExpandingDynamicInputWrapper(
        theme: theme,
        sizes: sizes,
        isLoading: isLoading,
        initiallyExpanded: true,
        title: day.isRestDay
            ? "${day.day} - REST DAY"
            : "${day.day} - ${day.workouts.length} Workout(s)",
        labelText: 'Day',
        prefixIcon: Icon(
          Icons.calendar_view_day,
          color: theme.colorScheme.onSurface,
          size: sizes.fontSize * 1.2,
        ),
        children: [
          _RestDaySwitch(
            theme: theme,
            sizes: sizes,
            isLoading: isLoading,
            isRestDay: day.isRestDay,
            onChanged: (value) {
              if (isLoading) {
                return;
              }

              final updated = day.copy()
                ..isRestDay = value
                ..workouts = value ? [] : day.workouts;
              onChanged(updated);
            },
          ),
          if (!day.isRestDay)
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: sizes.padding / 2,
                vertical: sizes.padding / 4,
              ),
              child: DynamicListInput<WorkoutPlanWorkoutEditorData>(
                theme: theme,
                filled: true,
                items: day.workouts,
                fontSize: sizes.smallFontSize,
                padding: sizes.padding / 2,
                spacing: sizes.spacing / 4,
                handlesPadding: sizes.padding / 6,
                addButtonHeight: sizes.fontSize * 3,
                isLoading: isLoading,
                addLabel: 'Add Workout',
                keyBuilder: (item) => ValueKey(item.internalId),
                addEnabled: day.workouts.length < 3,
                onAdd: () {
                  final updated = day.copy()
                    ..workouts = [
                      ...day.workouts,
                      WorkoutPlanWorkoutEditorData(),
                    ];
                  onChanged(updated);
                },
                onChanged: (items) {
                  final updated = day.copy()..workouts = List.from(items);
                  onChanged(updated);
                },
                itemBuilder: (context, index, item) {
                  return WorkoutPlanWorkoutRowEditor(
                    theme: theme,
                    sizes: sizes,
                    isLoading: isLoading,
                    workout: item,
                    onChanged: (updatedWorkout) {
                      final workouts = List<WorkoutPlanWorkoutEditorData>.from(
                        day.workouts,
                      );
                      workouts[index] = updatedWorkout;
                      final updated = day.copy()..workouts = workouts;
                      onChanged(updated);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RestDaySwitch extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final bool isRestDay;
  final ValueChanged<bool> onChanged;

  const _RestDaySwitch({
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.isRestDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: sizes.padding / 2,
        vertical: sizes.padding / 4,
      ),
      child: InkWell(
        onTap: () => onChanged(!isRestDay),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0,
            vertical: sizes.padding / 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.snooze,
                      color: theme.colorScheme.onSurface,
                      size: sizes.fontSize * 1.2,
                    ),
                    Text(
                      " REST DAY",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SharpSwitch(
                value: isRestDay,
                onChanged: onChanged,
                enabled: true,
                padding: EdgeInsets.all(sizes.spacing / 3),
                thumbSize: sizes.fontSize * 1.75,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
