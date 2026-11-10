import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/base_common_search_form.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/details/create_workout_modal.dart';
import '../widgets/workouts_list.dart';

class WorkoutsScreen extends StatefulWidget {
  static const name = "workouts";

  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCubit>();

    if (cubit.state.workouts.isEmpty) {
      final pagination = cubit.state.pagination;
      cubit.getWorkouts(
        name: pagination.name,
        difficulty: pagination.difficulty,
        muscleGroup: pagination.muscleGroup,
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
      final cubit = context.read<WorkoutCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.pagination.total > cubit.state.workouts.length) {
        final pagination = cubit.state.pagination;
        cubit.getWorkouts(
          name: pagination.name,
          difficulty: pagination.difficulty,
          muscleGroup: pagination.muscleGroup,
          isFavorite: pagination.isFavorite,
          offset: cubit.state.workouts.length,
          limit: 20,
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
    final theme = Theme.of(context);
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoints.screenSize);

    return AppScaffold(
      title: 'Workouts',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BaseCommonSearchForm(
                  theme: theme,
                  isLoading: state.isLoading,
                  nameLabel: "Workouts",
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  initialName: state.pagination.name,
                  initialDifficulty: state.pagination.difficulty,
                  initialMuscleGroup: state.pagination.muscleGroup,
                  initialIsFavorite: state.pagination.isFavorite,
                  onSubmit:
                      ({
                        required difficulty,
                        required isFavourite,
                        required muscleGroup,
                        required equipmentId,
                        required name,
                      }) => context.read<WorkoutCubit>().getWorkouts(
                        name: name,
                        difficulty: difficulty,
                        muscleGroup: muscleGroup,
                        limit: 20,
                        offset: 0,
                        isFavorite: isFavourite,
                      ),
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: WorkoutsList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    workouts: state.workouts,
                    pagination: state.pagination,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('workout-add'),
        elevation: sizes.elevation,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateWorkoutDialog(sizes: sizes),
          );
        },
        shape: BeveledRectangleBorder(),
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
