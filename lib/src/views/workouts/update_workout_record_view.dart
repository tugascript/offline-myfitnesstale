import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../cubits/workout_record_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/update_workout_record_editor.dart';
import '../not_found_view.dart';

class UpdateWorkoutRecordView extends StatefulWidget {
  static const routeName =
      '/workouts/:workoutId/history/:version/records/:workoutRecordId/update';

  final int workoutId;
  final int workoutRecordId;
  final int version;

  const UpdateWorkoutRecordView({
    super.key,
    required this.workoutId,
    required this.workoutRecordId,
    required this.version,
  });

  @override
  State<UpdateWorkoutRecordView> createState() =>
      _UpdateWorkoutRecordViewState();
}

class _UpdateWorkoutRecordViewState extends State<UpdateWorkoutRecordView> {
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

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, workoutState) {
        if (workoutState.selectedWorkout == null) {
          return NotFoundView();
        }

        final workout = workoutState.selectedWorkout!;
        if (workout.sets == null || workout.sets!.isEmpty) {
          return const Center(child: Text('This workout has no sets to log.'));
        }

        return ResponsiveScaffold(
          title: workoutState.selectedWorkout?.name ?? 'Update Workout Record',
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Workout Record',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    return UpdateWorkoutRecordEditor(
                      theme: theme,
                      sizes: sizes,
                      units: profileState.system?.units ?? Units.metric,
                      workoutRecordId: widget.workoutRecordId,
                      sets: workout.sets!,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
