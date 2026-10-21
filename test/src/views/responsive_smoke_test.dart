import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/common/muscles_wrap.dart';

void main() {
  testWidgets('muscle groups render in a narrow workout column', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180.2,
              child: MusclesWrap(
                theme: ThemeData.light(),
                sizes: DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs),
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
