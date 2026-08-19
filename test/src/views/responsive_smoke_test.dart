import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/views/home/activity_view.dart';
import 'package:myfitnesstale/src/widgets/common/muscles_wrap.dart';

void main() {
  MaterialApp buildHarness(GoRouter router, {TextScaler? textScaler}) {
    return MaterialApp.router(
      routerConfig: router,
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
    );
  }

  GoRouter createRouter() => GoRouter(
        initialLocation: '/activity',
        routes: [
          GoRoute(
            path: '/activity',
            builder: (context, state) => const ActivityView(),
          ),
        ],
      );

  testWidgets('activity hub renders on a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    final router = createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildHarness(router));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Plan History'), 200);

    expect(find.text('Workout History'), findsOneWidget);
    expect(find.text('Exercise Progress'), findsOneWidget);
    expect(find.text('Weight History'), findsOneWidget);
    expect(find.text('Plan History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('activity hub renders with enlarged text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final router = createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      buildHarness(
        router,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Plan History'), 200);

    expect(find.text('Plan History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muscle groups render in a narrow workout column',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180.2,
              child: MusclesWrap(
                theme: ThemeData.light(),
                sizes: DataDisplaySizes.getDataDisplaySizes(
                  ScreenSize.xs,
                ),
                leading: const Icon(Icons.fitness_center),
                title: 'Primary Muscles',
                muscles: const {Muscle.hamstrings},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Primary Muscles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
