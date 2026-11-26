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
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/base_common_search_form.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../widgets/details/create_workout_modal.dart';
import '../widgets/workout_type_toggle.dart';
import '../widgets/workouts_list.dart';

class WorkoutsScreen extends StatefulWidget {
  static const name = "workouts";

  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final ScrollController _scrollController = ScrollController();
  late final _SharedWorkoutSearchDraft _draft;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCubit>();
    final pagination = cubit.state.pagination;
    _draft = _SharedWorkoutSearchDraft(
      name: pagination.name,
      difficulty: pagination.difficulty,
      isFavorite: pagination.isFavorite,
      createdBy: pagination.createdBy,
    );

    if (cubit.state.workouts.isEmpty) {
      cubit.getWorkouts(
        name: pagination.name,
        difficulty: pagination.difficulty,
        muscleGroup: pagination.muscleGroup,
        isFavorite: pagination.isFavorite,
        createdBy: pagination.createdBy,
        type: pagination.type,
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
          createdBy: pagination.createdBy,
          type: pagination.type,
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

  void _updateDraft({
    required String name,
    required Difficulty? difficulty,
    required int? equipmentId,
    required bool isFavourite,
    required CreatedBy? createdBy,
  }) {
    _draft
      ..name = name
      ..difficulty = difficulty
      ..isFavorite = isFavourite
      ..createdBy = createdBy;
  }

  void _onTypeChanged(ExerciseType nextType) {
    context.read<WorkoutCubit>().getWorkouts(
      name: _draft.name,
      difficulty: _draft.difficulty,
      muscleGroup: null,
      isFavorite: _draft.isFavorite,
      createdBy: _draft.createdBy,
      type: nextType,
      limit: 20,
      offset: 0,
    );
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
        child: BlocConsumer<WorkoutCubit, WorkoutState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) {
            if (state.error == null) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!.description)));
          },
          builder: (context, state) {
            final pagination = state.pagination;
            final pendingQuery = state.pendingWorkoutsQuery;
            final activeType = pendingQuery?.type ?? pagination.type;
            final isCardio = activeType == ExerciseType.cardio;
            final isReloading =
                pendingQuery != null && pendingQuery.offset == 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                WorkoutTypeToggle(
                  key: const ValueKey('workout-search-type-toggle'),
                  selectedType: activeType,
                  sizes: sizes,
                  enabled: !state.isLoading,
                  onChanged: _onTypeChanged,
                ),
                SizedBox(height: sizes.inputSpacing),
                BaseCommonSearchForm(
                  theme: theme,
                  isLoading: state.isLoading,
                  nameLabel: "Workouts",
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  initialName: _draft.name,
                  initialDifficulty: _draft.difficulty,
                  initialMuscleGroup: isCardio ? null : pagination.muscleGroup,
                  initialIsFavorite: _draft.isFavorite,
                  initialCreatedBy: _draft.createdBy,
                  showMuscleGroup: !isCardio,
                  showCreatedBy: true,
                  onSharedFiltersChanged: _updateDraft,
                  onSubmit:
                      ({
                        required difficulty,
                        required isFavourite,
                        required muscleGroup,
                        required equipmentId,
                        required name,
                        required createdBy,
                      }) {
                        _updateDraft(
                          name: name,
                          difficulty: difficulty,
                          equipmentId: equipmentId,
                          isFavourite: isFavourite,
                          createdBy: createdBy,
                        );
                        context.read<WorkoutCubit>().getWorkouts(
                          name: name,
                          difficulty: difficulty,
                          muscleGroup: isCardio ? null : muscleGroup,
                          type: activeType,
                          limit: 20,
                          offset: 0,
                          isFavorite: isFavourite,
                          createdBy: createdBy,
                        );
                      },
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: WorkoutsList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    isReloading: isReloading,
                    skeletonType: activeType,
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
          final state = context.read<WorkoutCubit>().state;
          final activeType =
              state.pendingWorkoutsQuery?.type ?? state.pagination.type;
          final initialEditorType = activeType == ExerciseType.cardio
              ? EditorType.cardio
              : EditorType.basic;
          showDialog(
            context: context,
            builder: (context) => CreateWorkoutDialog(
              sizes: sizes,
              initialEditorType: initialEditorType,
            ),
          );
        },
        shape: const BeveledRectangleBorder(),
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}

final class _SharedWorkoutSearchDraft {
  String name;
  Difficulty? difficulty;
  bool isFavorite;
  CreatedBy? createdBy;

  _SharedWorkoutSearchDraft({
    required this.name,
    required this.difficulty,
    required this.isFavorite,
    required this.createdBy,
  });
}
