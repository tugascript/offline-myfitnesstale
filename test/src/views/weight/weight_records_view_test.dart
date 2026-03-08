import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/weight_record_cubit.dart';
import 'package:myfitnesstale/src/views/weight/weight_records_view.dart';

class TestWeightRecordCubit extends WeightRecordCubit {
  int getWeightRecordsCalls = 0;

  @override
  Future<void> getWeightRecords({
    int limit = 20,
    int offset = 0,
  }) async {
    getWeightRecordsCalls += 1;
  }
}

void main() {
  testWidgets('opens WeightRecordsView without layout exception',
      (tester) async {
    final profileCubit = ProfileCubit();
    final weightRecordCubit = TestWeightRecordCubit();

    addTearDown(() async {
      await profileCubit.close();
      await weightRecordCubit.close();
    });

    final router = GoRouter(
      initialLocation: WeightRecordsView.routeName,
      routes: [
        GoRoute(
          path: WeightRecordsView.routeName,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: profileCubit),
              BlocProvider<WeightRecordCubit>.value(value: weightRecordCubit),
            ],
            child: const WeightRecordsView(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      TestApp(router: router),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Weight Records'), findsOneWidget);
    expect(weightRecordCubit.getWeightRecordsCalls, 1);
    expect(tester.takeException(), isNull);
  });
}

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.router,
  });

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
