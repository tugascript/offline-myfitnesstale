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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../../data/repositories/workouts/inputs/workout_cardio_set_exercise_upsert_input.dart';
import '../../../../../data/repositories/workouts/inputs/workout_cardio_set_upsert_input.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../data/utils/exercise_details.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/sizes/screen_size.dart';
import '../../../../core/widgets/editors/save_buttons.dart';
import '../../../../core/widgets/layout/dynamic_list_input.dart';
import '../../../../exercises/view_models/exercise_cubit.dart';
import '../../../view_models/states/workout_state.dart';
import '../../../view_models/workout_cubit.dart';
import './cardio_set_editor.dart';
import './cardio_set_editor_data.dart';

class CardioEditor extends StatefulWidget {
  final int workoutId;
  final List<WorkoutCardioSetDto> initialSets;

  const CardioEditor({
    super.key,
    required this.workoutId,
    required this.initialSets,
  });

  @override
  State<CardioEditor> createState() => _CardioEditorState();
}

class _CardioEditorState extends State<CardioEditor> {
  late List<CardioSetEditorData> _displayedSets;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _displayedSets = _mapSets(widget.initialSets);
    context.read<ExerciseCubit>().getSelectionExercises(
      type: ExerciseType.cardio,
    );
  }

  List<CardioSetEditorData> _mapSets(List<WorkoutCardioSetDto> sets) {
    return sets.map((set) {
      return CardioSetEditorData(
        id: set.id,
        position: set.position,
        setType: set.setType,
        restSecs: set.restSecs,
        rounds: set.rounds,
        exercises: (set.exercises ?? []).map((exercise) {
          final details = exercise.exercise
              ?.getDetails<CardioExerciseDetails>();
          return CardioSetExerciseEditorData(
            id: exercise.id,
            position: exercise.position,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exercise?.name,
            exerciseDefaultMode: details?.defaultMode,
            exerciseUnitType: details?.unitType,
            exerciseUnit: details?.unit,
            mode: exercise.mode,
            quantity: exercise.quantity,
            restSecs: exercise.restSecs,
          );
        }).toList(),
      );
    }).toList();
  }

  List<CardioSetEditorData> _normalizeSetPositions(
    List<CardioSetEditorData> sets,
  ) {
    for (int i = 0; i < sets.length; i++) {
      sets[i].position = i + 1;
      for (int j = 0; j < sets[i].exercises.length; j++) {
        sets[i].exercises[j].position = j + 1;
      }
    }
    return sets;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _onComplete() async {
    if (_isCompleting) {
      return;
    }

    if (_displayedSets.isEmpty) {
      _showValidationError('Add at least one set before completing.');
      return;
    }

    if (_displayedSets.any((set) => set.exercises.isEmpty)) {
      _showValidationError('All sets must include at least one exercise.');
      return;
    }

    if (_displayedSets.any(
      (set) => set.exercises.any((exercise) => exercise.exerciseId == null),
    )) {
      _showValidationError('Select a cardio exercise for all set exercises.');
      return;
    }

    if (_displayedSets.any(
      (set) => set.exercises.any((exercise) => exercise.quantity <= 0),
    )) {
      _showValidationError('All exercises must have a quantity above 0.');
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    final normalizedSets = _normalizeSetPositions(
      List<CardioSetEditorData>.from(_displayedSets),
    );

    final workoutCubit = context.read<WorkoutCubit>();
    await workoutCubit.batchUpsertCardioWorkoutSets(
      workoutId: widget.workoutId,
      sets: normalizedSets.map((set) {
        final isConstant = set.setType == CardioSetType.constant;
        return WorkoutCardioSetUpsertInput(
          id: set.id,
          setType: set.setType,
          position: set.position,
          restSecs: set.restSecs,
          rounds: isConstant ? 1 : set.rounds,
          exercises: set.exercises.map((exercise) {
            return WorkoutCardioSetExerciseUpsertInput(
              id: exercise.id,
              position: exercise.position,
              exerciseId: exercise.exerciseId!,
              restSecs: isConstant ? 0 : exercise.restSecs,
              mode: exercise.mode,
              quantity: exercise.quantity,
            );
          }).toList(),
        );
      }).toList(),
    );

    if (mounted) {
      final hasError = workoutCubit.state.error != null;
      if (!hasError && context.canPop()) {
        context.pop();
        setState(() {
          _isCompleting = false;
        });
        return;
      }

      final updatedWorkout = workoutCubit.state.selectedWorkout;
      setState(() {
        if (!hasError &&
            updatedWorkout != null &&
            updatedWorkout.id == widget.workoutId) {
          _displayedSets = _mapSets(updatedWorkout.cardioSets ?? []);
        }
        _isCompleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkout != current.selectedWorkout ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.isLoading || state.error != null) {
          return;
        }

        final selectedWorkout = state.selectedWorkout;
        if (selectedWorkout != null &&
            selectedWorkout.id == widget.workoutId &&
            !_isCompleting) {
          setState(() {
            _displayedSets = _mapSets(selectedWorkout.cardioSets ?? []);
          });
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DynamicListInput<CardioSetEditorData>(
              theme: theme,
              filled: true,
              items: _displayedSets,
              fontSize: sizes.fontSize,
              padding: sizes.padding,
              spacing: sizes.spacing,
              handlesPadding: sizes.padding / 2,
              isLoading: state.isLoading || _isCompleting,
              addLabel: 'Add Set',
              keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
              onAdd: () {
                final lastSet = _displayedSets.lastOrNull;
                setState(() {
                  _displayedSets.add(
                    CardioSetEditorData(
                      id: null,
                      position: _displayedSets.length + 1,
                      setType: lastSet?.setType ?? CardioSetType.constant,
                      restSecs: lastSet?.restSecs ?? 60,
                      rounds: lastSet?.setType == CardioSetType.interval
                          ? lastSet!.rounds
                          : 1,
                      exercises: [],
                    ),
                  );
                });
              },
              onChanged: (items) {
                setState(() {
                  _displayedSets = _normalizeSetPositions(
                    List<CardioSetEditorData>.from(items),
                  );
                });
              },
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, index, setData) {
                return CardioSetEditor(
                  setData: setData,
                  sizes: sizes,
                  isLoading: state.isLoading || _isCompleting,
                  onChanged: (updatedSet) {
                    setState(() {
                      _displayedSets[index] = updatedSet;
                    });
                  },
                );
              },
            ),
            SizedBox(height: sizes.spacing / 2),
            SaveButtons(
              theme: theme,
              sizes: sizes,
              isLoading: _isCompleting || state.isLoading,
              onCancel: _isCompleting
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
              onSave: _isCompleting ? null : _onComplete,
            ),
          ],
        );
      },
    );
  }
}
