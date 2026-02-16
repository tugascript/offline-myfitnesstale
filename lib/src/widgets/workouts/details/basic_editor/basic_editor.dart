import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_dto.dart';

import '../../../../cubits/exercise_cubit.dart';
import '../../../../cubits/states/workout_state.dart';
import '../../../../cubits/workout_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../../utilities/sizes/screen_size.dart';
import '../../../../services/workout_service.dart';
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
      );
    }).toList();
    context.read<ExerciseCubit>().getSelectionExercises();
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
      );
    }).toList();
  }

  // Update Set
  // workoutCubit.updateWorkoutSet(
  //   workoutSetId: set.id!,
  //   workoutId: widget.workoutId,
  //   minSets: minSets,
  //   maxSets: maxSets,
  //   recommendedRestSecs: recommendedRestSecs,
  //   maxRestSecs: maxRestSecs,
  // );

  // // Update Exercise
  // if (controller.exerciseId != null && minReps != null) {
  //   workoutCubit.updateWorkoutSetExercise(
  //     workoutSetExerciseId: controller.exerciseId!,
  //     workoutId: widget.workoutId,
  //     minReps: minReps,
  //     maxReps: maxReps,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.selectedWorkout != current.selectedWorkout &&
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
          isLoading: state.isLoading,
          addLabel: "Add Set",
          onAdd: () {
            setState(() {
              _displayedSets.add(SetEditorData(
                id: null,
                position: _displayedSets.length + 1,
                minSets: 0,
                maxSets: 0,
                minReps: 0,
                maxReps: 0,
                recommendedRestSecs: 0,
                maxRestSecs: 0,
                toMaxReps: false,
                exerciseName: null,
                exerciseId: null,
                status: SetEditorDataStatus.initial,
              ));
            });
            showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return SetExerciseSearchModal(
                  sizes: sizes,
                  isLoading: state.isLoading,
                  onExerciseSelected: (id, name) async {
                    setState(() {
                      _displayedSets.last.exerciseId = id;
                      _displayedSets.last.exerciseName = name;
                      _displayedSets.last.status = SetEditorDataStatus.pending;
                    });
                    final workoutCubit = context.read<WorkoutCubit>();
                    await workoutCubit.createWorkoutSet(
                      workoutId: widget.workoutId,
                      setType: WorkoutSetType.standard,
                      minSets: 0,
                      recommendedRestSecs: 0,
                      exercises: [
                        WorkoutSetExerciseInput(
                          exerciseId: id,
                          minReps: 0,
                        ),
                      ],
                    );
                    if (!dialogContext.mounted) return;
                    // Only close on success; listener will set _displayedSets from state
                    final success = workoutCubit.state.error == null;
                    if (success) {
                      final newId = workoutCubit
                          .state.selectedWorkout?.sets?.lastOrNull?.id;
                      if (newId != null) {
                        setState(() {
                          _displayedSets.last.status =
                              SetEditorDataStatus.created;
                          _displayedSets.last.id = newId;
                        });
                      }
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                workoutCubit.state.error?.description ??
                                    "Something went wrong")),
                      );
                    }
                  },
                );
              },
            );
          },
          keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
          itemBuilder: (context, index, item) {
            return BasicSetEditor(
              set: item,
              sizes: sizes,
              onExerciseChanged: (value) {
                setState(() {
                  item.exerciseId = value.$1;
                  item.exerciseName = value.$2;
                });
              },
              onMinSetsChanged: (value) {
                final intSets = int.tryParse(value);
                if (intSets == null) {
                  return;
                }

                setState(() {
                  item.minSets = intSets;
                });
              },
              onMaxSetsChanged: (value) {
                final intSets = int.tryParse(value);
                if (intSets == null) {
                  return;
                }

                setState(() {
                  item.maxSets = intSets;
                });
              },
              onMinRepsChanged: (value) {
                final intReps = int.tryParse(value);
                if (intReps == null) {
                  return;
                }

                setState(() {
                  item.minReps = intReps;
                });
              },
              onMaxRepsChanged: (value) {
                final intReps = int.tryParse(value);
                if (intReps == null) {
                  return;
                }

                setState(() {
                  item.maxReps = intReps;
                });
              },
              onRestChanged: (value) {
                final intRest = int.tryParse(value);
                if (intRest == null) {
                  return;
                }

                setState(() {
                  item.recommendedRestSecs = intRest;
                });
              },
              onMaxRestChanged: (value) {
                final intRest = int.tryParse(value);
                if (intRest == null) {
                  return;
                }

                setState(() {
                  item.maxRestSecs = intRest;
                });
              },
              onToMaxRepsChanged: (value) {
                setState(() {
                  item.toMaxReps = value ?? false;
                });
              },
              isLoading: state.isLoading,
            );
          },
          onReorder: (oldIndex, newIndex) async {
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
              for (var i = 0; i < removed.length; i++) {
                final item = removed[i];
                if (item.id != null) {
                  await workoutCubit.deleteWorkoutSet(
                    workoutSetId: item.id!,
                    workoutId: widget.workoutId,
                  );
                }
              }

              setState(() {
                _displayedSets = List.from(items);
              });
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
