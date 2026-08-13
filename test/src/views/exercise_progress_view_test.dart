import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/exercise_record_state.dart';
import 'package:myfitnesstale/src/cubits/states/profile_state.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/views/exercise_progress_view.dart';
import 'package:myfitnesstale/src/views/exercises/exercise_records_view.dart';

class _ExerciseRecordCubit extends ExerciseRecordCubit {
  _ExerciseRecordCubit(ExerciseRecordState initialState) {
    emit(initialState);
  }

  int loadCalls = 0;

  @override
  Future<void> getExerciseRecords({
    int limit = 25,
    int offset = 0,
    (DateTime start, DateTime end)? dateRange,
    int? exerciseId,
  }) async {
    loadCalls++;
  }
}

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit(Units units) {
    setUnits(units);
  }

  void setUnits(Units units) {
    emit(ProfileState(
      system: SystemDto(
        id: 1,
        units: units,
        theme: ThemeType.system,
        initialSetup: SetUpStatus.completed,
        notificationsOn: false,
      ),
      isLoading: false,
      isInitiated: true,
    ));
  }
}

void main() {
  const muscles = TargetMuscles(
    primary: <Muscle>{},
    secondary: <Muscle>{},
  );
  const alpha = ExerciseDto(
    id: 1,
    name: 'Alpha Press',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: muscles,
    createdBy: CreatedBy.user,
  );
  const zulu = ExerciseDto(
    id: 2,
    name: 'Zulu Row',
    description: '',
    muscleGroup: MuscleGroup.pull,
    muscles: muscles,
    createdBy: CreatedBy.user,
  );

  final records = <ExerciseRecordDto>[
    ExerciseRecordDto(
      id: 1,
      exerciseId: alpha.id,
      weight: 100000,
      reps: 3,
      maxStrength: 110000,
      recordDate: DateTime.utc(2026, 8, 13),
      exercise: alpha,
    ),
    ExerciseRecordDto(
      id: 2,
      exerciseId: alpha.id,
      weight: 90000,
      reps: 12,
      maxStrength: 120000,
      recordDate: DateTime.utc(2026, 8, 12),
      exercise: alpha,
    ),
    ExerciseRecordDto(
      id: 3,
      exerciseId: zulu.id,
      weight: 50000,
      reps: 8,
      maxStrength: 60000,
      recordDate: DateTime.utc(2026, 8, 11),
      exercise: zulu,
    ),
  ];

  late _ExerciseRecordCubit exerciseRecordCubit;
  late _ProfileCubit profileCubit;

  Widget buildHarness({Units units = Units.metric}) {
    exerciseRecordCubit = _ExerciseRecordCubit(
      ExerciseRecordState.initial().copyWith(exerciseRecords: records),
    );
    profileCubit = _ProfileCubit(units);

    final router = GoRouter(
      initialLocation: ExerciseProgressView.routeName,
      routes: [
        GoRoute(
          path: ExerciseProgressView.routeName,
          builder: (context, state) => const ExerciseProgressView(),
        ),
        GoRoute(
          path: ExerciseRecordsView.routeName,
          builder: (context, state) => Scaffold(
            body: Text('Records for ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ExerciseRecordCubit>.value(value: exerciseRecordCubit),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  tearDown(() async {
    await exerciseRecordCubit.close();
    await profileCubit.close();
  });

  testWidgets('renders in a bounded layout with sorted, coherent metric data',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(exerciseRecordCubit.loadCalls, 1);
    expect(find.text('Records'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('100 kg × 3 reps'), findsOneWidget);
    expect(find.text('100 kg × 12 reps'), findsNothing);

    final alphaPosition = tester.getTopLeft(find.text(alpha.name));
    final zuluPosition = tester.getTopLeft(find.text(zulu.name));
    expect(alphaPosition.dy, lessThan(zuluPosition.dy));
  });

  testWidgets('displays profile-selected imperial weight', (tester) async {
    await tester.pumpWidget(buildHarness(units: Units.imperial));
    await tester.pump();

    expect(find.text('220.46 lb × 3 reps'), findsOneWidget);
    expect(find.textContaining('kg'), findsNothing);
  });

  testWidgets('opens the implemented exercise records destination',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.text(alpha.name));
    await tester.pumpAndSettle();

    expect(find.text('Records for 1'), findsOneWidget);
  });
}
