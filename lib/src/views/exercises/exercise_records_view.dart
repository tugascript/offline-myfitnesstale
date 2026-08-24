import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/profile_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../cubits/states/profile_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/exercises/records/editors/create_exercise_record_modal.dart';
import '../../widgets/exercises/records/exercise_records_history.dart';
import '../../widgets/exercises/records/latest_exercise_record.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../entity_error_view.dart';
import '../loading_view.dart';

class ExerciseRecordsView extends StatefulWidget {
  static const routeName = "/exercises/:id/records";
  static const name = "exercises-records";

  final int exerciseId;

  const ExerciseRecordsView({
    super.key,
    required this.exerciseId,
  });

  static String location(int exerciseId) =>
      routeName.replaceFirst(':id', exerciseId.toString());

  @override
  State<ExerciseRecordsView> createState() => _ExerciseRecordsViewState();
}

class _ExerciseRecordsViewState extends State<ExerciseRecordsView> {
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
          return const LoadingView(
            title: "Exercise Records",
            message: "Loading exercise records...",
          );
        }

        if (exerciseState.selectedExercise == null) {
          return EntityErrorView(
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
                child: Icon(
                  Icons.add,
                  size: sizes.buttonIconSize,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
