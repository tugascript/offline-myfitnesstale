import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/views/exercise_progress_view.dart';
import 'package:myfitnesstale/src/views/home/activity_view.dart';
import 'package:myfitnesstale/src/views/weight/weight_records_view.dart';
import 'package:myfitnesstale/src/views/workout_plans/workout_plan_list_view.dart';
import 'package:myfitnesstale/src/views/workouts/workouts_view.dart';

void main() {
  Widget buildHarness() {
    final router = GoRouter(
      initialLocation: '/activity',
      routes: [
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityView(),
        ),
        GoRoute(
          path: WorkoutsView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Workout destination')),
        ),
        GoRoute(
          path: ExerciseProgressView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Exercise destination')),
        ),
        GoRoute(
          path: WeightRecordsView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Weight destination')),
        ),
        GoRoute(
          path: WorkoutPlanListView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Plan destination')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders all four activity destinations', (tester) async {
    await tester.pumpWidget(buildHarness());

    expect(find.text('Workout History'), findsOneWidget);
    expect(find.text('Exercise Progress'), findsOneWidget);
    expect(find.text('Weight History'), findsOneWidget);
    expect(find.text('Plan History'), findsOneWidget);
  });

  final destinations = <String, String>{
    'Workout History': 'Workout destination',
    'Exercise Progress': 'Exercise destination',
    'Weight History': 'Weight destination',
    'Plan History': 'Plan destination',
  };

  for (final destination in destinations.entries) {
    testWidgets('${destination.key} opens its destination', (tester) async {
      await tester.pumpWidget(buildHarness());

      await tester.tap(find.text(destination.key));
      await tester.pumpAndSettle();

      expect(find.text(destination.value), findsOneWidget);
    });
  }
}
