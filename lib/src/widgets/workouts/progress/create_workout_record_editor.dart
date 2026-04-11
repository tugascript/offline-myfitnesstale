import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myfitnesstale/src/widgets/layout/app_text_form_field.dart';

import '../../../cubits/states/workout_record_state.dart';
import '../../../cubits/workout_record_cubit.dart';
import '../../../models/common.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/create_workout_record_batch_dto.dart';
import '../../../services/dtos/workout_set_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/mutation_button.dart';
import 'workout_set_exercise_record_form.dart';

class CreateWorkoutRecordEditor extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final int workoutId;
  final int version;
  final List<WorkoutSetDto> sets;

  const CreateWorkoutRecordEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.workoutId,
    required this.version,
    required this.sets,
  });

  @override
  State<CreateWorkoutRecordEditor> createState() =>
      _CreateWorkoutRecordEditorState();
}

class _CreateWorkoutRecordEditorState extends State<CreateWorkoutRecordEditor> {
  // Map of WorkoutSetId -> Map of IterationNumber -> Map of ExerciseId -> SetExerciseRecord
  final Map<int, Map<int, Map<int, CreateWorkoutSetExerciseRecordBatchDto>>>
      _setExercises = {};

  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  List<CreateWorkoutSetRecordBatchDto> _sets = [];
  DateTime _startedAt = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _completedAt = DateTime.now();

  /// WorkoutSetId -> iteration number -> rest seconds after that round
  final Map<int, Map<int, int>> _iterationRestSecs = {};

  /// Optional iterations (set id -> iteration numbers) the user chose not to log.
  final Map<int, Set<int>> _skippedOptionalIterations = {};

  @override
  void initState() {
    super.initState();
    _startTimeController.text = _formatDateTime(widget.units, _startedAt);
    _endTimeController.text = _formatDateTime(widget.units, _completedAt);
    for (final set in widget.sets) {
      _setExercises[set.id] = {};
      _iterationRestSecs[set.id] = {};
      final int iterations = set.maxSets ?? set.minSets;
      for (int i = 1; i <= iterations; i++) {
        _setExercises[set.id]![i] = {};
        _iterationRestSecs[set.id]![i] = set.recommendedRestSecs;
      }
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log at least one set.')),
      );
      return;
    }

