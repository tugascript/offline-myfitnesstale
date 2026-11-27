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
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/cardio_exercise_search_form.dart';
import '../widgets/details/create_exercise_modal.dart';
import '../widgets/exercise_type_toggle.dart';
import '../widgets/exercises_list.dart';

class ExercisesListScreen extends StatefulWidget {
  static const name = "exercises";

  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final _SharedSearchDraft _draft;

  @override
  void initState() {
    super.initState();
    final pagination = context.read<ExerciseCubit>().state.exercisePagination;
    _draft = _SharedSearchDraft(
      name: pagination.name,
      difficulty: pagination.difficulty,
      equipmentId: pagination.equipmentId,
      isFavorite: pagination.isFavorite,
      createdBy: pagination.createdBy,
    );
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
        type: pagination.type,
        difficulty: pagination.difficulty,
        muscleGroup: pagination.muscleGroup,
        cardioBaseMode: pagination.cardioBaseMode,
        cardioUnitType: pagination.cardioUnitType,
        equipmentId: pagination.equipmentId,
        isFavourite: pagination.isFavorite,
        createdBy: pagination.createdBy,
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
          type: pagination.type,
          difficulty: pagination.difficulty,
          muscleGroup: pagination.muscleGroup,
          cardioBaseMode: pagination.cardioBaseMode,
          cardioUnitType: pagination.cardioUnitType,
          equipmentId: pagination.equipmentId,
          isFavourite: pagination.isFavorite,
          createdBy: pagination.createdBy,
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
      ..equipmentId = equipmentId
      ..isFavorite = isFavourite
      ..createdBy = createdBy;
  }

  void _onTypeChanged(ExerciseType nextType) {
    context.read<ExerciseCubit>().getExercises(
      name: _draft.name,
      type: nextType,
      difficulty: _draft.difficulty,
      equipmentId: _draft.equipmentId,
      isFavourite: _draft.isFavorite,
      createdBy: _draft.createdBy,
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
      title: "Exercises",
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
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
            final pagination = state.exercisePagination;
            final pendingQuery = state.pendingExercisesQuery;
            final activeType = pendingQuery?.type ?? pagination.type;
            final isCardio = activeType == ExerciseType.cardio;
            final isReloading =
                pendingQuery != null && pendingQuery.offset == 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExerciseTypeToggle(
                  key: const ValueKey('exercise-search-type-toggle'),
                  selectedType: activeType,
                  sizes: sizes,
                  enabled: !state.isLoading,
                  onChanged: _onTypeChanged,
                ),
                SizedBox(height: sizes.inputSpacing),
                if (isCardio)
                  CardioExerciseSearchForm(
                    key: const ValueKey('cardio-exercise-search-form'),
                    theme: theme,
                    sizes: sizes,
                    isLoading: state.isLoading,
                    initialName: _draft.name,
                    initialDifficulty: _draft.difficulty,
                    initialCardioBaseMode: pagination.cardioBaseMode,
                    initialCardioUnitType: pagination.cardioUnitType,
                    initialEquipmentId: _draft.equipmentId,
                    equipmentSelection: state.equipmentSelection,
                    initialIsFavorite: _draft.isFavorite,
                    initialCreatedBy: _draft.createdBy,
                    showCreatedBy: true,
                    onSharedFiltersChanged: _updateDraft,
                    onSubmit:
                        ({
                          String? name,
                          Difficulty? difficulty,
                          CardioBaseMode? cardioBaseMode,
                          CardioUnitType? cardioUnitType,
                          int? equipmentId,
                          bool isFavourite = false,
                          CreatedBy? createdBy,
                        }) {
                          _updateDraft(
                            name: name ?? '',
                            difficulty: difficulty,
                            equipmentId: equipmentId,
                            isFavourite: isFavourite,
                            createdBy: createdBy,
                          );
                          context.read<ExerciseCubit>().getExercises(
                            name: name,
                            type: ExerciseType.cardio,
                            difficulty: difficulty,
                            cardioBaseMode: cardioBaseMode,
                            cardioUnitType: cardioUnitType,
                            equipmentId: equipmentId,
                            isFavourite: isFavourite,
                            createdBy: createdBy,
                            limit: 20,
                            offset: 0,
                          );
                        },
                  )
                else
                  BaseCommonSearchForm(
                    key: const ValueKey('strength-exercise-search-form'),
                    theme: theme,
                    nameLabel: "Exercise",
                    padding: sizes.padding,
                    fontSize: sizes.fontSize,
                    spacing: sizes.inputSpacing,
                    isLoading: state.isLoading,
                    initialName: _draft.name,
                    initialDifficulty: _draft.difficulty,
                    initialMuscleGroup: pagination.muscleGroup,
                    initialEquipmentId: _draft.equipmentId,
                    equipmentSelection: state.equipmentSelection,
                    initialIsFavorite: _draft.isFavorite,
                    initialCreatedBy: _draft.createdBy,
                    showCreatedBy: true,
                    onSharedFiltersChanged: _updateDraft,
                    onSubmit:
                        ({
                          String? name,
                          Difficulty? difficulty,
                          MuscleGroup? muscleGroup,
                          int? equipmentId,
                          bool isFavourite = false,
                          CreatedBy? createdBy,
                        }) {
                          _updateDraft(
                            name: name ?? '',
                            difficulty: difficulty,
                            equipmentId: equipmentId,
                            isFavourite: isFavourite,
                            createdBy: createdBy,
                          );
                          context.read<ExerciseCubit>().getExercises(
                            name: name,
                            type: ExerciseType.strength,
                            difficulty: difficulty,
                            muscleGroup: muscleGroup,
                            equipmentId: equipmentId,
                            isFavourite: isFavourite,
                            createdBy: createdBy,
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
                    isReloading: isReloading,
                    skeletonType: activeType,
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
            final state = context.read<ExerciseCubit>().state;
            final initialType =
                state.pendingExercisesQuery?.type ??
                state.exercisePagination.type;
            showDialog(
              context: context,
              builder: (context) => CreateExerciseModal(
                theme: theme,
                sizes: sizes,
                initialType: initialType,
              ),
            );
          },
          shape: BeveledRectangleBorder(),
          child: Icon(Icons.add, size: sizes.buttonIconSize),
        ),
      ),
    );
  }
}

final class _SharedSearchDraft {
  String name;
  Difficulty? difficulty;
  int? equipmentId;
  bool isFavorite;
  CreatedBy? createdBy;

  _SharedSearchDraft({
    required this.name,
    required this.difficulty,
    required this.equipmentId,
    required this.isFavorite,
    required this.createdBy,
  });
}
