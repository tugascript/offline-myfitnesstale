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

import '../view_models/states/workout_plan_state.dart';
import '../view_models/workout_plan_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/editor/create_workout_plan_modal.dart';
import '../widgets/workout_plan_search_form.dart';
import '../widgets/workout_plans_list.dart';

class WorkoutPlanListScreen extends StatefulWidget {
  const WorkoutPlanListScreen({super.key});

  @override
  State<WorkoutPlanListScreen> createState() => _WorkoutPlanListScreenState();
}

class _WorkoutPlanListScreenState extends State<WorkoutPlanListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutPlanCubit>();
    final cubitState = cubit.state;

    if (cubitState.workoutPlans.isEmpty) {
      cubit.getWorkoutPlans(
        name: cubitState.pagination.name,
        difficulty: cubitState.pagination.difficulty,
        isFavorite: cubitState.pagination.isFavorite,
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
        final pagination = cubit.state.pagination;
        cubit.getWorkoutPlans(
          name: pagination.name,
          difficulty: pagination.difficulty,
          isFavorite: pagination.isFavorite,
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
        padding: EdgeInsets.all(sizes.viewPadding),
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
                  initialName: state.pagination.name,
                  initialDifficulty: state.pagination.difficulty,
                  initialIsFavorite: state.pagination.isFavorite,
                  onSubmit:
                      ({
                        required String name,
                        required Difficulty? difficulty,
                        required bool isFavorite,
                      }) {
                        context.read<WorkoutPlanCubit>().getWorkoutPlans(
                          name: name,
                          difficulty: difficulty,
                          isFavorite: isFavorite,
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
        key: const ValueKey('workout-plan-add'),
        elevation: sizes.elevation,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                CreateWorkoutPlanModal(theme: theme, sizes: sizes),
          );
        },
        shape: BeveledRectangleBorder(),
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
