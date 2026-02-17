import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../cubits/exercise_cubit.dart';
import '../../../../cubits/states/workout_state.dart';
import '../../../../cubits/workout_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_set_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../../utilities/sizes/screen_size.dart';
import '../../../layout/dynamic_list_input.dart';
import '../editors/set_exercise_search_modal.dart';
import 'basic_set_editor.dart';
import 'set_editor_data.dart';

class BasicEditor extends StatefulWidget {
  final int workoutId;
  final List<WorkoutSetDto> initialSets;

  const BasicEditor({
    super.key,
    required this.workoutId,
    required this.initialSets,
  });

  @override
  State<BasicEditor> createState() => _BasicEditorState();
}

class _BasicEditorState extends State<BasicEditor> {
  late List<SetEditorData> _displayedSets;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _displayedSets = widget.initialSets.map((s) {
      final exercise = s.exercises?.firstOrNull;
      return SetEditorData(
        id: s.id,
        position: s.position,
        minSets: s.minSets,
        maxSets: s.maxSets ?? 0,
        minReps: exercise?.minReps ?? 0,
        maxReps: exercise?.maxReps ?? 0,
        recommendedRestSecs: s.recommendedRestSecs,
        maxRestSecs: s.maxRestSecs ?? 0,
        toMaxReps: exercise?.toMaxReps ?? false,
        exerciseId: exercise?.exerciseId,
        exerciseName: exercise?.exercise?.name,
        status: SetEditorDataStatus.created,
        setExerciseId: exercise?.id,
      );
    }).toList();
    context.read<ExerciseCubit>().getSelectionExercises();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 1), () {
      _saveDebounce = null;
      if (mounted) _saveSets();
    });
  }

  Future<void> _saveSets() async {
    final setsToSave = _displayedSets
        .where((s) => s.status == SetEditorDataStatus.pending)
        .toList();

    if (setsToSave.isEmpty) {
      return;
    }

    final workoutCubit = context.read<WorkoutCubit>();
    await workoutCubit.batchUpsertWorkoutSets(
      workoutId: widget.workoutId,
      sets: setsToSave.map((s) {
        return StandardSetInput(
          id: s.id,
          minSets: s.minSets,
          maxSets: s.maxSets,
          minReps: s.minReps,
          maxReps: s.maxReps,
          toMaxReps: s.toMaxReps,
          recommendedRestSecs: s.recommendedRestSecs,
          maxRestSecs: s.maxRestSecs,
          exerciseId: s.exerciseId!,
          setExerciseId: s.setExerciseId,
        );
      }).toList(),
    );
  }

  List<SetEditorData> _baseSetsFromState(WorkoutState state) {
    final rawSets = state.selectedWorkout?.id == widget.workoutId
        ? state.selectedWorkout?.sets ?? []
        : (state.workouts
                .firstWhere((w) => w.id == widget.workoutId,
                    orElse: () => state.selectedWorkout!)
                .sets ??
            []);
    return rawSets.map((s) {
      final exercise = s.exercises?.firstOrNull;
      return SetEditorData(
        id: s.id,
        position: s.position,
        minSets: s.minSets,
        maxSets: s.maxSets ?? 0,
        minReps: exercise?.minReps ?? 0,
        maxReps: exercise?.maxReps ?? 0,
        recommendedRestSecs: s.recommendedRestSecs,
        maxRestSecs: s.maxRestSecs ?? 0,
        toMaxReps: exercise?.toMaxReps ?? false,
        exerciseId: exercise?.exerciseId,
        exerciseName: exercise?.exercise?.name,
        status: SetEditorDataStatus.created,
        setExerciseId: exercise?.id,
      );
    }).toList();
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
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error?.description ?? "Something went wrong",
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final selectedWorkout = state.selectedWorkout;
        if (selectedWorkout != null && selectedWorkout.id == widget.workoutId) {
          final sets = selectedWorkout.sets;
          if (sets == null) {
            return;
          }

          if (sets.any((s) => s.setType != WorkoutSetType.standard)) {
            context.pop();
            return;
          }

          // Merge state into displayed list: base from state + pending (excluding creating)
          final baseSets = _baseSetsFromState(state);
          setState(() {
            _displayedSets = baseSets;
          });
        }
      },
      builder: (context, state) {
        return DynamicListInput<SetEditorData>(
          theme: theme,
          filled: true,
          items: _displayedSets,
          fontSize: sizes.fontSize,
          padding: sizes.padding,
          spacing: sizes.spacing,
          isLoading: false,
          addLabel: "Add Set",
          onAdd: () {
            setState(() {
              _displayedSets.add(
                SetEditorData(
                  id: null,
                  position: _displayedSets.length + 1,
                  minSets: 1,
                  maxSets: 0,
                  minReps: 1,
                  maxReps: 0,
                  recommendedRestSecs: 0,
                  maxRestSecs: 0,
                  toMaxReps: false,
                  exerciseName: null,
                  exerciseId: null,
                  status: SetEditorDataStatus.initial,
                  setExerciseId: null,
                ),
              );
            });
            showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return SetExerciseSearchModal(
                  sizes: sizes,
                  isLoading: state.isLoading,
                  onExerciseSelected: (id, name) async {
                    if (!dialogContext.mounted) return;
                    setState(() {
                      _displayedSets.last.exerciseId = id;
                      _displayedSets.last.exerciseName = name;
                      _displayedSets.last.status = SetEditorDataStatus.pending;
                    });
                    _scheduleSave();
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            );
          },
          keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
          itemBuilder: (context, index, item) {
            return BasicSetEditor(
              setData: item,
              sizes: sizes,
              onExerciseChanged: (value) {
                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }

                  item.exerciseId = value.$1;
                  item.exerciseName = value.$2;
                });
                _scheduleSave();
              },
              onMinSetsChanged: (value) {
                final intSets = int.tryParse(value);
                if (intSets == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.minSets = intSets;
                });
                _scheduleSave();
              },
              onMaxSetsChanged: (value) {
                final intSets = int.tryParse(value);
                if (intSets == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.maxSets = intSets;
                });
                _scheduleSave();
              },
              onMinRepsChanged: (value) {
                final intReps = int.tryParse(value);
                if (intReps == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.minReps = intReps;
                });
                _scheduleSave();
              },
              onMaxRepsChanged: (value) {
                final intReps = int.tryParse(value);
                if (intReps == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.maxReps = intReps;
                });
                _scheduleSave();
              },
              onRestChanged: (value) {
                final intRest = int.tryParse(value);
                if (intRest == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.recommendedRestSecs = intRest;
                });
                _scheduleSave();
              },
              onMaxRestChanged: (value) {
                final intRest = int.tryParse(value);
                if (intRest == null) {
                  return;
                }

                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.maxRestSecs = intRest;
                });
                _scheduleSave();
              },
              onToMaxRepsChanged: (value) {
                setState(() {
                  if (item.status != SetEditorDataStatus.pending) {
                    item.status = SetEditorDataStatus.pending;
                  }
                  item.toMaxReps = value ?? false;
                });
                _scheduleSave();
              },
            );
          },
          onReorder: (oldIndex, newIndex) async {
            if (oldIndex == newIndex || state.isLoading) {
              return;
            }

            final item = _displayedSets[oldIndex];

            setState(() {
              _displayedSets.removeAt(oldIndex);
              _displayedSets.insert(newIndex, item);
            });

            if (item.id != null) {
              final workoutCubit = context.read<WorkoutCubit>();
              await workoutCubit.updateWorkoutSetPosition(
                workoutSetId: item.id!,
                position: newIndex + 1,
              );
              await _saveSets();
            }
          },
          onChanged: (items) async {
            if (state.isLoading) {
              return;
            }

            final workoutCubit = context.read<WorkoutCubit>();
            if (items.length < _displayedSets.length) {
              final removed =
                  _displayedSets.where((e) => !items.contains(e)).toList();
              setState(() {
                _displayedSets = List.from(items);
              });

              for (var i = 0; i < removed.length; i++) {
                final item = removed[i];
                if (item.id != null) {
                  await workoutCubit.deleteWorkoutSet(
                    workoutSetId: item.id!,
                    workoutId: widget.workoutId,
                  );
                }
              }
              return;
            }

            if (items.length > _displayedSets.length) {
              setState(() {
                _displayedSets = List.from(items);
              });
              return;
            }
          },
        );
      },
    );
  }
}
