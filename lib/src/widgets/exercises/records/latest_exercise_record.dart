import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../cubits/exercise_record_cubit.dart';
import '../../../cubits/states/exercise_record_state.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/exercise_dto.dart';
import '../../../services/dtos/exercise_record_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/confirmation_dialog.dart';
import 'editors/create_exercise_record_modal.dart';
import 'editors/update_exercise_record_card.dart';
import 'exercise_record_reps.dart';

class LatestExerciseRecord extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final Units units;
  final ExerciseDto exercise;

  const LatestExerciseRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.exercise,
  });

  @override
  State<LatestExerciseRecord> createState() => _LatestExerciseRecordState();
}

class _LatestExerciseRecordState extends State<LatestExerciseRecord> {
  bool _editOpen = false;

  @override
  void initState() {
    super.initState();
    context
        .read<ExerciseRecordCubit>()
        .getLatestExerciseRecord(widget.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        if (!state.isLoading && state.latestExerciseRecord == null) {
          return _EmptyExerciseRecord(
            sizes: widget.sizes,
            theme: widget.theme,
            exerciseName: widget.exercise.name,
            units: widget.units,
            exerciseId: widget.exercise.id,
          );
        }

        if (_editOpen && state.latestExerciseRecord != null) {
          return UpdateExerciseRecordCard(
            theme: widget.theme,
            sizes: widget.sizes,
            units: widget.units,
            isLoading: state.isLoading,
            exercise: widget.exercise,
            record: state.latestExerciseRecord!,
            onClose: () {
              setState(() {
                _editOpen = false;
              });
            },
          );
        }

        return _LatestExerciseRecord(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoading,
          exercise: widget.exercise,
          exerciseRecord: state.latestExerciseRecord,
          onEdit: () {
            setState(() {
              _editOpen = true;
            });
          },
        );
      },
    );
  }
}

class _EmptyExerciseRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final String exerciseName;
  final Units units;
  final int exerciseId;

  const _EmptyExerciseRecord({
    required this.sizes,
    required this.theme,
    required this.exerciseName,
    required this.units,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => CreateExerciseRecordModal(
                theme: theme,
                sizes: sizes,
                units: units,
                exerciseId: exerciseId,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sizes.padding * 2,
              horizontal: sizes.padding,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: sizes.titleFontSize * 2,
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  "No $exerciseName records",
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  "Tap to add your first record",
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestExerciseRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final ExerciseDto exercise;
  final ExerciseRecordDto? exerciseRecord;
  final VoidCallback onEdit;

  const _LatestExerciseRecord({
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.exercise,
    required this.exerciseRecord,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padding,
            vertical: sizes.padding * 2,
          ),
          child: Skeletonizer(
            enabled: isLoading || exerciseRecord == null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Latest Record",
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('latest-exercise-record-edit'),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: sizes.titleFontSize * 1.2,
                        color: theme.colorScheme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      onPressed: onEdit,
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "💪",
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize * 1.2,
                          ),
                        ),
                        Text(
                          units == Units.imperial
                              ? " ${Converters.gramsToLbs(
                                  exerciseRecord?.maxStrength ?? 0,
                                ).toStringAsFixed(2)} LBS"
                              : " ${Converters.gramsToKg(
                                  exerciseRecord?.maxStrength ?? 0,
                                ).toStringAsFixed(2)} KG",
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ExerciseRecordReps(
                          units: units,
                          fontSize: sizes.subtitleFontSize,
                          reps: exerciseRecord?.reps ?? 0,
                          weight: exerciseRecord?.weight ?? 0,
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      children: [
                        SizedBox(width: sizes.padding * 2.75),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: sizes.subtitleFontSize * 1.2,
                              ),
                              Text(
                                " ${Formatters.formatDate(units, exerciseRecord?.recordDate ?? DateTime.now())}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizes.subtitleFontSize,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('latest-exercise-record-delete'),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.delete,
                            size: sizes.titleFontSize,
                            color:
                                theme.colorScheme.brightness == Brightness.dark
                                    ? Colors.red[400]
                                    : Colors.red[600],
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: 'Delete Exercise Record',
                                content:
                                    'Are you sure you want to delete this exercise record? This action cannot be undone.',
                                confirmLabel: 'DELETE',
                                isDestructive: true,
                                onConfirm: () async {
                                  if (exerciseRecord != null) {
                                    await context
                                        .read<ExerciseRecordCubit>()
                                        .deleteExerciseRecord(
                                          exerciseRecord!.id,
                                        );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
