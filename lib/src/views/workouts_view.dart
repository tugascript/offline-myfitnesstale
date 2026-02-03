import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/states/workout_state.dart';
import '../cubits/workout_cubit.dart';
import '../models/enums.dart';
import '../utilities/sizes/screen_size.dart';
import '../utilities/sizes/workouts_sizes.dart';
import '../widgets/common/base_common_search_form.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workouts/workouts_list.dart';

class WorkoutsView extends StatefulWidget {
  static const routeName = "/workouts";
  static const name = "workouts";

  const WorkoutsView({super.key});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCubit>();

    if (cubit.state.workouts.isEmpty) {
      cubit.getWorkouts(
        name: "",
        difficulty: null,
        limit: 20,
        offset: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = WorkoutsSizes.getWorkoutsSizes(breakPoints.screenSize);

    return ResponsiveScaffold(
      title: 'Workouts',
      showBackButton: GoRouterState.of(context).extra as bool? ?? false,
      body: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BaseCommonSearchForm(
                  isLoading: state.isLoading,
                  nameLabel: "Workouts",
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  initialName: "",
                  initialDifficulty: null,
                  initialMuscleGroup: null,
                  onSubmit: ({
                    String? name,
                    Difficulty? difficulty,
                    MuscleGroup? muscleGroup,
                  }) {
                    context.read<WorkoutCubit>().getWorkouts(
                          name: name,
                          difficulty: difficulty,
                          muscleGroup: muscleGroup,
                          limit: 20,
                          offset: 0,
                        );
                  },
                ),
                SizedBox(height: sizes.inputSpacing),
                WorkoutsList(
                  sizes: sizes,
                  isLoading: state.isLoading,
                  workouts: state.workouts,
                  pagination: state.pagination,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: sizes.buttonSize,
        height: sizes.buttonSize,
        child: FloatingActionButton(
          elevation: sizes.elevation,
          onPressed: () {
            context.push("/workouts/create");
          },
          shape: const CircleBorder(),
          child: Icon(Icons.add, size: sizes.buttonIconSize),
        ),
      ),
    );
  }
}
