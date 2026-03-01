import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/states/workout_plan_state.dart';
import '../../cubits/workout_plan_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/workout_plan/editor/create_workout_plan_modal.dart';
import '../../widgets/workout_plan/workout_plan_search_form.dart';
import '../../widgets/workout_plan/workout_plans_list.dart';

class WorkoutPlanListView extends StatefulWidget {
  static const routeName = '/workout-plans';

  const WorkoutPlanListView({super.key});

  @override
  State<WorkoutPlanListView> createState() => _WorkoutPlanListViewState();
}

class _WorkoutPlanListViewState extends State<WorkoutPlanListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutPlanCubit>();
    final cubitState = cubit.state;

    if (cubitState.workoutPlans.isEmpty) {
      cubit.getWorkoutPlans(
        name: null,
        difficulty: null,
        limit: 20,
        offset: 0,
      );
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = context.read<WorkoutPlanCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.pagination.total > cubit.state.workoutPlans.length) {
        cubit.getWorkoutPlans(
          offset: cubit.state.workoutPlans.length,
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoints.screenSize);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Workout Plans',
      body: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error!.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                WorkoutPlanSearchForm(
                  nameLabel: "Plans",
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  isLoading: state.isLoading,
                  initialName: "",
                  initialDifficulty: null,
                  onSubmit: ({
                    required String name,
                    required Difficulty? difficulty,
                  }) {
                    context.read<WorkoutPlanCubit>().getWorkoutPlans(
                          name: name,
                          difficulty: difficulty,
                          limit: 20,
                          offset: 0,
                        );
                  },
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: WorkoutPlansList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    workoutPlans: state.workoutPlans,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: sizes.elevation,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateWorkoutPlanModal(
              theme: theme,
              sizes: sizes,
            ),
          );
        },
        shape: BeveledRectangleBorder(),
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
