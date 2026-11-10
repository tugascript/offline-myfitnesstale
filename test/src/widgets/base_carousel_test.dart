import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/ui/core/sizes/data_display_sizes.dart';
import '../../../lib/src/ui/core/sizes/screen_size.dart';
import '../../../lib/src/ui/core/widgets/base_carousel.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestableWidget(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            textScaler: textScaler ?? const TextScaler.linear(1.0),
          ),
          child: child,
        ),
      ),
    );
  }

  group('BaseCarousel widget tests', () {
    testWidgets('renders title, children, and labels', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          BaseCarousel(
            sizes: sizes,
            title: 'Sample Carousel',
            labels: const ['First', 'Second'],
            children: const [Text('Child Page 1'), Text('Child Page 2')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sample Carousel'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Child Page 1'), findsOneWidget);
      expect(find.text('Child Page 2'), findsOneWidget);
    });

    testWidgets('renders custom header instead of title when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          BaseCarousel(
            sizes: sizes,
            header: const Row(
              children: [Icon(Icons.star), Text('Custom Header')],
            ),
            labels: const ['Tab A', 'Tab B'],
            children: const [Text('Content A'), Text('Content B')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Custom Header'), findsOneWidget);
    });

    testWidgets(
      'tapping page button scrolls to that page and invokes onPageChanged',
      (tester) async {
        int? changedPage;

        await tester.pumpWidget(
          buildTestableWidget(
            BaseCarousel(
              sizes: sizes,
              keyPrefix: 'test-carousel',
              labels: const ['Page 0', 'Page 1'],
              onPageChanged: (page) => changedPage = page,
              children: const [
                SizedBox(height: 100, child: Text('Screen 0')),
                SizedBox(height: 100, child: Text('Screen 1')),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scroll = tester.widget<SingleChildScrollView>(
          find.byKey(const ValueKey('test-carousel-scroll')),
        );
        expect(scroll.controller!.position.pixels, equals(0));

        // Tap Page 1
        await tester.tap(find.byKey(const ValueKey('test-carousel-page-1')));
        await tester.pumpAndSettle();

        expect(scroll.controller!.position.pixels, greaterThan(0));
        expect(changedPage, equals(1));

        // Tap Page 0
        await tester.tap(find.byKey(const ValueKey('test-carousel-page-0')));
        await tester.pumpAndSettle();

        expect(scroll.controller!.position.pixels, equals(0));
        expect(changedPage, equals(0));
      },
    );

    testWidgets('swiping horizontally changes page and updates indicators', (
      tester,
    ) async {
      int? changedPage;

      await tester.pumpWidget(
        buildTestableWidget(
          BaseCarousel(
            sizes: sizes,
            keyPrefix: 'test-swipe',
            labels: const ['First', 'Second'],
            onPageChanged: (page) => changedPage = page,
            children: const [
              SizedBox(height: 100, child: Text('View A')),
              SizedBox(height: 100, child: Text('View B')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scroll = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('test-swipe-scroll')),
      );
      expect(scroll.controller!.position.pixels, equals(0));

      // Swipe left
      await tester.drag(
        find.byKey(const ValueKey('test-swipe-scroll')),
        Offset(-scroll.controller!.position.viewportDimension * 0.75, 0),
      );
      await tester.pumpAndSettle();

      expect(scroll.controller!.position.pixels, greaterThan(0));
      expect(changedPage, equals(1));
    });

    testWidgets('uses semanticLabelBuilder when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          BaseCarousel(
            sizes: sizes,
            labels: const ['Workout', 'Meal'],
            semanticLabelBuilder: (label, index, total) =>
                'Custom $label: ${index + 1} of $total',
            children: const [Text('Content 1'), Text('Content 2')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Custom Workout: 1 of 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Custom Meal: 2 of 2'), findsOneWidget);
    });

    testWidgets(
      'handles narrow width 320px and 200% text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestableWidget(
            BaseCarousel(
              sizes: sizes,
              title: 'Long Title Fitting In Screen',
              labels: const ['Very Long Tab Name 1', 'Very Long Tab Name 2'],
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                SizedBox(height: 200, child: Center(child: Text('Card 1'))),
                SizedBox(height: 200, child: Center(child: Text('Card 2'))),
              ],
            ),
            textScaler: const TextScaler.linear(2.0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BaseCarousel), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
