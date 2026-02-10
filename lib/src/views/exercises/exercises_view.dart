import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/exercises/exercise_search_form.dart';
import '../../widgets/exercises/exercises_list.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'exercise_creation_view.dart';

class ExercisesView extends StatefulWidget {
  static const routeName = "/exercises";
  static const name = "exercises";

  const ExercisesView({super.key});

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.exercises.isEmpty) {
      final pagination = cubit.state.exercisePagination;
      cubit.getExercises(
        name: pagination.name,
        difficulty: pagination.difficulty,
        muscleGroup: pagination.muscleGroup,
        isFavourite: pagination.isFavorite,
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
      final cubit = context.read<ExerciseCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.exercisePagination.total > cubit.state.exercises.length) {
        final pagination = cubit.state.exercisePagination;
        cubit.getExercises(
          name: pagination.name,
          difficulty: pagination.difficulty,
          muscleGroup: pagination.muscleGroup,
          isFavourite: pagination.isFavorite,
          offset: cubit.state.exercises.length,
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakPoints.screenSize,
    );

    return AppScaffold(
      title: "Exercises",
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: BlocBuilder<ExerciseCubit, ExerciseState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExerciseSearchForm(
                  theme: theme,
                  sizes: sizes,
                  isLoading: state.isLoading,
                  initialName: state.exercisePagination.name,
                  initialDifficulty: state.exercisePagination.difficulty,
                  initialMuscleGroup: state.exercisePagination.muscleGroup,
                  initialIsFavourite: state.exercisePagination.isFavorite,
                  onSubmit: ({
                    String? name,
                    Difficulty? difficulty,
                    MuscleGroup? muscleGroup,
                    bool isFavourite = false,
                  }) {
                    context.read<ExerciseCubit>().getExercises(
                          name: name,
                          difficulty: difficulty,
                          muscleGroup: muscleGroup,
                          isFavourite: isFavourite,
                          limit: 20,
                          offset: 0,
                        );
                  },
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: ExercisesList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    exercises: state.exercises,
                    scrollController: _scrollController,
                  ),
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
            context.push(ExerciseCreationView.routeName);
          },
          shape: BeveledRectangleBorder(),
          child: Icon(Icons.add, size: sizes.buttonIconSize),
        ),
      ),
    );
  }
}
