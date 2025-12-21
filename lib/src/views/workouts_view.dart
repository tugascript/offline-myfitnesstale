import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/states/workout_state.dart';
import '../cubits/workout_cubit.dart';
import '../models/enums.dart';
import '../utilities/sizes/screen_size.dart';
import '../utilities/sizes/workouts_sizes.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workouts/workouts_list.dart';
import '../widgets/workouts/workouts_search.dart';

class WorkoutsView extends StatelessWidget {
  static const routeName = "/workouts";
  static const name = "workouts";

  const WorkoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = WorkoutsSizes.getWorkoutsSizes(breakPoints.screenSize);

    return ResponsiveScaffold(
      title: 'Workouts',
      body: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                WorkoutsSearch(
                  isLoading: state.isLoading,
                  sizes: sizes,
                  initialName: "",
                  initialDifficulty: null,
                  onSubmit: ({String? name, Difficulty? difficulty}) {
                    context.read<WorkoutCubit>().getWorkouts(
                          name: name,
                          difficulty: difficulty,
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
