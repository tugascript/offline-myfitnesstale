import 'package:flutter/material.dart';

import '../../widgets/layout/responsive_scaffold.dart';

class CreateWorkoutRecordView extends StatelessWidget {
  static const routeName = '/workouts/:id/history/:version/records/create';

  final int workoutId;
  final int version;

  const CreateWorkoutRecordView({
    super.key,
    required this.workoutId,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Create Workout Record',
      body: const Placeholder(),
    );
  }
}
