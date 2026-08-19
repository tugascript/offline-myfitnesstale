import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_record_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../cubits/workout_record_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/history/latest_workout_record.dart';
import '../../widgets/workouts/progress/history/workout_record_history.dart';
import 'create_workout_record_view.dart';

class WorkoutHistoryView extends StatefulWidget {
  static const routeName = '/workouts/:id/history/:version';

  final int workoutId;
  final int version;

  const WorkoutHistoryView({
    super.key,
    required this.workoutId,
    required this.version,
  });

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  @override
  void initState() {
    super.initState();

    final workoutCubit = context.read<WorkoutCubit>();
    if (workoutCubit.state.selectedWorkout?.id != widget.workoutId ||
        workoutCubit.state.selectedWorkout?.version != widget.version) {
      workoutCubit.getWorkout(widget.workoutId, version: widget.version);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, workoutState) {
        return ResponsiveScaffold(
          title: workoutState.selectedWorkout?.name ?? 'Workout History',
          isEntity: true,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final units = profileState.system?.units ?? Units.metric;
              return Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: BlocConsumer<WorkoutRecordCubit, WorkoutRecordState>(
                  listener: (context, state) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!.description),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatestWorkoutRecord(
                          sizes: sizes,
                          theme: theme,
                          units: units,
                          workoutId: widget.workoutId,
                          workoutVersion:
                              workoutState.selectedWorkout?.version ?? 1,
                        ),
                        SizedBox(height: sizes.spacing),
                        WorkoutRecordHistory(
                          theme: theme,
                          breakPoint: breakpoints,
                          sizes: sizes,
                          units: units,
                          workoutId: widget.workoutId,
                          workoutVersion:
                              workoutState.selectedWorkout?.version ?? 1,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('workout-record-add'),
            elevation: sizes.elevation,
            onPressed: () {
              context.push(
                CreateWorkoutRecordView.routeName
                    .replaceFirst(':id', widget.workoutId.toString())
                    .replaceFirst(':version', widget.version.toString()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
