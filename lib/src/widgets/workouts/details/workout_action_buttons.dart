import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utilities/sizes/workout_detail_sizes.dart';

class WorkoutActionButtons extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final int workoutId;

  const WorkoutActionButtons({
    super.key,
    required this.sizes,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StartWorkoutButton(
                sizes: sizes,
                workoutId: workoutId,
              ),
            ),
            SizedBox(width: sizes.spacing),
            _EditWorkoutButton(
              sizes: sizes,
              workoutId: workoutId,
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        Row(
          children: [
            Expanded(
              child: _WorkoutHistoryButton(
                sizes: sizes,
                workoutId: workoutId,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditWorkoutButton extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final int workoutId;

  const _EditWorkoutButton({
    required this.sizes,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: () {
        context.push('/workouts/$workoutId/edit');
      },
      icon: Icon(
        Icons.edit,
        size: sizes.fontSize,
        fontWeight: FontWeight.w600,
      ),
      label: Text(
        'Edit'.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 1,
        ),
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final int workoutId;

  const _StartWorkoutButton({
    required this.sizes,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: fix me
        context.push('/workouts/$workoutId/active');
      },
      icon: Icon(
        Icons.play_arrow,
        size: sizes.fontSize,
        fontWeight: FontWeight.w600,
      ),
      label: Text(
        'Start Workout'.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}

class _WorkoutHistoryButton extends StatelessWidget {
  final WorkoutDetailSizesList sizes;
  final int workoutId;

  const _WorkoutHistoryButton({
    required this.sizes,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.push('/workouts/$workoutId/history');
      },
      icon: Icon(
        Icons.history,
        size: sizes.subtitleFontSize,
        fontWeight: FontWeight.w600,
      ),
      label: Text(
        'History'.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}
