import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/dynamic_list_input.dart';
import 'workout_plan_editor_data.dart';
import 'workout_plan_week_editor.dart';

class WorkoutPlanStructureEditor extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<WorkoutPlanWeekEditorData> weeks;
  final ValueChanged<List<WorkoutPlanWeekEditorData>> onChanged;

  const WorkoutPlanStructureEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.weeks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicListInput<WorkoutPlanWeekEditorData>(
      theme: theme,
      filled: true,
      items: weeks,
      fontSize: sizes.fontSize,
      padding: sizes.padding,
      spacing: sizes.spacing,
      handlesPadding: sizes.padding / 2,
      isLoading: isLoading,
      addLabel: 'Add Week Block',
      keyBuilder: (item) => ValueKey(item.internalId),
      onAdd: () {
        final previous = weeks.lastOrNull;
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
        onChanged([...weeks, created]);
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
        onChanged(reorderedWeeks);
      },
      itemBuilder: (context, index, week) {
        return WorkoutPlanWeekEditor(
          theme: theme,
          sizes: sizes,
          isLoading: isLoading,
          index: index,
          week: week,
          onChanged: (updatedWeek) {
            final updatedWeeks = List<WorkoutPlanWeekEditorData>.from(weeks);
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

            onChanged(updatedWeeks);
          },
        );
      },
    );
  }
}
