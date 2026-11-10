// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/exercise_cubit.dart';
import '../../home/view_models/profile_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../../home/view_models/states/profile_state.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../widgets/records/editors/create_exercise_record_modal.dart';
import '../widgets/records/exercise_records_history.dart';
import '../widgets/records/latest_exercise_record.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/screens/entity_error_screen.dart';
import '../../core/screens/loading_screen.dart';

class ExerciseRecordsScreen extends StatefulWidget {
  static const name = "exercises-records";

  final int exerciseId;

  const ExerciseRecordsScreen({super.key, required this.exerciseId});

  static String location(int exerciseId) =>
      Routes.exerciseRecords.name.replaceFirst(':id', exerciseId.toString());

  @override
  State<ExerciseRecordsScreen> createState() => _ExerciseRecordsScreenState();
}

class _ExerciseRecordsScreenState extends State<ExerciseRecordsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.selectedExercise?.id != widget.exerciseId) {
      cubit.getExercise(widget.exerciseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, exerciseState) {
        if (exerciseState.isLoading && exerciseState.selectedExercise == null) {
          return const LoadingScreen(
            title: "Exercise Records",
            message: "Loading exercise records...",
          );
        }

        if (exerciseState.selectedExercise == null) {
          return EntityErrorScreen(
            sizes: sizes,
            entityName: 'Exercise',
            errorDescription: exerciseState.error?.description,
          );
        }

        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return ResponsiveScaffold(
              title: "${exerciseState.selectedExercise?.name} Records",
              isEntity: true,
              body: Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: Column(
                  children: [
                    LatestExerciseRecord(
                      sizes: sizes,
                      theme: theme,
                      units: profileState.system?.units ?? Units.metric,
                      exercise: exerciseState.selectedExercise!,
                    ),
                    SizedBox(height: sizes.spacing * 2),
                    ExerciseRecordsHistory(
                      theme: theme,
                      breakPoint: breakpoints,
                      sizes: sizes,
                      units: profileState.system?.units ?? Units.metric,
                      exercise: exerciseState.selectedExercise!,
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                key: const ValueKey('exercise-record-add'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CreateExerciseRecordModal(
                      theme: theme,
                      sizes: sizes,
                      units: profileState.system?.units ?? Units.metric,
                      exerciseId: widget.exerciseId,
                    ),
                  );
                },
                child: Icon(Icons.add, size: sizes.buttonIconSize),
              ),
            );
          },
        );
      },
    );
  }
}
