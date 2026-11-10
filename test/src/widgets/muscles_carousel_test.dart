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
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_carousel.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_data.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_diagram.dart';

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

  group('MusclesCarousel widget tests', () {
    testWidgets(
      'renders MusclesDiagram and MusclesData horizontally scrollable',
      (tester) async {
        const muscles = TargetMuscles(
          primary: {Muscle.chest, Muscle.upperChest},
          secondary: {Muscle.triceps, Muscle.frontDelts},
        );

        await tester.pumpWidget(
          buildTestableWidget(
            MusclesCarousel(
              sizes: sizes,
              muscleGroup: MuscleGroup.push,
              muscles: muscles,
              equipments: const [
                EquipmentDto(
                  id: 1,
                  name: 'Barbell',
                  createdBy: CreatedBy.system,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MusclesCarousel), findsOneWidget);
        expect(find.byType(MusclesDiagram), findsOneWidget);
        expect(find.byType(MusclesData), findsOneWidget);
        expect(find.text('Diagram'), findsOneWidget);
        expect(find.text('Data'), findsOneWidget);
      },
    );

    testWidgets('tapping Data tab scrolls to page 1 and updates indicator', (
      tester,
    ) async {
      const muscles = TargetMuscles(
        primary: {Muscle.lats},
        secondary: {Muscle.biceps},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          MusclesCarousel(
            sizes: sizes,
            muscleGroup: MuscleGroup.pull,
            muscles: muscles,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on page 0
      final page0Button = find.byKey(const ValueKey('muscles-carousel-page-0'));
      final page1Button = find.byKey(const ValueKey('muscles-carousel-page-1'));

      expect(page0Button, findsOneWidget);
      expect(page1Button, findsOneWidget);

      final scroll = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('muscles-carousel-scroll')),
      );
      expect(scroll.controller!.position.pixels, equals(0));

      // Tap Data tab
      await tester.tap(page1Button);
      await tester.pumpAndSettle();

      expect(scroll.controller!.position.pixels, greaterThan(0));

      // Tap Diagram tab to return
      await tester.tap(page0Button);
      await tester.pumpAndSettle();
      expect(scroll.controller!.position.pixels, equals(0));
    });

    testWidgets('swiping horizontally changes page and updates indicators', (
      tester,
    ) async {
      const muscles = TargetMuscles(
        primary: {Muscle.quadriceps},
        secondary: {Muscle.glutes},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          MusclesCarousel(
            sizes: sizes,
            muscleGroup: MuscleGroup.legs,
            muscles: muscles,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scroll = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('muscles-carousel-scroll')),
      );
      expect(scroll.controller!.position.pixels, equals(0));

      // Drag left to page 1
      await tester.drag(
        find.byKey(const ValueKey('muscles-carousel-scroll')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(scroll.controller!.position.pixels, greaterThan(0));
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
            MusclesCarousel(
              sizes: sizes,
              muscleGroup: MuscleGroup.push,
              muscles: const TargetMuscles(
                primary: {Muscle.chest, Muscle.upperChest, Muscle.lowerChest},
                secondary: {
                  Muscle.triceps,
                  Muscle.frontDelts,
                  Muscle.sideDelts,
                },
              ),
              equipments: const [
                EquipmentDto(
                  id: 1,
                  name: 'Olympic Barbell',
                  createdBy: CreatedBy.system,
                ),
                EquipmentDto(
                  id: 2,
                  name: 'Incline Bench',
                  createdBy: CreatedBy.system,
                ),
              ],
            ),
            textScaler: const TextScaler.linear(2.0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MusclesCarousel), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('fromMuscles constructor sets up muscles correctly', (
      tester,
    ) async {
      final widget = MusclesCarousel.fromMuscles(
        sizes: sizes,
        muscleGroup: MuscleGroup.core,
        primaryMuscles: const {Muscle.abdominals},
        secondaryMuscles: const {Muscle.obliques},
        pageLabels: const ['Visual', 'Details'],
      );

      expect(widget.muscles.primary, equals({Muscle.abdominals}));
      expect(widget.muscles.secondary, equals({Muscle.obliques}));
      expect(widget.pageLabels, equals(['Visual', 'Details']));

      await tester.pumpWidget(buildTestableWidget(widget));
      await tester.pumpAndSettle();

      expect(find.text('Visual'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('supports muscleGroups set parameter', (tester) async {
      final widget = MusclesCarousel(
        sizes: sizes,
        muscleGroups: const {MuscleGroup.push, MuscleGroup.pull},
        muscles: const TargetMuscles(
          primary: {Muscle.chest, Muscle.lats},
          secondary: {},
        ),
      );

      expect(widget.muscleGroups, equals({MuscleGroup.push, MuscleGroup.pull}));
      expect(widget.muscleGroup, equals(MuscleGroup.push));

      await tester.pumpWidget(buildTestableWidget(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MusclesCarousel), findsOneWidget);
    });
  });
}
