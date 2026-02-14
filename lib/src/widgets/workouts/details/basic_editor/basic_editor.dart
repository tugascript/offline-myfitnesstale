import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';

import '../../../../cubits/states/workout_state.dart';
import '../../../../cubits/workout_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_set_dto.dart';
import '../../../../services/workout_service.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../../utilities/sizes/screen_size.dart';
import '../../../layout/dynamic_list_input.dart';
import '../editors/set_exercise_search_modal.dart';
import 'basic_set_editor.dart';

class BasicEditor extends StatefulWidget {
  final int workoutId;

  const BasicEditor({
    super.key,
    required this.workoutId,
  });

  @override
  State<BasicEditor> createState() => _BasicEditorState();
}

class _BasicEditorState extends State<BasicEditor> {
  final Map<int, _SetControllers> _controllers = {};
  final Set<int> _pendingUpdates = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getSelectionExercises();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<WorkoutSetDto> sets) {
    final Set<int> setIds = sets.map((s) => s.id).toSet();

    // Remove controllers for deleted sets
    _controllers.removeWhere((id, controller) {
      if (!setIds.contains(id)) {
        controller.dispose();
        _pendingUpdates.remove(id);
        return true;
      }
      return false;
    });
  }

  _SetControllers _getController(WorkoutSetDto set) {
    return _controllers.putIfAbsent(set.id, () {
      final controller = _SetControllers(set);
      _attachListeners(set.id, controller);
      return controller;
    });
  }

  void _attachListeners(int setId, _SetControllers controller) {
    void listener() {
      _onSetChanged(setId);
    }

    controller.minSets.addListener(listener);
    controller.maxSets.addListener(listener);
    controller.minReps.addListener(listener);
    controller.maxReps.addListener(listener);
    controller.restTime.addListener(listener);
    controller.maxRestTime.addListener(listener);
  }

  void _onSetChanged(int setId) {
    _pendingUpdates.add(setId);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), _flushUpdates);
  }

  Future<void> _flushUpdates() async {
    if (!mounted) return;
    if (_pendingUpdates.isEmpty) return;

    final List<int> idsToUpdate = _pendingUpdates.toList();
    _pendingUpdates.clear();

    for (final id in idsToUpdate) {
      final controller = _controllers[id];
      if (controller != null) {
        await _updateSet(id, controller);
      }
    }
  }

  Future<void> _updateSet(int setId, _SetControllers controller) async {
    if (!mounted) return;
    final workoutCubit = context.read<WorkoutCubit>();

    // Parse values
    final minSets = int.tryParse(controller.minSets.text);
    final maxSets = int.tryParse(controller.maxSets.text);
    final minReps = int.tryParse(controller.minReps.text);
    final maxReps = int.tryParse(controller.maxReps.text);
    final recommendedRestSecs = int.tryParse(controller.restTime.text);
    final maxRestSecs = int.tryParse(controller.maxRestTime.text);

    // Update Set
    if (minSets != null && recommendedRestSecs != null) {
      await workoutCubit.updateWorkoutSet(
        workoutSetId: setId,
        workoutId: widget.workoutId,
        minSets: minSets,
        maxSets: maxSets,
        recommendedRestSecs: recommendedRestSecs,
        maxRestSecs: maxRestSecs,
      );
    }

    // Update Exercise
    if (controller.exerciseId != null && minReps != null) {
      await workoutCubit.updateWorkoutSetExercise(
        workoutSetExerciseId: controller.exerciseId!,
        workoutId: widget.workoutId,
        minReps: minReps,
        maxReps: maxReps,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        final sets = state.selectedWorkout?.id == widget.workoutId
            ? state.selectedWorkout?.sets ?? []
            : (state.workouts
                    .firstWhere((w) => w.id == widget.workoutId,
                        orElse: () => state.selectedWorkout!)
                    .sets ??
                []);

        final sortedSets = List<WorkoutSetDto>.from(sets)
          ..sort((a, b) => a.position.compareTo(b.position));

        _syncControllers(sortedSets);

        return DynamicListInput<WorkoutSetDto>(
          theme: theme,
          filled: true,
          items: sortedSets,
          fontSize: sizes.fontSize,
          padding: sizes.padding,
          spacing: sizes.spacing,
          isLoading: state.isLoading,
          addLabel: "Add Set",
          onAdd: () {
            showDialog(
              context: context,
              builder: (context) {
                return SetExerciseSearchModal(
                  sizes: sizes,
                  onExerciseSelected: (id, name) {
                    Navigator.of(context).pop();
                    context.read<WorkoutCubit>().createWorkoutSet(
                      workoutId: widget.workoutId,
                      setType: WorkoutSetType.standard,
                      minSets: 1,
                      recommendedRestSecs: 60,
                      exercises: [
                        WorkoutSetExerciseInput(
                          exerciseId: id,
                          minReps: 0, // Default value, user can edit
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          keyBuilder: (item) => ValueKey(item.id),
          itemBuilder: (context, index, item) {
            final controller = _getController(item);

            return BasicSetEditor(
              set: item,
              sizes: sizes,
              minSetsController: controller.minSets,
              maxSetsController: controller.maxSets,
              minRepsController: controller.minReps,
              maxRepsController: controller.maxReps,
              restController: controller.restTime,
              maxRestController: controller.maxRestTime,
              isMaxReps: controller.isMaxReps,
              onIsMaxRepsChanged: (value) {
                if (value != controller.isMaxReps) {
                  setState(() {
                    controller.isMaxReps = value;
                  });
                  _onSetChanged(item.id);
                }
              },
              exercise: controller.exercise,
              onExerciseChanged: (value) {
                setState(() {
                  controller.exercise = value;
                });
              },
              isLoading: state.isLoading,
            );
          },
          onReorder: (oldIndex, newIndex) {
            var targetIndex = newIndex;
            if (oldIndex < newIndex) {
              targetIndex -= 1;
            }
            final newPosition = targetIndex + 1;
            final item = sortedSets[oldIndex];

            if (item.position != newPosition) {
              context.read<WorkoutCubit>().updateWorkoutSetPosition(
                    workoutSetId: item.id,
                    position: newPosition,
                  );
            }
          },
          onChanged: (items) {
            // Handled by onReorder and internal updates
          },
        );
      },
    );
  }
}

class _SetControllers {
  final TextEditingController minSets;
  final TextEditingController maxSets;
  final TextEditingController minReps;
  final TextEditingController maxReps;
  final TextEditingController restTime;
  final TextEditingController maxRestTime;

  bool isMaxReps;
  (int, String)? exercise;
  int? exerciseId;

  _SetControllers(WorkoutSetDto set)
      : minSets = TextEditingController(text: set.minSets.toString()),
        maxSets = TextEditingController(text: set.maxSets?.toString() ?? ""),
        minReps = TextEditingController(
            text: set.exercises?.firstOrNull?.minReps.toString() ?? ""),
        maxReps = TextEditingController(
            text: set.exercises?.firstOrNull?.maxReps?.toString() ?? ""),
        restTime =
            TextEditingController(text: set.recommendedRestSecs.toString()),
        maxRestTime =
            TextEditingController(text: set.maxRestSecs?.toString() ?? ""),
        isMaxReps = false,
        exercise = set.exercises?.firstOrNull?.exercise != null
            ? (
                set.exercises!.firstOrNull!.exercise!.id,
                set.exercises!.firstOrNull!.exercise!.name
              )
            : null,
        exerciseId = set.exercises?.firstOrNull?.id;

  void dispose() {
    minSets.dispose();
    maxSets.dispose();
    minReps.dispose();
    maxReps.dispose();
    restTime.dispose();
    maxRestTime.dispose();
  }
}
