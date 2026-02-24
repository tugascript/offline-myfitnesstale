import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/workout_set_exercise_model.dart';
import '../../../../models/utilities.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/dynamic_list_input.dart';
import 'complex_set_editor_data.dart';
import 'set_exercise_editor.dart.dart';

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
  void _emitSetChange(void Function(ComplexSetEditorData setData) update) {
    final nextSet = ComplexSetEditorData(
      internalId: widget.setData.internalId,
      id: widget.setData.id,
      position: widget.setData.position,
      minSets: widget.setData.minSets,
      maxSets: widget.setData.maxSets,
      recommendedRestSecs: widget.setData.recommendedRestSecs,
      maxRestSecs: widget.setData.maxRestSecs,
      setType: widget.setData.setType,
      exercises: widget.setData.exercises
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
              alternativeExerciseIds:
                  List<int>.from(exercise.alternativeExerciseIds),
              status: exercise.status,
            ),
          )
          .toList(),
      status: widget.setData.status,
    );
    update(nextSet);
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
            Text(
              "Set #${setData.position}",
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (setData.id != null)
              Text(
                "ID: ${setData.id}",
                style: TextStyle(
                  fontSize: sizes.smallFontSize,
                  color: Colors.grey,
                ),
              ),
            SizedBox(height: sizes.spacing / 2),
            DropdownButtonFormField<WorkoutSetType>(
              initialValue: setData.setType,
              decoration: const InputDecoration(
                labelText: "Set Type",
                border: OutlineInputBorder(),
              ),
              items: WorkoutSetType.values.map((setType) {
                return DropdownMenuItem(
                  value: setType,
                  child: Text(EnumDisplayNames.getSetTypeDisplayName(setType)),
                );
              }).toList(),
              onChanged: widget.isLoading
                  ? null
                  : (setType) {
                      if (setType == null) {
                        return;
                      }
                      _emitSetChange((setData) {
                        setData.setType = setType;
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
            ),
            SizedBox(height: sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: !widget.isLoading,
                    keyboardType: TextInputType.number,
                    initialValue: setData.minSets.toString(),
                    decoration: const InputDecoration(
                      labelText: "Min Sets",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return;
                      }
                      _emitSetChange((setData) {
                        setData.minSets = parsed;
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: TextFormField(
                    enabled: !widget.isLoading,
                    keyboardType: TextInputType.number,
                    initialValue: setData.maxSets?.toString() ?? "",
                    decoration: const InputDecoration(
                      labelText: "Max Sets",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      _emitSetChange((setData) {
                        setData.maxSets = value.isEmpty ? null : parsed;
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: !widget.isLoading,
                    keyboardType: TextInputType.number,
                    initialValue: setData.recommendedRestSecs.toString(),
                    decoration: const InputDecoration(
                      labelText: "Recommended Rest (secs)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return;
                      }
                      _emitSetChange((setData) {
                        setData.recommendedRestSecs = parsed;
                        setData.status = ComplexSetEditorDataStatus.pending;
                      });
                    },
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: TextFormField(
                    enabled: !widget.isLoading,
                    keyboardType: TextInputType.number,
                    initialValue: setData.maxRestSecs?.toString() ?? "",
                    decoration: const InputDecoration(
                      labelText: "Max Rest (secs)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
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
            DynamicListInput<ComplexSetExerciseEditorData>(
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
                _emitSetChange((setData) {
                  setData.exercises.add(
                    ComplexSetExerciseEditorData(
                      id: null,
                      position: setData.exercises.length + 1,
                      minReps: 1,
                      maxReps: null,
                      toMaxReps: false,
                      exerciseId: null,
                      exerciseName: null,
                      alternativeExerciseIds: const [],
                      status: ComplexSetEditorDataStatus.initial,
                    ),
                  );
                  setData.status = ComplexSetEditorDataStatus.pending;
                });
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
                      final value = exercise.difficulty?.value;
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
                  onAlternativeIdsChanged: (value) {
                    _updateExerciseAtIndex(index, (exercise) {
                      exercise.alternativeExerciseIds = value
                          .split(',')
                          .map((e) => int.tryParse(e.trim()))
                          .whereType<int>()
                          .toList();
                      exercise.status = ComplexSetEditorDataStatus.pending;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
