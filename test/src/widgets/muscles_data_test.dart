import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscle_badge.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscle_group_badge.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_data.dart';

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

  group('MusclesData widget tests', () {
    testWidgets('renders all primary and secondary data when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MusclesData(
            sizes: sizes,
            muscleGroup: MuscleGroup.push,
            primaryMuscles: const {Muscle.chest, Muscle.upperChest},
            secondaryMuscles: const {Muscle.triceps, Muscle.frontDelts},
            equipments: const [
              EquipmentDto(id: 1, name: 'Barbell', createdBy: CreatedBy.system),
              EquipmentDto(
                id: 2,
                name: 'Incline Bench',
                createdBy: CreatedBy.system,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MusclesData), findsOneWidget);
      expect(find.text('🏋️‍♂️ Muscle Group'), findsOneWidget);
      expect(find.byType(MuscleGroupBadge), findsOneWidget);

      expect(find.text('💪 Primary Muscles'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Upper Chest'), findsOneWidget);

      expect(find.text(' Equipment'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Incline Bench'), findsOneWidget);

      expect(find.text('🥈 Secondary Muscles'), findsOneWidget);
      expect(find.text('Triceps'), findsOneWidget);
      expect(find.text('Front Delts'), findsOneWidget);

      expect(find.byType(MuscleBadge), findsNWidgets(4));
    });

    testWidgets(
      'renders only muscle group when primary/secondary muscles and equipment are empty',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            MusclesData(sizes: sizes, muscleGroup: MuscleGroup.legs),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🏋️‍♂️ Muscle Group'), findsOneWidget);
        expect(find.byType(MuscleGroupBadge), findsOneWidget);
        expect(find.text('💪 Primary Muscles'), findsNothing);
        expect(find.text('🥈 Secondary Muscles'), findsNothing);
        expect(find.text(' Equipment'), findsNothing);
        expect(find.byType(MuscleBadge), findsNothing);
      },
    );

    testWidgets('renders only primary data when secondary data is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MusclesData(
            sizes: sizes,
            muscleGroup: MuscleGroup.pull,
            primaryMuscles: const {Muscle.lats, Muscle.biceps},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🏋️‍♂️ Muscle Group'), findsOneWidget);
      expect(find.text('💪 Primary Muscles'), findsOneWidget);
      expect(find.text('Lats'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);
      expect(find.text('🥈 Secondary Muscles'), findsNothing);
      expect(find.text(' Equipment'), findsNothing);
    });

    testWidgets(
      'renders secondary muscles without equipment when equipment is empty',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            MusclesData(
              sizes: sizes,
              muscleGroup: MuscleGroup.core,
              secondaryMuscles: const {Muscle.abdominals},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🥈 Secondary Muscles'), findsOneWidget);
        expect(find.text('Abdominals'), findsOneWidget);
        expect(find.text(' Equipment'), findsNothing);
      },
    );

    testWidgets(
      'renders equipment without secondary muscles when secondary muscles is empty',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            MusclesData(
              sizes: sizes,
              muscleGroup: MuscleGroup.push,
              equipments: const [
                EquipmentDto(
                  id: 1,
                  name: 'Dumbbell',
                  createdBy: CreatedBy.system,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(' Equipment'), findsOneWidget);
        expect(find.text('Dumbbell'), findsOneWidget);
        expect(find.text('🥈 Secondary Muscles'), findsNothing);
      },
    );

    testWidgets(
      'fromTargetMuscles constructor maps muscles and exposes targetMuscles',
      (tester) async {
        const targetMuscles = TargetMuscles(
          primary: {Muscle.quadriceps},
          secondary: {Muscle.glutes, Muscle.calves},
        );

        final widget = MusclesData.fromTargetMuscles(
          sizes: sizes,
          muscleGroup: MuscleGroup.legs,
          muscles: targetMuscles,
        );

        expect(widget.primaryMuscles, equals(targetMuscles.primary));
        expect(widget.secondaryMuscles, equals(targetMuscles.secondary));
        expect(widget.targetMuscles, equals(targetMuscles));

        await tester.pumpWidget(buildTestableWidget(widget));
        await tester.pumpAndSettle();

        expect(find.text('💪 Primary Muscles'), findsOneWidget);
        expect(find.text('Quadriceps'), findsOneWidget);
        expect(find.text('🥈 Secondary Muscles'), findsOneWidget);
        expect(find.text('Glutes'), findsOneWidget);
        expect(find.text('Calves'), findsOneWidget);
      },
    );

    testWidgets('constrains max height to sizes.svgMaxHeight', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MusclesData(
            sizes: sizes,
            muscleGroup: MuscleGroup.push,
            primaryMuscles: const {Muscle.chest},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final constrainedBoxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((box) => box.constraints.maxHeight == sizes.svgMaxHeight);

      expect(constrainedBoxes, isNotEmpty);
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
            MusclesData(
              sizes: sizes,
              muscleGroup: MuscleGroup.push,
              primaryMuscles: const {
                Muscle.chest,
                Muscle.upperChest,
                Muscle.lowerChest,
              },
              secondaryMuscles: const {
                Muscle.triceps,
                Muscle.frontDelts,
                Muscle.sideDelts,
              },
              equipments: const [
                EquipmentDto(
                  id: 1,
                  name: 'Olympic Barbell',
                  createdBy: CreatedBy.system,
                ),
                EquipmentDto(
                  id: 2,
                  name: 'Adjustable Incline Bench',
                  createdBy: CreatedBy.system,
                ),
              ],
            ),
            textScaler: const TextScaler.linear(2.0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MusclesData), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('uses theme parameter when provided', (tester) async {
      final customTheme = ThemeData.dark();

      await tester.pumpWidget(
        buildTestableWidget(
          MusclesData(
            theme: customTheme,
            sizes: sizes,
            muscleGroup: MuscleGroup.pull,
            primaryMuscles: const {Muscle.lats},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final badge = tester.widget<MuscleBadge>(find.byType(MuscleBadge));
      expect(badge.theme, equals(customTheme));
    });

    testWidgets('renders multiple muscle groups properly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MusclesData(
            sizes: sizes,
            muscleGroups: const {MuscleGroup.push, MuscleGroup.pull},
            primaryMuscles: const {Muscle.chest, Muscle.lats},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🏋️‍♂️ Muscle Groups'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Pull'), findsOneWidget);
    });
  });
}
