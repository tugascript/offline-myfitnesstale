import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/views/exercises/exercises_view.dart';

class _ExerciseSearchCubit extends ExerciseCubit {
  int equipmentFetchCount = 0;
  final equipmentFetchStarted = Completer<void>();
  final releaseEquipmentFetch = Completer<void>();

  _ExerciseSearchCubit() {
    emit(state.copyWith(equipmentSelection: const {1: 'Barbell'}));
  }

  @override
  Future<void> getSelectionEquipments() async {
    equipmentFetchCount += 1;
    equipmentFetchStarted.complete();
    await releaseEquipmentFetch.future;
    emit(state.copyWith(
      equipmentSelection: const {
        1: 'Barbell',
        2: 'Cable Machine',
      },
    ));
  }

  @override
  Future<void> getExercises({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? equipmentId,
    int? limit,
    int? offset,
    bool isFavourite = false,
  }) async {}
}

void main() {
  testWidgets('refreshes equipment choices when exercise search opens',
      (tester) async {
    final cubit = _ExerciseSearchCubit();
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: ExercisesView.routeName,
      routes: [
        GoRoute(
          path: ExercisesView.routeName,
          builder: (_, __) => const ExercisesView(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ExerciseCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await cubit.equipmentFetchStarted.future;

    expect(cubit.equipmentFetchCount, 1);
    expect(find.text('Cable Machine'), findsNothing);

    final fetchedState = cubit.stream.firstWhere(
      (state) => state.equipmentSelection.containsValue('Cable Machine'),
    );
    cubit.releaseEquipmentFetch.complete();
    await fetchedState;
    await tester.pump();

    await tester.tap(find.text('All Equipment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Barbell'), findsOneWidget);
    expect(find.text('Cable Machine'), findsOneWidget);
  });
}
