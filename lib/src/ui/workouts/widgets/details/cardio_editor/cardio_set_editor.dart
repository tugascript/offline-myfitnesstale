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

import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../../data/utils/display_names.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../data/utils/exercise_details.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_dropdown.dart';
import '../../../../core/widgets/layout/dynamic_list_input.dart';
import '../../../../core/widgets/layout/expanding_section.dart';
import './cardio_duration_input.dart';
import './cardio_exercise_search_modal.dart';
import './cardio_rounds_input.dart';
import './cardio_set_editor_data.dart';
import './cardio_set_exercise_editor.dart';

const int _defaultTimeQuantitySecs = 60;
const int _defaultUnitsQuantity = 1;
const int _maxIntervalExercises = 10;

class CardioSetEditor extends StatefulWidget {
  final CardioSetEditorData setData;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<CardioSetEditorData> onChanged;

  const CardioSetEditor({
    super.key,
    required this.setData,
    required this.sizes,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<CardioSetEditor> createState() => _CardioSetEditorState();
}

class _CardioSetEditorState extends State<CardioSetEditor> {
  late CardioSetEditorData _workingSetData;

  CardioSetEditorData _cloneSetData(CardioSetEditorData source) {
    return CardioSetEditorData(
      internalId: source.internalId,
      id: source.id,
      position: source.position,
      setType: source.setType,
      restSecs: source.restSecs,
      rounds: source.rounds,
      exercises: source.exercises
          .map(
            (exercise) => CardioSetExerciseEditorData(
              internalId: exercise.internalId,
              id: exercise.id,
              position: exercise.position,
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
              exerciseDefaultMode: exercise.exerciseDefaultMode,
              exerciseUnitType: exercise.exerciseUnitType,
              exerciseUnit: exercise.exerciseUnit,
              mode: exercise.mode,
              quantity: exercise.quantity,
              restSecs: exercise.restSecs,
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
  void didUpdateWidget(covariant CardioSetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _workingSetData = _cloneSetData(widget.setData);
  }

  void _emitSetChange(void Function(CardioSetEditorData setData) update) {
    final nextSet = _cloneSetData(_workingSetData);
    update(nextSet);
    _workingSetData = _cloneSetData(nextSet);
    widget.onChanged(nextSet);
  }

  List<CardioSetExerciseEditorData> _normalizeExercisePositions(
    List<CardioSetExerciseEditorData> exercises,
  ) {
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].position = i + 1;
    }
    return exercises;
  }

  void _updateExerciseAtIndex(
    int index,
    void Function(CardioSetExerciseEditorData exercise) update,
  ) {
    _emitSetChange((setData) {
      final exercise = setData.exercises[index];
      update(exercise);
      setData.exercises = _normalizeExercisePositions(setData.exercises);
    });
  }

  void _applyExerciseDto(
    CardioSetExerciseEditorData target,
    ExerciseDto exercise,
  ) {
    final details = exercise.getDetails<CardioExerciseDetails>();
    final nextMode = details?.defaultMode ?? target.mode;
    final modeChanged = nextMode != target.mode;

    target.exerciseId = exercise.id;
    target.exerciseName = exercise.name;
    target.exerciseDefaultMode = details?.defaultMode;
    target.exerciseUnitType = details?.unitType;
    target.exerciseUnit = details?.unit;
    target.mode = nextMode;
    if (modeChanged || target.quantity <= 0) {
      target.quantity = nextMode == CardioBaseMode.time
          ? _defaultTimeQuantitySecs
          : _defaultUnitsQuantity;
    }
  }

  bool _canAddExercise(CardioSetEditorData setData) {
    switch (setData.setType) {
      case CardioSetType.constant:
        return setData.exercises.isEmpty;
      case CardioSetType.interval:
        return setData.exercises.length < _maxIntervalExercises;
    }
  }

  void _openAddExerciseModal(BuildContext context, DataDisplaySizesList sizes) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CardioExerciseSearchModal(
          sizes: sizes,
          isLoading: widget.isLoading,
          onExerciseSelected: (exercise) {
            if (!dialogContext.mounted) return;
            final details = exercise.getDetails<CardioExerciseDetails>();
            final mode = details?.defaultMode ?? CardioBaseMode.time;
            _emitSetChange((setData) {
              setData.exercises.add(
                CardioSetExerciseEditorData(
                  id: null,
                  position: setData.exercises.length + 1,
                  exerciseId: exercise.id,
                  exerciseName: exercise.name,
                  exerciseDefaultMode: details?.defaultMode,
                  exerciseUnitType: details?.unitType,
                  exerciseUnit: details?.unit,
                  mode: mode,
                  quantity: mode == CardioBaseMode.time
                      ? _defaultTimeQuantitySecs
                      : _defaultUnitsQuantity,
                  restSecs: 0,
                ),
              );
            });
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = widget.sizes;
    final setData = widget.setData;
    final isInterval = setData.setType == CardioSetType.interval;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<CardioSetType>(
              theme: theme,
              isLoading: widget.isLoading,
              value: setData.setType,
              emptyLabel: 'Set Type',
              labelText: 'Set Type',
              showEmptyValue: false,
              items: CardioSetType.values,
              labelBuilder: EnumDisplayNames.getCardioSetTypeDisplayName,
              onChanged: (setType) {
                if (widget.isLoading || setType == null) return;
                _emitSetChange((next) {
                  next.setType = setType;
                  if (setType == CardioSetType.constant) {
                    next.rounds = 1;
                    if (next.exercises.length > 1) {
                      next.exercises = [next.exercises.first];
                    }
                    for (final exercise in next.exercises) {
                      exercise.restSecs = 0;
                    }
                    next.exercises = _normalizeExercisePositions(
                      next.exercises,
                    );
                  }
                });
              },
              onSaved: (setType) {
                if (widget.isLoading || setType == null) return;
                _emitSetChange((next) {
                  next.setType = setType;
                });
              },
              fontSize: sizes.fontSize,
              padding: sizes.padding * 0.4,
              filled: true,
            ),
            SizedBox(height: sizes.spacing / 2),
            if (isInterval)
              Row(
                children: [
                  Expanded(
                    child: CardioRoundsInput(
                      sizes: sizes,
                      theme: theme,
                      initialRounds: setData.rounds,
                      enabled: !widget.isLoading,
                      onChanged: (rounds) {
                        _emitSetChange((next) {
                          next.rounds = rounds;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: sizes.spacing / 2),
                  Expanded(
                    child: CardioDurationInput(
                      theme: theme,
                      sizes: sizes,
                      seconds: setData.restSecs,
                      labelText: 'Rest',
                      sheetTitle: 'Set Rest',
                      allowHours: false,
                      minSeconds: 0,
                      enabled: !widget.isLoading,
                      icon: Icons.timer,
                      onChanged: (restSecs) {
                        _emitSetChange((next) {
                          next.restSecs = restSecs;
                        });
                      },
                    ),
                  ),
                ],
              )
            else
              CardioDurationInput(
                theme: theme,
                sizes: sizes,
                seconds: setData.restSecs,
                labelText: 'Rest',
                sheetTitle: 'Set Rest',
                allowHours: false,
                minSeconds: 0,
                enabled: !widget.isLoading,
                icon: Icons.timer,
                onChanged: (restSecs) {
                  _emitSetChange((next) {
                    next.restSecs = restSecs;
                  });
                },
              ),
            SizedBox(height: sizes.spacing / 2),
            ExpandingSection(
              icon: Icons.directions_run,
              dense: true,
              title:
                  '${setData.exercises.length} exercise${setData.exercises.length == 1 ? '' : 's'}',
              titleFountSize: sizes.fontSize,
              initiallyExpanded: setData.exercises.isEmpty,
              titleFontWeight: FontWeight.w500,
              padding: sizes.spacing / 2,
              children: [
                DynamicListInput<CardioSetExerciseEditorData>(
                  handlesPadding: sizes.padding / 3,
                  addButtonHeight: sizes.fontSize * 3,
                  theme: theme,
                  filled: true,
                  items: setData.exercises,
                  fontSize: sizes.fontSize,
                  padding: sizes.padding,
                  spacing: sizes.spacing,
                  isLoading: widget.isLoading,
                  addEnabled: _canAddExercise(setData),
                  addLabel: 'Add Exercise',
                  keyBuilder: (item) => ValueKey(item.id ?? item.internalId),
                  onAdd: () => _openAddExerciseModal(context, sizes),
                  onChanged: (items) {
                    _emitSetChange((next) {
                      next.exercises = _normalizeExercisePositions(
                        List<CardioSetExerciseEditorData>.from(items),
                      );
                    });
                  },
                  onReorder: (oldIndex, newIndex) {},
                  itemBuilder: (context, index, exerciseData) {
                    return CardioSetExerciseEditor(
                      exerciseData: exerciseData,
                      setType: setData.setType,
                      sizes: sizes,
                      isLoading: widget.isLoading,
                      onExerciseChanged: (exercise) {
                        _updateExerciseAtIndex(index, (target) {
                          _applyExerciseDto(target, exercise);
                        });
                      },
                      onModeChanged: (mode) {
                        _updateExerciseAtIndex(index, (target) {
                          if (target.mode == mode) return;
                          target.mode = mode;
                          target.quantity = mode == CardioBaseMode.time
                              ? _defaultTimeQuantitySecs
                              : _defaultUnitsQuantity;
                        });
                      },
                      onQuantityChanged: (quantity) {
                        _updateExerciseAtIndex(index, (target) {
                          target.quantity = quantity;
                        });
                      },
                      onRestSecsChanged: (restSecs) {
                        _updateExerciseAtIndex(index, (target) {
                          target.restSecs = restSecs;
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
