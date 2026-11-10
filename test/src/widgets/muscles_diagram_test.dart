import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/exercise_detail_view.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_diagram.dart';

class _StubExerciseCubit extends ExerciseCubit {
  _StubExerciseCubit(ExerciseDto exercise) {
    emit(state.copyWith(selectedExercise: Nullable(exercise)));
  }

  @override
  Future<void> getExercise(int id) async {}
}

void main() {
  late String rawSvg;
  late String rawFrontBackSvg;

  setUpAll(() {
    rawSvg = File(MusclesDiagram.assetPath).readAsStringSync();
    rawFrontBackSvg = File(MusclesDiagram.frontBackAssetPath)
        .readAsStringSync();
  });

  group('MusclesSvgLoader', () {
    test('maps every Muscle enum value to valid path IDs in muscles.svg and muscles-front-back.svg', () {
      for (final muscle in Muscle.values) {
        final regionIds = MusclesSvgLoader.muscleToSvgRegionIds[muscle];
        expect(
          regionIds,
          isNotNull,
          reason: 'Missing mapping for ${muscle.name}',
        );
        expect(regionIds, isNotEmpty);
        for (final id in regionIds!) {
          expect(
            rawSvg,
            contains('id="$id" fill="#616161"'),
            reason:
                'muscles.svg is missing path with id="$id" for ${muscle.name}',
          );
          expect(
            rawFrontBackSvg,
            contains('id="$id" fill="#454545"'),
            reason:
                'muscles-front-back.svg is missing path with id="$id" for ${muscle.name}',
          );
        }
      }
    });

    test('paints primary muscles dark and secondary muscles light with primary precedence on both SVGs', () {
      const muscles = TargetMuscles(
        primary: {Muscle.upperChest, Muscle.lats},
        secondary: {Muscle.chest, Muscle.triceps, Muscle.frontDelts},
      );

      final painted = MusclesSvgLoader.paintSvg(rawSvg, muscles: muscles);
      final paintedFrontBack = MusclesSvgLoader.paintSvg(
        rawFrontBackSvg,
        muscles: muscles,
      );
      final primaryHex = MusclesSvgLoader.colorToHex(
        MusclesDiagram.defaultPrimaryColor,
      );
      final secondaryHex = MusclesSvgLoader.colorToHex(
        MusclesDiagram.defaultSecondaryColor,
      );

      expect(painted, contains('id="chest" fill="$primaryHex"'));
      expect(painted, contains('id="lats" fill="$primaryHex"'));
      expect(painted, contains('id="triceps" fill="$secondaryHex"'));
      expect(painted, contains('id="front_delts" fill="$secondaryHex"'));
      expect(painted, contains('id="biceps" fill="#616161"'));

      expect(paintedFrontBack, contains('id="chest" fill="$primaryHex"'));
      expect(paintedFrontBack, contains('id="lats" fill="$primaryHex"'));
      expect(paintedFrontBack, contains('id="triceps" fill="$secondaryHex"'));
      expect(
        paintedFrontBack,
        contains('id="front_delts" fill="$secondaryHex"'),
      );
      expect(paintedFrontBack, contains('id="biceps" fill="#454545"'));
    });

    test(
      'produces distinct cacheKeys and compiled bytes when switching exercises',
      () async {
        const chestLoader = MusclesSvgLoader(
          muscles: TargetMuscles(
            primary: {Muscle.chest},
            secondary: {Muscle.triceps},
          ),
        );
        const legsLoader = MusclesSvgLoader(
          muscles: TargetMuscles(
            primary: {Muscle.quadriceps},
            secondary: {Muscle.calves},
          ),
        );

        expect(
          chestLoader.cacheKey(null),
          isNot(equals(legsLoader.cacheKey(null))),
        );

        final chestBytes = await chestLoader.loadBytes(null);
        final legsBytes = await legsLoader.loadBytes(null);

        expect(
          chestBytes.buffer.asUint8List(),
          isNot(equals(legsBytes.buffer.asUint8List())),
        );
      },
    );
  });

  group('MusclesDiagram & ExerciseDetailView widget tests', () {
    testWidgets(
      'renders MusclesDiagram in ExerciseDetailView at 320px width and 200% text scaling without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const exercise = ExerciseDto(
          id: 1,
          name: 'Incline Barbell Bench Press',
          description: 'Press the barbell upward from an incline bench.',
          muscleGroup: MuscleGroup.push,
          muscles: TargetMuscles(
            primary: {Muscle.upperChest, Muscle.chest},
            secondary: {Muscle.triceps, Muscle.frontDelts},
          ),
          equipments: [
            EquipmentDto(id: 1, name: 'Barbell', createdBy: CreatedBy.system),
          ],
          difficulty: Difficulty.intermediate,
          createdBy: CreatedBy.system,
        );

        final cubit = _StubExerciseCubit(exercise);
        addTearDown(cubit.close);

        await tester.pumpWidget(
          BlocProvider<ExerciseCubit>.value(
            value: cubit,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2.0)),
                child: child!,
              ),
              home: const ExerciseDetailView(exerciseId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MusclesDiagram), findsOneWidget);
        expect(find.byType(SvgPicture), findsWidgets);
        expect(find.text('Primary'), findsOneWidget);
        expect(find.text('Secondary'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('configures SvgPicture with MusclesSvgLoader', (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
      const muscles = TargetMuscles(
        primary: {Muscle.quadriceps},
        secondary: {Muscle.glutes, Muscle.calves},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => MusclesDiagram(
                muscles: muscles,
                sizes: sizes,
                theme: Theme.of(context),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.bytesLoader, isA<MusclesSvgLoader>());
      final loader = svgPicture.bytesLoader as MusclesSvgLoader;
      expect(loader.muscles, equals(muscles));
      expect(loader.primaryColor, equals(MusclesDiagram.defaultPrimaryColor));
      expect(
        loader.secondaryColor,
        equals(MusclesDiagram.defaultSecondaryColor),
      );
    });
  });
}
