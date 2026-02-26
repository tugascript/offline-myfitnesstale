import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/utilities.dart';
import '../../../../models/workout_set_exercise_model.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_dropdown.dart';
import '../../../layout/dynamic_list_input.dart';
import '../../../layout/expanding_section.dart';
import '../editors/rest_input.dart';
import '../editors/set_exercise_search_modal.dart';
import '../editors/sets_input.dart';
import 'complex_set_editor_data.dart';
import 'set_exercise_editor.dart';

// TODO: save the muscle group of the main exercise so it can automatically search on the alternatives
class PremiumSetEditor extends StatefulWidget {
  final ComplexSetEditorData setData;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<ComplexSetEditorData> onChanged;

  const PremiumSetEditor({
    super.key,
    required this.setData,
    required this.sizes,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<PremiumSetEditor> createState() => _PremiumSetEditorState();
}

class _PremiumSetEditorState extends State<PremiumSetEditor> {
  late ComplexSetEditorData _workingSetData;

  ComplexSetEditorData _cloneSetData(ComplexSetEditorData source) {
    return ComplexSetEditorData(
      internalId: source.internalId,
      id: source.id,
      position: source.position,
      minSets: source.minSets,
      maxSets: source.maxSets,
      recommendedRestSecs: source.recommendedRestSecs,
      maxRestSecs: source.maxRestSecs,
      setType: source.setType,
      exercises: source.exercises
          .map(
            (exercise) => ComplexSetExerciseEditorData(
              internalId: exercise.internalId,
              id: exercise.id,
              position: exercise.position,
              minReps: exercise.minReps,
              maxReps: exercise.maxReps,
              toMaxReps: exercise.toMaxReps,
              difficulty: exercise.difficulty,
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
              alternativeExercises: Set<AlternativeExerciseData>.from(
                exercise.alternativeExercises,
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _workingSetData = _cloneSetData(widget.setData);
  }

  @override
  void didUpdateWidget(covariant PremiumSetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _workingSetData = _cloneSetData(widget.setData);
  }

  void _emitSetChange(void Function(ComplexSetEditorData setData) update) {
    final nextSet = _cloneSetData(_workingSetData);
    update(nextSet);
    _workingSetData = _cloneSetData(nextSet);
    widget.onChanged(nextSet);
  }

  List<ComplexSetExerciseEditorData> _normalizeExercisePositions(
    List<ComplexSetExerciseEditorData> exercises,
  ) {
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].position = i + 1;
    }
    return exercises;
  }

  WorkoutSetExerciseDifficulty? _buildDifficulty({
    required WorkoutSetExerciseDifficultyType? type,
    required int? value,
  }) {
    if (type == null || value == null) {
      return null;
    }

    return WorkoutSetExerciseDifficulty.create(
      value: value,
      type: type,
    );
  }

  void _updateExerciseAtIndex(
    int index,
    void Function(ComplexSetExerciseEditorData exercise) update,
  ) {
    _emitSetChange((setData) {
      final exercise = setData.exercises[index];
      update(exercise);
      setData.exercises = _normalizeExercisePositions(setData.exercises);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = widget.sizes;
    final setData = widget.setData;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<WorkoutSetType>(
              value: setData.setType,
              emptyLabel: "Set Type",
              labelText: "Set Type",
              showEmptyValue: false,
              items: WorkoutSetType.values,
              labelBuilder: EnumDisplayNames.getSetTypeDisplayName,
              onChanged: (setType) {
                if (widget.isLoading) {
                  return;
                }
                if (setType == null) {
                  return;
                }
                _emitSetChange((setData) {
                  setData.setType = setType;
                });
              },
              onSaved: (setType) {
                if (widget.isLoading) {
                  return;
                }
                if (setType == null) {
                  return;
                }
                _emitSetChange((setData) {
                  setData.setType = setType;
                });
              },
              fontSize: sizes.fontSize,
              padding: sizes.padding * 0.4,
              filled: true,
            ),
            SizedBox(height: sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: SetsInput(
                    initialMinSets: setData.minSets,
                    initialMaxSets: setData.maxSets,
                    minSetsOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return;
                      }
                      _emitSetChange((setData) {
                        setData.minSets = parsed;
                      });
                    },
                    maxSetsOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      _emitSetChange((setData) {
                        setData.maxSets = value.isEmpty ? null : parsed;
                      });
                    },
                    sizes: sizes,
                    theme: theme,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: RestInput(
                    initialRest: setData.recommendedRestSecs,
                    initialMaxRest: setData.maxRestSecs,
                    sizes: sizes,
                    theme: theme,
                    restOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return;
                      }
                      _emitSetChange((setData) {
                        setData.recommendedRestSecs = parsed;
                      });
                    },
                    maxRestOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      _emitSetChange((setData) {
                        setData.maxRestSecs = value.isEmpty ? null : parsed;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            ExpandingSection(
              icon: Icons.fitness_center,
              dense: true,
              title:
                  "${setData.exercises.length} exercise${setData.exercises.length == 1 ? '' : 's'}",
              titleFountSize: sizes.fontSize,
              initiallyExpanded: setData.exercises.isEmpty,
              titleFontWeight: FontWeight.w500,
              padding: sizes.spacing / 2,
              children: [
                DynamicListInput<ComplexSetExerciseEditorData>(
                  handlesPadding: sizes.padding / 3,
                  addButtonHeight: sizes.fontSize * 3,
                  theme: theme,
                  filled: true,
                  items: setData.exercises,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  spacing: sizes.spacing,
                  isLoading: widget.isLoading,
                  addEnabled: _addExerciseButtonEnabled(setData),
                  addLabel: "Add Exercise",
                  keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
                  onAdd: () {
                    _addExerciseLogic(context, setData, sizes);
                  },
                  onChanged: (items) {
                    _emitSetChange((setData) {
                      setData.exercises = _normalizeExercisePositions(
                        List<ComplexSetExerciseEditorData>.from(items),
                      );
                    });
                  },
                  onReorder: (oldIndex, newIndex) {},
                  itemBuilder: (context, index, exerciseData) {
                    return SetExerciseEditor(
                      exerciseData: exerciseData,
                      sizes: sizes,
                      isLoading: widget.isLoading,
                      onExerciseChanged: (value) {
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.exerciseId = value.$1;
                          exercise.exerciseName = value.$2;
                        });
                      },
                      onMinRepsChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) {
                          return;
                        }
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.minReps = parsed;
                        });
                      },
                      onMaxRepsChanged: (value) {
                        final parsed = int.tryParse(value);
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.maxReps = value.isEmpty ? null : parsed;
                        });
                      },
                      onToMaxRepsChanged: (value) {
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.toMaxReps = value ?? false;
                        });
                      },
                      onDifficultyTypeChanged: (type) {
                        _updateExerciseAtIndex(index, (exercise) {
                          int? value = exercise.difficulty?.value;
                          if (type != null &&
                              (value == null ||
                                  value < type.minValue ||
                                  value > type.maxValue)) {
                            value = type.defaultValue;
                          }

                          exercise.difficulty = _buildDifficulty(
                            type: type,
                            value: value,
                          );
                        });
                      },
                      onDifficultyValueChanged: (value) {
                        final parsed = int.tryParse(value);
                        _updateExerciseAtIndex(index, (exercise) {
                          final type = exercise.difficulty?.type;
                          exercise.difficulty = _buildDifficulty(
                            type: type,
                            value: value.isEmpty ? null : parsed,
                          );
                        });
                      },
                      onAlternativeExercisesChanged: (value) {
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.alternativeExercises = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _addExerciseButtonEnabled(ComplexSetEditorData setData) {
    switch (setData.setType) {
      case WorkoutSetType.standard:
        return setData.exercises.isEmpty;
      case WorkoutSetType.drop:
        return setData.exercises.length < 5;
      case WorkoutSetType.superSet:
        return setData.exercises.length < 3;
      case WorkoutSetType.giant:
      case WorkoutSetType.pyramid:
        return setData.exercises.length < 6;
      case WorkoutSetType.circuit:
        return setData.exercises.length < 10;
    }
  }

  void _addExerciseLogic(
    BuildContext context,
    ComplexSetEditorData setData,
    DataDisplaySizesList sizes,
  ) {
    final setType = setData.setType;
    final lastExercise = setData.exercises.lastOrNull;
    if (lastExercise == null) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return SetExerciseSearchModal(
            sizes: sizes,
            isLoading: widget.isLoading,
            onExerciseSelected: (id, name) async {
              if (!dialogContext.mounted) {
                return;
              }

              _emitSetChange((setData) {
                setData.exercises.add(
                  ComplexSetExerciseEditorData(
                    id: null,
                    position: setData.exercises.length + 1,
                    minReps: 1,
                    maxReps: null,
                    toMaxReps: false,
                    exerciseId: id,
                    exerciseName: name,
                    alternativeExercises: const {},
                  ),
                );
              });

              Navigator.of(dialogContext).pop();
            },
          );
        },
      );
      return;
    }

    switch (setType) {
      case WorkoutSetType.standard:
        return;
      case WorkoutSetType.drop:
        if (setData.exercises.length >= 5) {
          return;
        }

        _emitSetChange((setData) {
          setData.exercises.add(
            ComplexSetExerciseEditorData(
              id: null,
              position: setData.exercises.length + 1,
              minReps: lastExercise.minReps + 2,
              maxReps: lastExercise.maxReps != null
                  ? lastExercise.maxReps! + 2
                  : null,
              toMaxReps:
                  setData.exercises.length >= 2 || lastExercise.toMaxReps,
              exerciseId: lastExercise.exerciseId,
              exerciseName: lastExercise.exerciseName,
              alternativeExercises: lastExercise.alternativeExercises,
              difficulty: _calculateDifficulty(
                setType,
                lastExercise.difficulty,
              ),
            ),
          );
        });
        return;
      case WorkoutSetType.superSet:
        if (setData.exercises.length >= 3) {
          return;
        }

        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return SetExerciseSearchModal(
              sizes: sizes,
              isLoading: widget.isLoading,
              onExerciseSelected: (id, name) async {
                if (!dialogContext.mounted) {
                  return;
                }

                _emitSetChange((setData) {
                  setData.exercises.add(
                    ComplexSetExerciseEditorData(
                      id: null,
                      position: setData.exercises.length + 1,
                      minReps: lastExercise.minReps,
                      maxReps: lastExercise.maxReps,
                      toMaxReps: lastExercise.toMaxReps,
                      exerciseId: id,
                      exerciseName: name,
                      alternativeExercises: const {},
                      difficulty: _calculateDifficulty(
                        setType,
                        lastExercise.difficulty,
                      ),
                    ),
                  );
                });

                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
        return;
      case WorkoutSetType.giant:
        if (setData.exercises.length >= 6) {
          return;
        }

        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return SetExerciseSearchModal(
              sizes: sizes,
              isLoading: widget.isLoading,
              onExerciseSelected: (id, name) async {
                if (!dialogContext.mounted) {
                  return;
                }

                _emitSetChange((setData) {
                  setData.exercises.add(
                    ComplexSetExerciseEditorData(
                      id: null,
                      position: setData.exercises.length + 1,
                      minReps: lastExercise.minReps,
                      maxReps: lastExercise.maxReps,
                      toMaxReps: lastExercise.toMaxReps,
                      exerciseId: id,
                      exerciseName: name,
                      alternativeExercises: const {},
                      difficulty: _calculateDifficulty(
                        setType,
                        lastExercise.difficulty,
                      ),
                    ),
                  );
                });

                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
        return;
      case WorkoutSetType.pyramid:
        if (setData.exercises.length >= 6) {
          return;
        }

        _emitSetChange((setData) {
          final minReps = lastExercise.minReps - 2;
          final maxReps =
              lastExercise.maxReps != null ? lastExercise.maxReps! - 2 : null;
          setData.exercises.add(
            ComplexSetExerciseEditorData(
              id: null,
              position: setData.exercises.length + 1,
              minReps: minReps > 0 ? minReps : 1,
              maxReps: maxReps != null && maxReps > 0 ? maxReps : null,
              toMaxReps: lastExercise.toMaxReps,
              exerciseId: lastExercise.exerciseId,
              exerciseName: lastExercise.exerciseName,
              alternativeExercises: lastExercise.alternativeExercises,
              difficulty: _calculateDifficulty(
                setType,
                lastExercise.difficulty,
              ),
            ),
          );
        });
        return;
      case WorkoutSetType.circuit:
        if (setData.exercises.length >= 10) {
          return;
        }

        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return SetExerciseSearchModal(
              sizes: sizes,
              isLoading: widget.isLoading,
              onExerciseSelected: (id, name) async {
                if (!dialogContext.mounted) {
                  return;
                }

                _emitSetChange((setData) {
                  setData.exercises.add(
                    ComplexSetExerciseEditorData(
                      id: null,
                      position: setData.exercises.length + 1,
                      minReps: lastExercise.minReps,
                      maxReps: lastExercise.maxReps,
                      toMaxReps: lastExercise.toMaxReps,
                      exerciseId: id,
                      exerciseName: name,
                      alternativeExercises: const {},
                      difficulty: _calculateDifficulty(
                        setType,
                        lastExercise.difficulty,
                      ),
                    ),
                  );
                });

                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
        return;
    }
  }

  WorkoutSetExerciseDifficulty? _calculateDifficulty(
    WorkoutSetType setType,
    WorkoutSetExerciseDifficulty? prevDifficulty,
  ) {
    if (prevDifficulty == null) {
      return null;
    }

    switch (setType) {
      case WorkoutSetType.standard:
        return null;
      case WorkoutSetType.drop:
        return WorkoutSetExerciseDifficulty(
          type: prevDifficulty.type,
          value: _calculateDropSetDifficultyValue(
            prevDifficulty.type,
            prevDifficulty.value,
          ),
        );
      case WorkoutSetType.pyramid:
        return WorkoutSetExerciseDifficulty(
          type: prevDifficulty.type,
          value: _calculatePyramidDifficultyValue(
            prevDifficulty.type,
            prevDifficulty.value,
          ),
        );
      case WorkoutSetType.superSet:
      case WorkoutSetType.giant:
      case WorkoutSetType.circuit:
        return prevDifficulty;
    }
  }

  int _calculateDropSetDifficultyValue(
    WorkoutSetExerciseDifficultyType prevType,
    int prevVal,
  ) {
    switch (prevType) {
      case WorkoutSetExerciseDifficultyType.rir:
        {
          final val = prevVal - 1;
          return val > WorkoutSetExerciseDifficultyType.rir.minValue
              ? val
              : WorkoutSetExerciseDifficultyType.rir.minValue;
        }
      case WorkoutSetExerciseDifficultyType.rpe:
        {
          final val = prevVal + 1;
          return val > WorkoutSetExerciseDifficultyType.rpe.maxValue
              ? WorkoutSetExerciseDifficultyType.rpe.maxValue
              : val;
        }
      case WorkoutSetExerciseDifficultyType.rmp:
        {
          final val = prevVal - 10;
          return val > WorkoutSetExerciseDifficultyType.rmp.minValue
              ? val
              : WorkoutSetExerciseDifficultyType.rmp.minValue;
        }
    }
  }

  int _calculatePyramidDifficultyValue(
    WorkoutSetExerciseDifficultyType prevType,
    int prevVal,
  ) {
    switch (prevType) {
      case WorkoutSetExerciseDifficultyType.rir:
        {
          final val = prevVal - 1;
          return val > WorkoutSetExerciseDifficultyType.rir.minValue
              ? val
              : WorkoutSetExerciseDifficultyType.rir.minValue;
        }
      case WorkoutSetExerciseDifficultyType.rpe:
        {
          final val = prevVal + 1;
          return val > WorkoutSetExerciseDifficultyType.rpe.maxValue
              ? WorkoutSetExerciseDifficultyType.rpe.maxValue
              : val;
        }
      case WorkoutSetExerciseDifficultyType.rmp:
        {
          final val = prevVal + 10;
          return val < WorkoutSetExerciseDifficultyType.rmp.maxValue
              ? val
              : WorkoutSetExerciseDifficultyType.rmp.maxValue;
        }
    }
  }
}
