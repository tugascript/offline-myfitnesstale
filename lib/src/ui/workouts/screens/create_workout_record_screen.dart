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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../widgets/progress/create_workout_record_editor.dart';

class CreateWorkoutRecordScreen extends StatefulWidget {
  final int workoutId;
  final int version;
  final int? workoutPlanRecordId;
  final int? week;
  final int? day;
  final int? workoutPosition;

  const CreateWorkoutRecordScreen({
    super.key,
    required this.workoutId,
    required this.version,
    this.workoutPlanRecordId,
    this.week,
    this.day,
    this.workoutPosition,
  });

  @override
  State<CreateWorkoutRecordScreen> createState() =>
      _CreateWorkoutRecordScreenState();
}

class _CreateWorkoutRecordScreenState extends State<CreateWorkoutRecordScreen> {
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
