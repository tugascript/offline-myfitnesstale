import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/profile_cubit.dart';
import '../../../cubits/states/profile_state.dart';
import '../../../cubits/states/workout_record_state.dart';
import '../../../cubits/states/workout_state.dart';
import '../../../cubits/workout_cubit.dart';
import '../../../cubits/workout_record_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routing.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../widgets/progress/history/latest_workout_record.dart';
import '../widgets/progress/history/workout_record_history.dart';

class WorkoutHistoryView extends StatefulWidget {
  final int? workoutId;
  final int? version;

  const WorkoutHistoryView({super.key, this.workoutId, this.version});

  static String location({int? workoutId, int? version}) {
    if (workoutId == null) {
      return Routes.workoutHistory.name;
    }
    if (version == null) {
      return '${Routes.workoutHistory.name}?id=$workoutId';
    }
    return '${Routes.workoutHistory.name}?id=$workoutId&version=$version';
  }

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  @override
  void initState() {
    super.initState();

    if (widget.workoutId != null) {
      final workoutCubit = context.read<WorkoutCubit>();
      if (widget.version == null ||
          workoutCubit.state.selectedWorkout?.id != widget.workoutId ||
          workoutCubit.state.selectedWorkout?.version != widget.version) {
        workoutCubit.getWorkout(widget.workoutId!, version: widget.version);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    final isSingleWorkout = widget.workoutId != null;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, workoutState) {
        final selectedWorkout =
            workoutState.selectedWorkout?.id == widget.workoutId &&
                (widget.version != null || !workoutState.isLoading)
            ? workoutState.selectedWorkout
            : null;
        final workoutVersion = isSingleWorkout
            ? (widget.version ?? selectedWorkout?.version ?? 1)
            : null;

        return ResponsiveScaffold(
          title: isSingleWorkout
              ? (selectedWorkout?.name ?? 'Workout History')
              : 'Workout History',
          isEntity: isSingleWorkout,
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
                          workoutVersion: workoutVersion,
                        ),
                        SizedBox(height: sizes.spacing),
                        WorkoutRecordHistory(
                          theme: theme,
                          breakPoint: breakpoints,
                          sizes: sizes,
                          units: units,
                          workoutId: widget.workoutId,
                          workoutVersion: workoutVersion,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: isSingleWorkout
              ? FloatingActionButton(
                  key: const ValueKey('workout-record-add'),
                  elevation: sizes.elevation,
                  onPressed: () {
                    context.push(
                      Routes.createWorkoutRecord.name
                          .replaceFirst(':id', widget.workoutId.toString())
                          .replaceFirst(
                            ':version',
                            (workoutVersion ?? 1).toString(),
                          ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
