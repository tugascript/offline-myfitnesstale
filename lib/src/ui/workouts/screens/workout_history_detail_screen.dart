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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/workouts/dtos/workout_set_record_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/states/workout_record_state.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../view_models/workout_record_cubit.dart';
import '../widgets/progress/history/detail/workout_record_head_card.dart';
import '../widgets/progress/history/detail/workout_record_sets.dart';

class WorkoutHistoryDetailScreen extends StatefulWidget {
  final int workoutId;
  final int workoutRecordId;
  final int version;

  const WorkoutHistoryDetailScreen({
    super.key,
    required this.workoutId,
    required this.workoutRecordId,
    required this.version,
  });

  @override
  State<WorkoutHistoryDetailScreen> createState() =>
      _WorkoutHistoryDetailScreenState();
}

class _WorkoutHistoryDetailScreenState
    extends State<WorkoutHistoryDetailScreen> {
  @override
  void initState() {
    super.initState();

    final workoutCubit = context.read<WorkoutCubit>();
    if (workoutCubit.state.selectedWorkout?.id != widget.workoutId ||
        workoutCubit.state.selectedWorkout?.version != widget.version) {
      workoutCubit.getWorkout(widget.workoutId, version: widget.version);
    }

    final workoutRecordCubit = context.read<WorkoutRecordCubit>();
    if (workoutRecordCubit.state.selectedWorkoutRecord?.id !=
        widget.workoutRecordId) {
      workoutRecordCubit.getWorkoutRecord(widget.workoutRecordId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, workoutState) {
            return ResponsiveScaffold(
              title: workoutState.selectedWorkout?.name ?? 'Workout Details',
              body: Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
                  builder: (context, workoutRecordState) {
                    final Map<int, List<WorkoutSetRecordDto>> setRecordsMap =
                        workoutRecordState.selectedWorkoutRecord?.setRecords
                            ?.fold<Map<int, List<WorkoutSetRecordDto>>>(
                              {},
                              (map, s) => map
                                ..update(
                                  s.workoutSetId,
                                  (value) => value..add(s),
                                  ifAbsent: () => [s],
                                ),
                            ) ??
                        {};

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record details',
                          style: TextStyle(
                            fontSize: sizes.titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: sizes.spacing),
                        WorkoutRecordHeadCard(
                          sizes: sizes,
                          theme: theme,
                          units: profileState.system?.units ?? Units.metric,
                          isLoading: workoutRecordState.isLoading,
                          workoutRecord:
                              workoutRecordState.selectedWorkoutRecord,
                        ),
                        SizedBox(height: sizes.spacing),
                        WorkoutRecordSets(
                          sizes: sizes,
                          theme: theme,
                          units: profileState.system?.units ?? Units.metric,
                          data:
                              workoutState.selectedWorkout?.sets
                                  ?.where(
                                    (set) => setRecordsMap[set.id] != null,
                                  )
                                  .map(
                                    (set) => WorkoutRecordSetsData(
                                      workoutSet: set,
                                      setRecords: setRecordsMap[set.id]!,
                                    ),
                                  )
                                  .toList() ??
                              [],
                        ),
                        SizedBox(height: sizes.spacing),
                        MutationButtons(
                          padding: 0,
                          theme: theme,
                          sizes: sizes,
                          isLoading: workoutRecordState.isLoading,
                          onEdit: () {
                            context.push(
                              Routes.updateWorkoutRecord.name
                                  .replaceFirst(
                                    ':workoutId',
                                    widget.workoutId.toString(),
                                  )
                                  .replaceFirst(
                                    ':version',
                                    widget.version.toString(),
                                  )
                                  .replaceFirst(
                                    ':workoutRecordId',
                                    widget.workoutRecordId.toString(),
                                  ),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: 'Delete workout record',
                                content: 'Are you sure you want to delete this workout record? This action cannot be undone.',
                                onConfirm: () {
                                  context
                                      .read<WorkoutRecordCubit>()
                                      .deleteWorkoutRecord(
                                        widget.workoutRecordId,
                                      );
                                  context.pop();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
