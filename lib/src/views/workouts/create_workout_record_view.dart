import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/create_workout_record_editor.dart';

class CreateWorkoutRecordView extends StatefulWidget {
  static const routeName = '/workouts/:id/history/:version/records/create';

  final int workoutId;
  final int version;
  final int? workoutPlanRecordId;
  final int? week;
  final int? day;
  final int? workoutPosition;

  const CreateWorkoutRecordView({
    super.key,
    required this.workoutId,
    required this.version,
    this.workoutPlanRecordId,
    this.week,
    this.day,
    this.workoutPosition,
  });

  @override
  State<CreateWorkoutRecordView> createState() =>
      _CreateWorkoutRecordViewState();
}

class _CreateWorkoutRecordViewState extends State<CreateWorkoutRecordView> {
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, workoutState) {
        if (workoutState.isLoading || workoutState.selectedWorkout == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final workout = workoutState.selectedWorkout!;
        if (workout.sets == null || workout.sets!.isEmpty) {
          return const Center(child: Text('This workout has no sets to log.'));
        }

        return ResponsiveScaffold(
          title: workoutState.selectedWorkout?.name ?? 'Log Past Workout',
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Workout Record',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    return CreateWorkoutRecordEditor(
                      theme: theme,
                      sizes: sizes,
                      units: profileState.system?.units ?? Units.metric,
                      workoutId: widget.workoutId,
                      version: widget.version,
                      sets: workout.sets!,
                      workoutPlanRecordId: widget.workoutPlanRecordId,
                      week: widget.week,
                      day: widget.day,
                      workoutPosition: widget.workoutPosition,
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
