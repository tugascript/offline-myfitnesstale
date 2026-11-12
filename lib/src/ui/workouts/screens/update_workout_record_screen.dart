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
import 'package:material_ui/material_ui.dart';

import '../../../data/utils/enums.dart';
import '../../core/screens/not_found_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../view_models/workout_record_cubit.dart';
import '../widgets/progress/update_workout_record_editor.dart';

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
