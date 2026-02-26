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
import '../../../common/mutation_button.dart';
import '../../../layout/app_primary_button.dart';
import '../../../layout/dynamic_list_input.dart';
import 'complex_set_editor_data.dart';
import 'premium_set_editor.dart';

class PremiumEditor extends StatefulWidget {
  final int workoutId;
  final List<WorkoutSetDto> initialSets;

  const PremiumEditor({
    super.key,
    required this.workoutId,
    required this.initialSets,
  });

  @override
  State<PremiumEditor> createState() => _PremiumEditorState();
}

class _PremiumEditorState extends State<PremiumEditor> {
  late List<ComplexSetEditorData> _displayedSets;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _displayedSets = _mapSets(widget.initialSets);
    context.read<ExerciseCubit>().getSelectionExercises();
  }

  List<ComplexSetEditorData> _mapSets(List<WorkoutSetDto> sets) {
    return sets.map((set) {
      return ComplexSetEditorData(
        id: set.id,
        position: set.position,
        setType: set.setType,
        minSets: set.minSets,
        maxSets: set.maxSets,
        recommendedRestSecs: set.recommendedRestSecs,
        maxRestSecs: set.maxRestSecs,
        exercises: (set.exercises ?? []).map((exercise) {
          return ComplexSetExerciseEditorData(
            id: exercise.id,
            position: exercise.position,
            minReps: exercise.minReps,
            maxReps: exercise.maxReps,
            toMaxReps: exercise.toMaxReps,
            difficulty: exercise.difficulty,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exercise?.name,
            alternativeExercises: (exercise.options ?? [])
                .map(
                  (option) => AlternativeExerciseData(
                    id: option.exerciseId,
                    name: option.exercise?.name ?? "Unknown",
                  ),
                )
                .toSet(),
          );
        }).toList(),
      );
    }).toList();
  }

  List<ComplexSetEditorData> _normalizeSetPositions(
    List<ComplexSetEditorData> sets,
  ) {
    for (int i = 0; i < sets.length; i++) {
      sets[i].position = i + 1;
      for (int j = 0; j < sets[i].exercises.length; j++) {
        sets[i].exercises[j].position = j + 1;
      }
    }
    return sets;
  }

  Future<void> _onComplete() async {
    if (_isCompleting) {
      return;
    }

    if (_displayedSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add at least one set before completing."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_displayedSets.any((set) => set.exercises.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All sets must include at least one exercise."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_displayedSets.any(
      (set) => set.exercises.any((exercise) => exercise.exerciseId == null),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select a primary exercise for all set exercises."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    final normalizedSets = _normalizeSetPositions(
      List<ComplexSetEditorData>.from(_displayedSets),
    );

    final workoutCubit = context.read<WorkoutCubit>();
    await workoutCubit.batchUpsertComplexWorkoutSets(
      workoutId: widget.workoutId,
      sets: normalizedSets.map((set) {
        return ComplexSetInput(
          id: set.id,
          setType: set.setType,
          position: set.position,
          minSets: set.minSets,
          maxSets: set.maxSets,
          recommendedRestSecs: set.recommendedRestSecs,
          maxRestSecs: set.maxRestSecs,
          exercises: set.exercises.map((exercise) {
            return ComplexSetExerciseInput(
              id: exercise.id,
              position: exercise.position,
              exerciseId: exercise.exerciseId!,
              minReps: exercise.minReps,
              maxReps: exercise.maxReps,
              toMaxReps: exercise.toMaxReps,
              difficulty: exercise.difficulty,
              alternativeExerciseIds:
                  exercise.alternativeExercises.map((e) => e.id).toSet(),
            );
          }).toList(),
        );
      }).toList(),
    );

    if (mounted) {
      if (workoutCubit.state.error == null && context.canPop()) {
        context.pop();
      }

      setState(() {
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
        if (selectedWorkout != null &&
            selectedWorkout.id == widget.workoutId &&
            !_isCompleting) {
          setState(() {
            _displayedSets = _mapSets(selectedWorkout.sets ?? []);
          });
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DynamicListInput<ComplexSetEditorData>(
              handlesPadding: sizes.padding / 2,
              theme: theme,
              filled: true,
              items: _displayedSets,
              fontSize: sizes.fontSize,
              padding: sizes.padding,
              spacing: sizes.spacing,
              isLoading: state.isLoading || _isCompleting,
              addLabel: "Add Set",
              keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
              onAdd: () {
                final lastSet = _displayedSets.lastOrNull;
                setState(() {
                  _displayedSets.add(
                    ComplexSetEditorData(
                      id: null,
                      setType: lastSet?.setType ?? WorkoutSetType.standard,
                      position: _displayedSets.length + 1,
                      minSets: lastSet?.minSets ?? 1,
                      maxSets: lastSet?.maxSets,
                      recommendedRestSecs: lastSet?.recommendedRestSecs ?? 60,
                      maxRestSecs: lastSet?.maxRestSecs,
                      exercises: [],
                    ),
                  );
                });
              },
              onChanged: (items) {
                setState(() {
                  _displayedSets = _normalizeSetPositions(
                    List<ComplexSetEditorData>.from(items),
                  );
                });
              },
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, index, setData) {
                return PremiumSetEditor(
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
            Row(
              children: [
                Expanded(
                  child: MutationButton(
                    onPressed: _isCompleting
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                    theme: theme,
                    isLoading: _isCompleting || state.isLoading,
                    sizes: sizes,
                    label: 'CANCEL',
                    icon: Icons.cancel,
                    color: theme.colorScheme.error,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: AppPrimaryButton(
                    onPressed: _isCompleting ? null : _onComplete,
                    theme: theme,
                    isLoading: _isCompleting || state.isLoading,
                    sizes: sizes,
                    label: 'SAVE',
                    icon: Icons.save,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
