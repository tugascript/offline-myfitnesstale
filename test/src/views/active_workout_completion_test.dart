// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/ui/workouts/view_models/active_workout_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/active_workout_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/complete_modal.dart';

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
        child: const MaterialApp(home: ActiveWorkoutScreen(workoutId: 1)),
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
