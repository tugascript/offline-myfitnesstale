import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/utilities/converters.dart';

import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../services/dtos/workout_set_dto.dart';
import '../../../services/dtos/workout_set_exercise_dto.dart';
import '../../../utilities/sizes/workout_detail_sizes.dart';
import '../../layout/app_card.dart';

class WorkoutSetCard extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final WorkoutSetDto set;
  final int setNumber;

  const WorkoutSetCard({
    super.key,
    required this.sizes,
    required this.set,
    required this.setNumber,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ExpansionTile(
        leading: Container(
          width: sizes.subtitleFontSize * 1.75,
          height: sizes.subtitleFontSize * 1.75,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Center(
            child: Text(
              setNumber.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: sizes.subtitleFontSize,
              ),
            ),
          ),
        ),
        initiallyExpanded: true,
        title: Row(
          children: [
            Icon(Icons.repeat, size: sizes.subtitleFontSize),
            SizedBox(width: sizes.subtitleFontSize / 3),
            Text(
              '${set.minSets}${set.maxSets != null ? '-${set.maxSets}' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: sizes.subtitleFontSize,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: sizes.spacing / 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SetTypeBadge(
                  sizes: sizes,
                  setType: set.setType,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: sizes.smallFontSize,
                      color: Colors.grey[800],
                    ),
                    Text(
                      ' ${set.exercises?.length ?? 0} ',
                      style: TextStyle(
                        fontSize: sizes.smallFontSize,
                        color: Colors.grey[800],
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: sizes.smallFontSize,
                      color: Colors.grey[600],
                    ),
                    Text(
                      ' ${Converters.formatDuration(set.recommendedRestSecs)}${set.maxRestSecs != null ? '-${Converters.formatDuration(set.maxRestSecs!)}' : ''}',
                      style: TextStyle(
                        fontSize: sizes.smallFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        children: [
          if (set.exercises?.isEmpty ?? true)
            Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: Text(
                'No exercises in this set',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: sizes.fontSize,
                ),
              ),
            )
          else
            ...set.exercises!.map((setExercise) {
              return _SetExercise(sizes: sizes, setExercise: setExercise);
            }),
          SizedBox(height: sizes.padding),
        ],
      ),
    );
  }
}

class _SetTypeBadge extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final WorkoutSetType setType;

  const _SetTypeBadge({
    required this.sizes,
    required this.setType,
  });

  Color _getSetTypeColor(WorkoutSetType type) {
    switch (type) {
      case WorkoutSetType.standard:
        return Colors.blue;
      case WorkoutSetType.drop:
        return Colors.red;
      case WorkoutSetType.superSet:
        return Colors.purple;
      case WorkoutSetType.giant:
        return Colors.green;
      case WorkoutSetType.pyramid:
        return Colors.amber;
      case WorkoutSetType.circuit:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSetTypeColor(setType);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padding / 4,
        vertical: sizes.padding / 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        EnumDisplayNames.getSetTypeDisplayName(setType),
        style: TextStyle(
          color: color,
          fontSize: sizes.smallFontSize,
        ),
      ),
    );
  }
}

class _SetExercise extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final WorkoutSetExerciseDto setExercise;

  const _SetExercise({
    required this.sizes,
    required this.setExercise,
  });

  @override
  Widget build(BuildContext context) {
    final smallPadding = sizes.padding / 4;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${setExercise.minReps}${setExercise.maxReps != null ? '-${setExercise.maxReps}' : ''}x ',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              color: Colors.grey[600], // TODO: add theming
            ),
          ),
          Text(
            setExercise.exercise?.name ?? 'Unknown Exercise',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
            ),
          ),
        ],
      ),
      subtitle: (setExercise.options != null && setExercise.options!.isNotEmpty)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: sizes.padding),
                Padding(
                  padding: EdgeInsets.only(top: smallPadding),
                  child: Wrap(
                    spacing: smallPadding,
                    children: [
                      Text(
                        'Alternatives: ',
                        style: TextStyle(
                          fontSize: sizes.smallFontSize,
                          color: Colors.grey[500], // TODO: add theming
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ...setExercise.options!.asMap().entries.map(
                            (entry) => Text(
                              '${entry.value.exercise?.name}${entry.key == setExercise.options!.length - 1 ? '' : ', '}',
                              style: TextStyle(
                                fontSize: sizes.smallFontSize,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      onTap: () {
        context.push('/exercises/${setExercise.exerciseId}');
      },
    );
  }
}
