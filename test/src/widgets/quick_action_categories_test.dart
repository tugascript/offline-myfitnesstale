import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_action_category_card.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_action_destination_sheet.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_actions_widget.dart';

const _groups = {
  'training': {
    'Workouts': '/workouts',
    'Workout Plans': '/workout-plans',
    'Workout History': '/workouts',
    'Workout Plan History': '/workout-plans',
  },
  'weight': {
    'Weight Records': '/weight-records',
    'Weight Goals': '/weight-goal',
  },
  'exercises': {
    'Exercises': '/exercises',
    'Exercise Progress': '/exercises/progress',
    'Strength Goals': '/strength-goals',
    'Equipment': '/equipments',
  },
  'nutrition': {
    'Macro Goals': '/macro-goals',
    'Meal Plans': '/meal-plans',
    'Recipes': '/recipes',
    'Foods': '/foods',
  },
};

void main() {
  Future<ScrollController> pumpHome(
    WidgetTester tester, {
    double scale = 1,
    double width = 390,
    double height = 800,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ListView(
              controller: scroll,
              children: [
                const SizedBox(height: 300),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: QuickActionsWidget(
                    theme: Theme.of(context),
                    sizes: DataDisplaySizes.getDataDisplaySizes(
                      BreakPoint.fromContext(context).screenSize,
                    ),
                  ),
                ),
                const SizedBox(height: 500),
              ],
            ),
          ),
        ),
        for (final route
            in _groups.values.expand((group) => group.values).toSet())
          GoRoute(
            path: route,
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text(route)),
              body: Text('Destination ${state.uri.path}'),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return scroll;
  }

  Future<void> openGroup(WidgetTester tester, String group) async {
    final card = find.byKey(ValueKey('quick-action-category-$group'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(QuickActionDestinationSheet), findsOneWidget);
  }

  for (final group in _groups.entries) {
    for (final destination in group.value.entries) {
      testWidgets(
        '${group.key}: ${destination.key} navigates and Back restores Home',
        (tester) async {
          final scroll = await pumpHome(tester);
          await openGroup(tester, group.key);
          expect(find.byType(ListTile), findsNWidgets(group.value.length));
          for (final label in group.value.keys) {
            expect(
              find.descendant(
                of: find.byType(ListTile),
                matching: find.text(label),
              ),
              findsOneWidget,
            );
          }
          final homeOffset = scroll.offset;
          await tester.tap(
            find.descendant(
              of: find.byType(ListTile),
              matching: find.text(destination.key),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Destination ${destination.value}'), findsOneWidget);
          expect(find.byType(QuickActionDestinationSheet), findsNothing);
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.byType(QuickActionsWidget), findsOneWidget);
          expect(find.byType(QuickActionDestinationSheet), findsNothing);
          expect(scroll.offset, homeOffset);
        },
      );
    }
  }

  for (final method in ['close', 'outside', 'back', 'swipe']) {
    testWidgets('dismiss sheet using $method without navigating', (
      tester,
    ) async {
      await pumpHome(tester);
      await openGroup(tester, 'training');
      switch (method) {
        case 'close':
          await tester.tap(
            find.byKey(const ValueKey('quick-action-sheet-close')),
          );
        case 'outside':
          await tester.tapAt(const Offset(20, 20));
        case 'back':
          await tester.binding.handlePopRoute();
        case 'swipe':
          await tester.dragFrom(
            tester.getRect(find.byType(BottomSheet)).topCenter +
                const Offset(0, 20),
            const Offset(0, 600),
          );
      }
      await tester.pumpAndSettle();
      expect(find.byType(QuickActionDestinationSheet), findsNothing);
      expect(find.byType(QuickActionsWidget), findsOneWidget);
    });
  }

  for (final width in [320.0, 390.0, 900.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('cards and every sheet fit width $width and text $scale', (
        tester,
      ) async {
        await pumpHome(tester, width: width, scale: scale, dark: scale == 2);
        expect(find.byType(QuickActionCategoryCard), findsNWidgets(4));
        final training = find.byKey(
          const ValueKey('quick-action-category-training'),
        );
        final weight = find.byKey(
          const ValueKey('quick-action-category-weight'),
        );
        final first = tester.getTopLeft(training);
        final second = tester.getTopLeft(weight);
        if (width == 390 && scale == 1 || width == 900) {
          expect(first.dy, second.dy);
          expect(second.dx, greaterThan(first.dx));
        } else {
          expect(first.dx, second.dx);
          expect(second.dy, greaterThan(first.dy));
        }
        expect(tester.takeException(), isNull);
        for (final group in _groups.entries) {
          await openGroup(tester, group.key);
          final lastRow = find.descendant(
            of: find.byType(ListTile),
            matching: find.text(group.value.keys.last),
          );
          await tester.ensureVisible(lastRow);
          await tester.pumpAndSettle();
          expect(lastRow.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.byKey(const ValueKey('quick-action-sheet-close')),
          );
          await tester.pumpAndSettle();
        }
      });
    }
  }

  testWidgets(
    'short-screen sheet scrolls while its close button stays accessible',
    (tester) async {
      await pumpHome(tester, width: 320, height: 350, scale: 2);
      await openGroup(tester, 'exercises');
      final scrolling = find.descendant(
        of: find.byType(QuickActionDestinationSheet),
        matching: find.byType(Scrollable),
      );
      expect(
        tester.state<ScrollableState>(scrolling).position.maxScrollExtent,
        greaterThan(0),
      );
      final lastRow = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Equipment'),
      );
      await tester.ensureVisible(lastRow);
      await tester.pumpAndSettle();
      expect(lastRow.hitTestable(), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quick-action-sheet-close')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
