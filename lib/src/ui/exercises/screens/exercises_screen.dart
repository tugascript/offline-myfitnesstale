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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/base_common_search_form.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/exercises_list.dart';

class ExercisesScreen extends StatefulWidget {
  static const name = "exercises";

  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    final cubit = context.read<ExerciseCubit>();
    await cubit.getSelectionEquipments();
    if (!mounted) return;
    if (cubit.state.exercises.isEmpty) {
      final pagination = cubit.state.exercisePagination;
      await cubit.getExercises(
        name: pagination.name,
        difficulty: pagination.difficulty,
        muscleGroup: pagination.muscleGroup,
        equipmentId: pagination.equipmentId,
        isFavourite: pagination.isFavorite,
        limit: 20,
        offset: 0,
      );
    }
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
          equipmentId: pagination.equipmentId,
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoints.screenSize);

    return AppScaffold(
      title: "Exercises",
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocBuilder<ExerciseCubit, ExerciseState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BaseCommonSearchForm(
                  theme: theme,
                  nameLabel: "Exercise",
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  isLoading: state.isLoading,
                  initialName: state.exercisePagination.name,
                  initialDifficulty: state.exercisePagination.difficulty,
                  initialMuscleGroup: state.exercisePagination.muscleGroup,
                  initialEquipmentId: state.exercisePagination.equipmentId,
                  equipmentSelection: state.equipmentSelection,
                  initialIsFavorite: state.exercisePagination.isFavorite,
                  onSubmit:
                      ({
                        String? name,
                        Difficulty? difficulty,
                        MuscleGroup? muscleGroup,
                        int? equipmentId,
                        bool isFavourite = false,
                      }) {
                        context.read<ExerciseCubit>().getExercises(
                          name: name,
                          difficulty: difficulty,
                          muscleGroup: muscleGroup,
                          equipmentId: equipmentId,
                          isFavourite: isFavourite,
                          limit: 20,
                          offset: 0,
                        );
                      },
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: ExercisesList(
                    theme: theme,
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
          key: const ValueKey('exercise-add'),
          elevation: sizes.elevation,
          onPressed: () {
            context.push(Routes.exerciseCreation.name);
          },
          shape: BeveledRectangleBorder(),
          child: Icon(Icons.add, size: sizes.buttonIconSize),
        ),
      ),
    );
  }
}
