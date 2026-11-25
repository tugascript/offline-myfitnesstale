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
import '../../core/screens/entity_error_screen.dart';
import '../../core/screens/loading_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/records/editors/create_exercise_record_modal.dart';
import '../widgets/records/exercise_records_history.dart';
import '../widgets/records/latest_exercise_record.dart';

class ExerciseRecordsListScreen extends StatefulWidget {
  static const name = "exercises-records";

  final int exerciseId;

  const ExerciseRecordsListScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseRecordsListScreen> createState() =>
      _ExerciseRecordsListScreenState();
}

class _ExerciseRecordsListScreenState extends State<ExerciseRecordsListScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.selectedExercise?.id != widget.exerciseId) {
      cubit.getExercise(widget.exerciseId);
    }
  }

  @override
  void didUpdateWidget(covariant ExerciseRecordsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId) {
      final cubit = context.read<ExerciseCubit>();
      if (cubit.state.selectedExercise?.id != widget.exerciseId) {
        cubit.getExercise(widget.exerciseId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, exerciseState) {
        final selectedExercise =
            exerciseState.selectedExercise?.id == widget.exerciseId
            ? exerciseState.selectedExercise
            : null;
        if (exerciseState.isLoading && selectedExercise == null) {
          return const LoadingScreen(
            title: "Exercise Records",
            message: "Loading exercise records...",
          );
        }

        if (selectedExercise == null) {
          return EntityErrorScreen(
            sizes: sizes,
            entityName: 'Exercise',
            errorDescription: exerciseState.error?.description,
          );
        }

        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return ResponsiveScaffold(
              title: "${selectedExercise.name} Records",
              isEntity: true,
              body: Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: Column(
                  children: [
                    LatestExerciseRecord(
                      sizes: sizes,
                      theme: theme,
                      units: profileState.system?.units ?? Units.metric,
                      exercise: selectedExercise,
                    ),
                    SizedBox(height: sizes.spacing * 2),
                    ExerciseRecordsHistory(
                      theme: theme,
                      breakPoint: breakpoints,
                      sizes: sizes,
                      units: profileState.system?.units ?? Units.metric,
                      exercise: selectedExercise,
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
