import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/utilities.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/editors/expanding_dynamic_input_wrapper.dart';
import '../../../layout/app_dropdown.dart';
import '../../../layout/dynamic_list_input.dart';
import 'weeks_input.dart';
import 'workout_plan_day_editor.dart';
import 'workout_plan_editor_data.dart';

class WorkoutPlanWeekEditor extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final int index;
  final WorkoutPlanWeekEditorData week;
  final ValueChanged<WorkoutPlanWeekEditorData> onChanged;

  const WorkoutPlanWeekEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.index,
    required this.week,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: WeeksInput(
                    sizes: sizes,
                    theme: theme,
                    currentWeek: week.startWeek,
                    initialEndWeek: week.endWeek,
                    startWeekOnChanged: (value) {
                      final int parsed = int.tryParse(value) ?? week.startWeek;
                      final updated = week.copy()..startWeek = parsed;
                      onChanged(updated);
                    },
                    endWeekOnChanged: (value) {
                      final int parsed = int.tryParse(value) ?? week.endWeek;
                      final updated = week.copy()..endWeek = parsed;
                      onChanged(updated);
                    },
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: AppDropdown<WorkoutPhase>(
                    filled: true,
                    value: week.phase,
                    emptyLabel: 'No Phase',
                    labelText: 'Phase',
                    items: WorkoutPhase.values,
                    fontSize: sizes.fontSize,
                    padding: sizes.padding * 0.4,
                    labelBuilder: EnumDisplayNames.getWorkoutPhaseDisplayName,
                    onChanged: isLoading
                        ? (_) {}
                        : (value) {
                            final updated = week.copy()..phase = value;
                            onChanged(updated);
                          },
                    onSaved: (_) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            ExpandingDynamicInputWrapper(
              theme: theme,
              sizes: sizes,
              isLoading: isLoading,
              initiallyExpanded: week.initiallyExpanded,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface,
                size: sizes.fontSize * 1.2,
              ),
              title: week.days.isEmpty
                  ? "0"
                  : week.days.length > 1
                      ? "1 - ${week.days.length}"
                      : "1",
              labelText: 'Days',
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(sizes.spacing),
                  child: DynamicListInput<WorkoutPlanDayEditorData>(
                    theme: theme,
                    filled: true,
                    items: week.days,
                    fontSize: sizes.smallFontSize,
                    padding: sizes.padding / 2,
                    spacing: sizes.spacing / 2,
                    handlesPadding: sizes.padding / 6,
                    addButtonHeight: sizes.fontSize * 3,
                    isLoading: isLoading,
                    addLabel: 'Add Day',
                    keyBuilder: (item) => ValueKey(item.internalId),
                    addEnabled: week.days.length < 7,
                    onAdd: () {
                      final usedDays = week.days.map((d) => d.day).toSet();
                      final nextDay = ([for (int i = 1; i <= 7; i++) i]
                          .where((day) => !usedDays.contains(day))
                          .firstOrNull);
                      if (nextDay == null) {
                        return;
                      }

                      final updated = week.copy()
                        ..days = [
                          ...week.days,
                          WorkoutPlanDayEditorData(
                            day: nextDay,
                            isRestDay: false,
                            initiallyExpanded: true,
                            workouts: [],
                          ),
                        ];
                      onChanged(updated);
                    },
                    onChanged: (items) {
                      final updatedDays = <WorkoutPlanDayEditorData>[];
                      for (int i = 0; i < items.length; i++) {
                        final dayData = items[i].copy()..day = i + 1;
                        updatedDays.add(dayData);
                      }
                      final updated = week.copy()..days = updatedDays;
                      onChanged(updated);
                    },
                    itemBuilder: (context, dayIndex, day) {
                      return WorkoutPlanDayEditor(
                        theme: theme,
                        sizes: sizes,
                        isLoading: isLoading,
                        day: day,
                        onChanged: (updatedDay) {
                          final updatedDays =
                              List<WorkoutPlanDayEditorData>.from(
                            week.days,
                          );
                          updatedDays[dayIndex] = updatedDay;
                          final updated = week.copy()..days = updatedDays;
                          onChanged(updated);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
