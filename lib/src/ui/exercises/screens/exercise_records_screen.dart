import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/exercise_cubit.dart';
import '../../home/view_models/profile_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../../home/view_models/states/profile_state.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routing.dart';
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
