import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../view_models/workout_record_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../widgets/progress/update_workout_record_editor.dart';
import '../../core/screens/not_found_screen.dart';

class UpdateWorkoutRecordScreen extends StatefulWidget {
  final int workoutId;
  final int workoutRecordId;
  final int version;

  const UpdateWorkoutRecordScreen({
    super.key,
    required this.workoutId,
    required this.workoutRecordId,
    required this.version,
  });

  @override
  State<UpdateWorkoutRecordScreen> createState() =>
      _UpdateWorkoutRecordScreenState();
}

class _UpdateWorkoutRecordScreenState extends State<UpdateWorkoutRecordScreen> {
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
          return NotFoundScreen();
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
                      workoutId: widget.workoutId,
                      version: widget.version,
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