    await context.read<WorkoutRecordCubit>().batchCreateWorkoutRecord(
          workoutId: widget.workoutId,
          version: widget.version,
          startedAt: _startedAt,
          completedAt: _completedAt,
          sets: _sets,
        );
    if (!mounted) return;
    final err = context.read<WorkoutRecordCubit>().state.error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.description)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout record saved.')),
    );
    context.pop();
  }

  void _updateChanges() {
    final List<CreateWorkoutSetRecordBatchDto> result = [];
    for (final set in widget.sets) {
      final iterationsMap = _setExercises[set.id] ?? {};
      for (final entry in iterationsMap.entries) {
        final iterationNumber = entry.key;
        final exercisesMap = entry.value;

        final exercisesList = exercisesMap.values.toList()
          ..sort((a, b) => a.position.compareTo(b.position));

        if (exercisesList.isNotEmpty) {
          result.add(CreateWorkoutSetRecordBatchDto(
            workoutSetId: set.id,
            setNumber: iterationNumber,
            startedAt: _startedAt,
            completedAt: _completedAt,
            totalRestSecs: _iterationRestSecs[set.id]?[iterationNumber] ?? 0,
            exercises: exercisesList,
          ));
        }
      }
    }
    setState(() {
      _sets = result;
    });
  }

  bool _iterationIsOptional(WorkoutSetDto set, int iterationNumber) {
    final max = set.maxSets;
    if (max == null || max <= set.minSets) return false;
    return iterationNumber > set.minSets;
  }

  void _skipOptionalIteration(WorkoutSetDto set, int iterationNumber) {
    setState(() {
      _skippedOptionalIterations
          .putIfAbsent(set.id, () => <int>{})
          .add(iterationNumber);
      _setExercises[set.id]![iterationNumber] = {};
    });
    _updateChanges();
  }

  void _includeOptionalIteration(WorkoutSetDto set, int iterationNumber) {
    setState(() {
      _skippedOptionalIterations[set.id]?.remove(iterationNumber);
    });
    _updateChanges();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sets.isEmpty) {
      return const Text('No sets found for this workout.');
    }

    return BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
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
                          labelText: "Start Time",
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
                                initialTime: TimeOfDay.fromDateTime(_startedAt),
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
                                _updateChanges();
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
                          labelText: "End Time",
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
                                initialTime:
                                    TimeOfDay.fromDateTime(_completedAt),
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
                                _updateChanges();
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
          ...widget.sets.map<Widget>((set) {
            final exercises = set.exercises;
            if (exercises == null || exercises.isEmpty) {
              return const SizedBox.shrink();
            }

            final int prevTotalSets = widget.sets
                .take(widget.sets.indexOf(set))
                .fold(0, (sum, set) => sum + (set.maxSets ?? set.minSets));
            final int totalSets = (set.maxSets ?? set.minSets) * set.position;
            final int iterations = set.maxSets ?? set.minSets;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.repeat, size: widget.sizes.fontSize * 1.2),
                    Text(
                      ' Sets ${prevTotalSets + 1} - ${prevTotalSets + totalSets}',
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
                  child: Column(
                    children: List<Widget>.generate(
                      iterations,
                      (iterationIndex) {
                        final iterationNumber = iterationIndex + 1;
                        final optional =
                            _iterationIsOptional(set, iterationNumber);
                        final skipped = _skippedOptionalIterations[set.id]
                                ?.contains(iterationNumber) ??
                            false;

                        return Padding(
                          padding: EdgeInsets.all(widget.sizes.padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      optional
                                          ? 'Set $iterationNumber (optional)'
                                          : 'Set $iterationNumber',
                                      style: TextStyle(
                                        fontSize: widget.sizes.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (optional && !skipped)
                                    TextButton(
                                      onPressed: state.isLoading
                                          ? null
                                          : () => _skipOptionalIteration(
                                                set,
                                                iterationNumber,
                                              ),
                                      child: Text(
                                        'Skip',
                                        style: TextStyle(
                                          fontSize: widget.sizes.fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (optional && skipped)
                                    TextButton(
                                      onPressed: state.isLoading
                                          ? null
                                          : () => _includeOptionalIteration(
                                                set,
                                                iterationNumber,
                                              ),
                                      child: Text(
                                        'Log this set',
                                        style: TextStyle(
                                          fontSize: widget.sizes.fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: widget.sizes.spacing),
                              if (optional && skipped) ...[
                                Text(
                                  'This set will not be saved.',
                                  style: TextStyle(
                                    fontSize: widget.sizes.fontSize * 0.95,
                                    color: widget
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ] else
                                ...exercises.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final exercise = entry.value;

                                  final loggedEx = _setExercises[set.id]
                                      ?[iterationNumber]?[exercise.exerciseId];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.exercise?.name ??
                                            'Unknown Exercise',
                                        style: TextStyle(
                                          fontSize: widget.sizes.fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                          height: widget.sizes.inputSpacing),
                                      WorkoutSetExerciseRecordForm(
                                        key: ValueKey(
                                          '${set.id}_${iterationNumber}_${exercise.id}',
                                        ),
                                        theme: widget.theme,
                                        sizes: widget.sizes,
                                        units: widget.units,
                                        isLoading: state.isLoading,
                                        initialWeight: loggedEx?.weight ?? 0,
                                        initialReps: loggedEx?.reps ?? 0,
                                        initialDifficulty:
                                            loggedEx?.difficulty.value ?? 8,
                                        initialDifficultyType:
                                            loggedEx?.difficulty.type ??
                                                WorkoutSetExerciseDifficultyType
                                                    .rpe,
                                        showIterationRest:
                                            index == exercises.length - 1,
                                        initialRestSecs:
                                            _iterationRestSecs[set.id]
                                                    ?[iterationNumber] ??
                                                set.recommendedRestSecs,
                                        onRestSecsChanged: index ==
                                                exercises.length - 1
                                            ? (secs) {
                                                setState(() {
                                                  _iterationRestSecs[set.id]![
                                                      iterationNumber] = secs;
                                                });
                                                _updateChanges();
                                              }
                                            : null,
                                        onValuesChanged: ({
                                          required double weight,
                                          required int reps,
                                          required WorkoutSetExerciseDifficulty
                                              difficulty,
                                        }) {
                                          setState(() {
                                            _setExercises[set.id]![
                                                        iterationNumber]![
                                                    exercise.exerciseId] =
                                                CreateWorkoutSetExerciseRecordBatchDto(
                                              workoutSetExerciseId: exercise.id,
                                              exerciseId: exercise.exerciseId,
                                              position: exercise.position,
                                              weight: weight.toInt(),
                                              reps: reps,
                                              difficulty: difficulty,
                                            );
                                          });
                                          _updateChanges();
                                        },
                                      ),
                                      if (index < exercises.length - 1)
                                        SizedBox(
                                          height: widget.sizes.spacing,
                                        ),
                                    ],
                                  );
                                }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: widget.sizes.spacing),
          MutationButton(
            theme: widget.theme,
            sizes: widget.sizes,
            isLoading: state.isLoading,
            onPressed: _onSave,
            label: 'Save workout record',
            icon: Icons.save,
          ),
        ],
      );
    });
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
