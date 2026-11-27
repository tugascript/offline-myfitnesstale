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
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_record_dto.dart';
import '../../../../data/repositories/workouts/inputs/workout_cardio_set_exercise_record_batch_input.dart';
import '../../../../data/repositories/workouts/inputs/workout_cardio_set_record_batch_input.dart';
import '../../../../data/repositories/workouts/inputs/workout_record_batch_input.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/exercise_details.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/cardio_set_type_badge.dart';
import '../../../core/widgets/detail_number.dart';
import '../../../core/widgets/layout/app_outlined_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../view_models/states/workout_record_state.dart';
import '../../view_models/workout_record_cubit.dart';
import './workout_cardio_set_exercise_record_form.dart';

class UpdateCardioWorkoutRecordEditor extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final List<WorkoutCardioSetDto> cardioSets;
  final int workoutId;
  final int version;
  final int workoutRecordId;

  const UpdateCardioWorkoutRecordEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.cardioSets,
    required this.workoutId,
    required this.version,
    required this.workoutRecordId,
  });

  @override
  State<UpdateCardioWorkoutRecordEditor> createState() =>
      _UpdateCardioWorkoutRecordEditorState();
}

class _UpdateCardioWorkoutRecordEditorState
    extends State<UpdateCardioWorkoutRecordEditor> {
  final Map<int, Map<int, Map<int, WorkoutCardioSetExerciseRecordBatchInput>>>
  _cardioExercises = {};
  final Map<int, Map<int, int>> _roundRestSecs = {};

  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  List<WorkoutCardioSetRecordBatchInput> _cardioSets = [];
  DateTime _startedAt = DateTime.now().subtract(const Duration(minutes: 30));
  DateTime _completedAt = DateTime.now();

  void _populateInitialData() {
    final record = context
        .read<WorkoutRecordCubit>()
        .state
        .selectedWorkoutRecord;

    if (record == null || record.id != widget.workoutRecordId) {
      return;
    }

    _startedAt = record.startedAt;
    _completedAt =
        record.completedAt ?? _startedAt.add(const Duration(minutes: 30));

    for (final setRecord in record.cardioSetRecords ?? []) {
      final setId = setRecord.workoutCardioSetId;
      final roundNumber = setRecord.roundNumber;

      _roundRestSecs[setId] ??= {};
      _roundRestSecs[setId]![roundNumber] = setRecord.totalRestSecs ?? 0;

      final exerciseRecords =
          setRecord.exerciseRecords ?? <WorkoutCardioSetExerciseRecordDto>[];
      for (final exRecord in exerciseRecords) {
        _cardioExercises[setId] ??= {};
        _cardioExercises[setId]![roundNumber] ??= {};
        _cardioExercises[setId]![roundNumber]![exRecord
                .workoutCardioSetExerciseId] =
            WorkoutCardioSetExerciseRecordBatchInput(
              workoutCardioSetExerciseId: exRecord.workoutCardioSetExerciseId,
              exerciseId: exRecord.exerciseId,
              position: exRecord.position,
              mode: exRecord.mode,
              quantity: exRecord.quantity,
              durationSecs: exRecord.durationSecs,
              restSecs: exRecord.restSecs,
              rpe: exRecord.rpe,
            );
      }
    }
  }

  void _ensureDefaults() {
    for (
      var blockIndex = 0;
      blockIndex < widget.cardioSets.length;
      blockIndex++
    ) {
      final set = widget.cardioSets[blockIndex];
      _cardioExercises[set.id] ??= {};
      _roundRestSecs[set.id] ??= {};
      final isLastBlock = blockIndex == widget.cardioSets.length - 1;

      for (var round = 1; round <= set.rounds; round++) {
        _cardioExercises[set.id]![round] ??= {};
        final isFinalRoundOfWorkout = isLastBlock && round == set.rounds;
        _roundRestSecs[set.id]![round] ??= isFinalRoundOfWorkout
            ? 0
            : set.restSecs;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _populateInitialData();
    _ensureDefaults();
    _startTimeController.text = _formatDateTime(widget.units, _startedAt);
    _endTimeController.text = _formatDateTime(widget.units, _completedAt);
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _rebuildBatchSets() {
    final result = <WorkoutCardioSetRecordBatchInput>[];
    for (final set in widget.cardioSets) {
      final roundsMap = _cardioExercises[set.id] ?? {};
      final sortedRounds = roundsMap.keys.toList()..sort();
      for (final roundNumber in sortedRounds) {
        final exercisesMap = roundsMap[roundNumber] ?? {};
        final exercisesList = exercisesMap.values.toList()
          ..sort((a, b) => a.position.compareTo(b.position));
        if (exercisesList.isNotEmpty) {
          result.add(
            WorkoutCardioSetRecordBatchInput(
              workoutCardioSetId: set.id,
              roundNumber: roundNumber,
              startedAt: _startedAt,
              completedAt: _completedAt,
              totalRestSecs: _roundRestSecs[set.id]?[roundNumber] ?? 0,
              exercises: exercisesList,
            ),
          );
        }
      }
    }
    setState(() {
      _cardioSets = result;
    });
  }

  Future<void> _onSave() async {
    if (!_completedAt.isAfter(_startedAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    if (_cardioSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log at least one round.')),
      );
      return;
    }
    for (final setInput in _cardioSets) {
      for (final exercise in setInput.exercises) {
        if (exercise.mode == CardioBaseMode.units && exercise.quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Completed units must be greater than 0 for unit-based exercises.',
              ),
            ),
          );
          return;
        }
      }
    }

    await context.read<WorkoutRecordCubit>().batchUpdateWorkoutRecord(
      widget.workoutRecordId,
      WorkoutRecordBatchInput(
        workoutId: widget.workoutId,
        version: widget.version,
        startedAt: _startedAt,
        completedAt: _completedAt,
        cardioSets: _cardioSets,
      ),
    );
    if (!mounted) return;
    final err = context.read<WorkoutRecordCubit>().state.error;
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.description)));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Workout record saved.')));
    if (context.canPop()) {
      context.pop();
    }
  }

  String _formatTarget(WorkoutCardioSetExerciseDto exercise) {
    if (exercise.mode == CardioBaseMode.time) {
      return Converters.formatDuration(exercise.quantity);
    }
    final unit = exercise.exercise
        ?.getDetails<CardioExerciseDetails>()
        ?.unit
        .trim();
    if (unit != null && unit.isNotEmpty) {
      return '${exercise.quantity} $unit';
    }
    return '${exercise.quantity} units';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cardioSets.isEmpty) {
      return const Text('No cardio blocks found for this workout.');
    }

    return BlocConsumer<WorkoutRecordCubit, WorkoutRecordState>(
      listenWhen: (previous, next) =>
          previous.selectedWorkoutRecord != next.selectedWorkoutRecord,
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!.description)));
          return;
        }
        if (state.selectedWorkoutRecord != null) {
          setState(() {
            _populateInitialData();
            _ensureDefaults();
            _startTimeController.text = _formatDateTime(
              widget.units,
              _startedAt,
            );
            _endTimeController.text = _formatDateTime(
              widget.units,
              _completedAt,
            );
          });
          _rebuildBatchSets();
        }
      },
      builder: (context, state) {
        final mutedColor = widget.theme.colorScheme.onSurfaceVariant;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.zero,
              shape: const BeveledRectangleBorder(),
              child: Padding(
                padding: EdgeInsets.all(widget.sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: widget.sizes.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: widget.sizes.spacing),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextFormField(
                            theme: widget.theme,
                            fontSize: widget.sizes.fontSize,
                            padding: widget.sizes.padding,
                            labelText: 'Start Time',
                            controller: _startTimeController,
                            readOnly: true,
                            filled: true,
                            isLoading: state.isLoading,
                            onTap: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startedAt,
                                firstDate: DateTime(now.year - 1),
                                lastDate: now,
                              );
                              if (date != null && context.mounted) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    _startedAt,
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    _startedAt = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    _startTimeController.text = _formatDateTime(
                                      widget.units,
                                      _startedAt,
                                    );
                                  });
                                  _rebuildBatchSets();
                                }
                              }
                            },
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              size: widget.sizes.fontSize * 1.2,
                            ),
                          ),
                          SizedBox(height: widget.sizes.inputSpacing),
                          AppTextFormField(
                            theme: widget.theme,
                            fontSize: widget.sizes.fontSize,
                            padding: widget.sizes.padding,
                            labelText: 'End Time',
                            controller: _endTimeController,
                            filled: true,
                            readOnly: true,
                            isLoading: state.isLoading,
                            onTap: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _completedAt,
                                firstDate: DateTime(now.year - 1),
                                lastDate: now,
                              );
                              if (date != null && context.mounted) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    _completedAt,
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    _completedAt = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    _endTimeController.text = _formatDateTime(
                                      widget.units,
                                      _completedAt,
                                    );
                                  });
                                  _rebuildBatchSets();
                                }
                              }
                            },
                            prefixIcon: Icon(
                              Icons.event_available,
                              size: widget.sizes.fontSize * 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: widget.sizes.spacing),
            ...widget.cardioSets.asMap().entries.map((blockEntry) {
              final blockIndex = blockEntry.key;
              final set = blockEntry.value;
              final exercises = set.exercises;
              if (exercises == null || exercises.isEmpty) {
                return const SizedBox.shrink();
              }
              final isLastBlock = blockIndex == widget.cardioSets.length - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: widget.sizes.halfSpacing,
                    runSpacing: widget.sizes.quarterSpacing,
                    children: [
                      CardioSetTypeBadge(
                        sizes: widget.sizes,
                        setType: set.setType,
                      ),
                      Text(
                        'Block ${blockIndex + 1} (${set.rounds} ${set.rounds == 1 ? 'round' : 'rounds'})',
                        style: TextStyle(
                          fontSize: widget.sizes.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  Card(
                    margin: EdgeInsets.only(bottom: widget.sizes.spacing),
                    shape: const BeveledRectangleBorder(),
                    child: Column(
                      children: List<Widget>.generate(set.rounds, (roundIdx) {
                        final roundNumber = roundIdx + 1;
                        final isFinalRoundOfWorkout =
                            isLastBlock && roundNumber == set.rounds;

                        return Padding(
                          padding: EdgeInsets.all(widget.sizes.padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Round $roundNumber',
                                style: TextStyle(
                                  fontSize: widget.sizes.fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: widget.sizes.spacing),
                              ...exercises.asMap().entries.map((entry) {
                                final exIndex = entry.key;
                                final exercise = entry.value;
                                final isLastExerciseInRound =
                                    exIndex == exercises.length - 1;
                                final isLastRoundInBlock =
                                    roundNumber == set.rounds;
                                final loggedEx =
                                    _cardioExercises[set
                                        .id]?[roundNumber]?[exercise.id];
                                final showExerciseRest =
                                    (set.setType == CardioSetType.interval &&
                                        (!isLastExerciseInRound ||
                                            (!isLastRoundInBlock &&
                                                set.restSecs == 0 &&
                                                exercise.restSecs > 0))) ||
                                    (loggedEx?.restSecs ?? 0) > 0;
                                final unit = exercise.exercise
                                    ?.getDetails<CardioExerciseDetails>()
                                    ?.unit;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: widget.sizes.halfSpacing,
                                      runSpacing: widget.sizes.quarterSpacing,
                                      children: [
                                        DetailNumber(
                                          number: exIndex + 1,
                                          theme: widget.theme,
                                          fontSize: widget.sizes.fontSize,
                                        ),
                                        Text(
                                          exercise.exercise?.name ??
                                              'Unknown Exercise',
                                          style: TextStyle(
                                            fontSize: widget.sizes.fontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '(${_formatTarget(exercise)})',
                                          style: TextStyle(
                                            fontSize: widget.sizes.fontSize,
                                            color: mutedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: widget.sizes.inputSpacing),
                                    WorkoutCardioSetExerciseRecordForm(
                                      key: ValueKey(
                                        'cardio_update_${set.id}_${roundNumber}_${exercise.id}',
                                      ),
                                      theme: widget.theme,
                                      sizes: widget.sizes,
                                      isLoading: state.isLoading,
                                      mode: exercise.mode,
                                      unit: unit,
                                      initialQuantity:
                                          loggedEx?.quantity ??
                                          exercise.quantity,
                                      initialDurationSecs:
                                          loggedEx?.durationSecs ??
                                          (exercise.mode == CardioBaseMode.time
                                              ? exercise.quantity
                                              : 0),
                                      initialRpe:
                                          loggedEx?.rpe ??
                                          WorkoutSetExerciseDifficultyType
                                              .rpe
                                              .defaultValue,
                                      showExerciseRest: showExerciseRest,
                                      initialExerciseRestSecs:
                                          loggedEx?.restSecs ??
                                          exercise.restSecs,
                                      showRoundRest:
                                          isLastExerciseInRound &&
                                          !isFinalRoundOfWorkout,
                                      initialRoundRestSecs:
                                          _roundRestSecs[set
                                              .id]?[roundNumber] ??
                                          set.restSecs,
                                      onRoundRestSecsChanged:
                                          isLastExerciseInRound &&
                                              !isFinalRoundOfWorkout
                                          ? (secs) {
                                              setState(() {
                                                _roundRestSecs[set
                                                        .id]![roundNumber] =
                                                    secs;
                                              });
                                              _rebuildBatchSets();
                                            }
                                          : null,
                                      onValuesChanged:
                                          ({
                                            required int quantity,
                                            required int durationSecs,
                                            required int restSecs,
                                            required int rpe,
                                          }) {
                                            setState(() {
                                              _cardioExercises[set
                                                      .id]![roundNumber]![exercise
                                                      .id] =
                                                  WorkoutCardioSetExerciseRecordBatchInput(
                                                    workoutCardioSetExerciseId:
                                                        exercise.id,
                                                    exerciseId:
                                                        exercise.exerciseId,
                                                    position: exercise.position,
                                                    mode: exercise.mode,
                                                    quantity: quantity,
                                                    durationSecs: durationSecs,
                                                    restSecs: restSecs,
                                                    rpe: rpe,
                                                  );
                                            });
                                            _rebuildBatchSets();
                                          },
                                    ),
                                    if (!isLastExerciseInRound)
                                      SizedBox(height: widget.sizes.spacing),
                                  ],
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: widget.sizes.spacing),
            AppOutlinedButton(
              theme: widget.theme,
              sizes: widget.sizes,
              isLoading: state.isLoading,
              onPressed: _onSave,
              label: 'Save workout record',
              icon: Icons.save,
            ),
          ],
        );
      },
    );
  }
}

String _formatDateTime(Units unit, DateTime dateTime) {
  switch (unit) {
    case Units.metric:
      return DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    case Units.imperial:
      return DateFormat("MM/dd/yyyy hh:mm a").format(dateTime);
  }
}
