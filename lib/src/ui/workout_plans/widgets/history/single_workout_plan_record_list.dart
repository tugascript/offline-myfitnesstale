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

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import './workout_plan_record_head.dart';

class SingleWorkoutPlanRecordList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;
  final int? workoutPlanId;
  final int? workoutPlanVersion;
  final List<WorkoutPlanRecordDto> planRecords;
  final WorkoutPlanRecordPagination pagination;
  final ScrollController? scrollController;

  const SingleWorkoutPlanRecordList({
    super.key,
    required this.sizes,
    required this.units,
    required this.isLoading,
    this.workoutPlanId,
    this.workoutPlanVersion,
    required this.planRecords,
    required this.pagination,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && planRecords.isEmpty) {
      return NotFoundList(
        sizes: sizes,
        message: 'No plan records found',
        icon: Icons.history,
      );
    }

    final hasMore = planRecords.length < pagination.total;
    final showLoadingIndicator = isLoading && planRecords.isNotEmpty && hasMore;

    return Skeletonizer(
      enabled: isLoading && planRecords.isEmpty,
      child: ListView.builder(
        controller: scrollController,
        itemCount: isLoading && planRecords.isEmpty
            ? 2
            : planRecords.length + (showLoadingIndicator ? 1 : 0),
        itemBuilder: (context, index) {
          if (isLoading && planRecords.isEmpty) {
            return _SingleWorkoutPlanRecordCard(
              sizes: sizes,
              units: units,
              record: WorkoutPlanRecordDto.empty(),
              workoutPlanId: workoutPlanId,
              workoutPlanVersion: workoutPlanVersion,
            );
          }

          if (index == planRecords.length) {
            return Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return _SingleWorkoutPlanRecordCard(
            sizes: sizes,
            units: units,
            record: planRecords[index],
            workoutPlanId: workoutPlanId,
            workoutPlanVersion: workoutPlanVersion,
          );
        },
      ),
    );
  }
}

class _SingleWorkoutPlanRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final WorkoutPlanRecordDto record;
  final int? workoutPlanId;
  final int? workoutPlanVersion;

  const _SingleWorkoutPlanRecordCard({
    required this.sizes,
    required this.units,
    required this.record,
    this.workoutPlanId,
    this.workoutPlanVersion,
  });

  @override
  Widget build(BuildContext context) {
    final status = workoutPlanStatusPresentation(record.status);
    final localDateFormat = DateFormat.yMMMd().add_jm();

    return Card(
      margin: EdgeInsets.only(bottom: sizes.margins),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.workoutPlan != null) ...[
              Text(
                record.workoutPlan!.name,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: sizes.spacing / 2),
            ],
            Row(
              children: [
                Icon(status.icon, color: status.color),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('Version ${record.workoutPlanVersion}'),
              ],
            ),
            SizedBox(height: sizes.spacing),
            Text(
              'Started: ${localDateFormat.format(record.startedAt.toLocal())}',
            ),
            if (record.completedAt != null) ...[
              SizedBox(height: sizes.spacing / 3),
              Text(
                'Completed: ${localDateFormat.format(record.completedAt!.toLocal())}',
              ),
            ],
            SizedBox(height: sizes.spacing / 2),
            Text(
              'Last reached: Week ${record.currentWeek} • Day ${record.currentDay} • Workout ${record.currentWorkoutPosition}',
            ),
          ],
        ),
      ),
    );
  }
}
