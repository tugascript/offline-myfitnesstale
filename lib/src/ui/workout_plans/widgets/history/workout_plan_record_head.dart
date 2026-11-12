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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/progress_status_presentation.dart';
import '../../../core/widgets/total_numeric_string.dart';

class WorkoutPlanRecordHead extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final WorkoutPlanRecordDto? workoutPlanRecord;

  const WorkoutPlanRecordHead({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutPlanRecord,
  });

  @override
  Widget build(BuildContext context) {
    final status = workoutPlanRecord != null
        ? ProgressStatusPresentation.fromStatus(workoutPlanRecord!.status)
        : null;

    return Skeletonizer(
      enabled: isLoading || workoutPlanRecord == null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workoutPlanRecord?.workoutPlan != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_note, size: sizes.subtitleFontSize * 1.2),
                Flexible(
                  child: Text(
                    " ${workoutPlanRecord!.workoutPlan!.name}",
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
          ],
          if (status != null) ...[
            Row(
              children: [
                Icon(
                  status.icon,
                  color: status.color,
                  size: sizes.fontSize * 1.2,
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: sizes.fontSize,
                    ),
                  ),
                ),
                Text(
                  'Version ${workoutPlanRecord?.workoutPlanVersion ?? 1}',
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: sizes.fontSize * 1.2),
                    Flexible(
                      child: Text(
                        " ${Formatters.formatDateTimeRange(units, workoutPlanRecord?.startedAt ?? DateTime.now(), workoutPlanRecord?.completedAt)}",
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (workoutPlanRecord?.completedAt != null) ...[
                SizedBox(width: sizes.spacing),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: sizes.fontSize * 1.2),
                    Text(
                      " ${Formatters.formatDuration(workoutPlanRecord!.completedAt!.difference(workoutPlanRecord!.startedAt).inSeconds)}",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: sizes.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TotalNumericString(
                  leading: Icon(
                    Icons.calendar_view_week,
                    size: sizes.fontSize * 1.2,
                  ),
                  name: 'Week',
                  total: workoutPlanRecord?.currentWeek ?? 1,
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: TotalNumericString(
                  leading: Icon(Icons.today, size: sizes.fontSize * 1.2),
                  name: 'Day',
                  total: workoutPlanRecord?.currentDay ?? 1,
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: TotalNumericString(
                  leading: Icon(
                    Icons.fitness_center,
                    size: sizes.fontSize * 1.2,
                  ),
                  name: 'Workout',
                  total: workoutPlanRecord?.currentWorkoutPosition ?? 1,
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.spacing / 2),
          Text(
            'Last reached: Week ${workoutPlanRecord?.currentWeek ?? 1} • Day ${workoutPlanRecord?.currentDay ?? 1} • Workout ${workoutPlanRecord?.currentWorkoutPosition ?? 1}',
            style: TextStyle(fontSize: sizes.fontSize),
          ),
        ],
      ),
    );
  }
}
