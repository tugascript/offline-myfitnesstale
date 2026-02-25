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
              status: exercise.status,
            ),
          )
          .toList(),
      status: source.status,
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
      setData.status = ComplexSetEditorDataStatus.pending;
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
                  setData.status = ComplexSetEditorDataStatus.pending;
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
                  setData.status = ComplexSetEditorDataStatus.pending;
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
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
                    maxSetsOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      _emitSetChange((setData) {
                        setData.maxSets = value.isEmpty ? null : parsed;
                        setData.status = ComplexSetEditorDataStatus.pending;
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
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
                    maxRestOnChanged: (value) {
                      final parsed = int.tryParse(value);
                      _emitSetChange((setData) {
                        setData.maxRestSecs = value.isEmpty ? null : parsed;
                        setData.status = ComplexSetEditorDataStatus.pending;
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
                  addLabel: "Add Exercise",
                  keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
                  onAdd: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return SetExerciseSearchModal(
                          sizes: sizes,
                          isLoading: widget.isLoading,
                          onExerciseSelected: (id, name) async {
                            if (!dialogContext.mounted) return;

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
                                  status: ComplexSetEditorDataStatus.initial,
                                ),
                              );
                              setData.status =
                                  ComplexSetEditorDataStatus.pending;
                            });

                            Navigator.of(dialogContext).pop();
                          },
                        );
                      },
                    );
                  },
                  onChanged: (items) {
                    _emitSetChange((setData) {
                      setData.exercises = _normalizeExercisePositions(
                        List<ComplexSetExerciseEditorData>.from(items),
                      );
                      setData.status = ComplexSetEditorDataStatus.pending;
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
                          exercise.status = ComplexSetEditorDataStatus.pending;
                        });
                      },
                      onMinRepsChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) {
                          return;
                        }
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.minReps = parsed;
                          exercise.status = ComplexSetEditorDataStatus.pending;
                        });
                      },
                      onMaxRepsChanged: (value) {
                        final parsed = int.tryParse(value);
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.maxReps = value.isEmpty ? null : parsed;
                          exercise.status = ComplexSetEditorDataStatus.pending;
                        });
                      },
                      onToMaxRepsChanged: (value) {
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.toMaxReps = value ?? false;
                          exercise.status = ComplexSetEditorDataStatus.pending;
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
                          exercise.status = ComplexSetEditorDataStatus.pending;
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
                          exercise.status = ComplexSetEditorDataStatus.pending;
                        });
                      },
                      onAlternativeExercisesChanged: (value) {
                        _updateExerciseAtIndex(index, (exercise) {
                          exercise.alternativeExercises = value;
                          exercise.status = ComplexSetEditorDataStatus.pending;
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
}
