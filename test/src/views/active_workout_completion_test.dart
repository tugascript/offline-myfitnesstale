import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/active_workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/views/workouts/active_workout_view.dart';
import 'package:myfitnesstale/src/widgets/workouts/details/complete_modal.dart';

class _ActiveWorkoutCubit extends ActiveWorkoutCubit {
  int completions = 0;

  @override
  Future<void> startWorkout(
    int workoutId, {
    int? workoutPlanRecordId,
    int? week,
    int? day,
    int? workoutPosition,
  }) async {}

  @override
  Future<void> completeWorkout() async {
    completions++;
  }
}

void main() {
  testWidgets('manual completion requires confirmation', (tester) async {
    final cubit = _ActiveWorkoutCubit();
    final profileCubit = ProfileCubit();
    addTearDown(cubit.close);
    addTearDown(profileCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ActiveWorkoutCubit>.value(value: cubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: const MaterialApp(home: ActiveWorkoutView(workoutId: 1)),
      ),
    );

    await tester.tap(find.text('COMPLETE'));
    await tester.pumpAndSettle();
    expect(cubit.completions, 0);
    expect(find.text('COMPLETE WORKOUT'), findsOneWidget);

    await tester.tap(find.text('NO'));
    await tester.pumpAndSettle();
    expect(cubit.completions, 0);

    await tester.tap(find.text('COMPLETE'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(cubit.completions, 0);

    await tester.tap(find.text('COMPLETE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();
    expect(cubit.completions, 1);
    expect(find.text('COMPLETE WORKOUT'), findsNothing);
  });

  testWidgets('confirmation fits a narrow screen with large text', (
    tester,
  ) async {
    final cubit = _ActiveWorkoutCubit();
    addTearDown(cubit.close);
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      BlocProvider<ActiveWorkoutCubit>.value(
        value: cubit,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) =>
                        const CompleteWorkoutDialog(workoutName: 'this'),
                  );
                },
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteWorkoutDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();
    expect(cubit.completions, 1);
    expect(find.byType(CompleteWorkoutDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
