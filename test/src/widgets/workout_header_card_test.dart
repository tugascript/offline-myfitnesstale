import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/data/utils/json_data.dart';
import '../../../lib/src/data/utils/enums.dart';
import '../../../lib/src/data/repositories/workouts/dtos/workout_dto.dart';
import '../../../lib/src/ui/core/sizes/data_display_sizes.dart';
import '../../../lib/src/ui/core/sizes/screen_size.dart';
import '../../../lib/src/ui/core/widgets/muscles_carousel.dart';
import '../../../lib/src/ui/workouts/widgets/details/workout_header_card.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestableWidget(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MediaQuery(
            data: MediaQueryData(
              textScaler: textScaler ?? const TextScaler.linear(1.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  const workoutDto = WorkoutDto(
    id: 1,
    name: 'Full Body Blast',
    difficulty: Difficulty.advanced,
    version: 1,
    isFavorite: false,
    totalSets: 12,
    totalReps: 120,
    editorType: EditorType.basic,
    createdBy: CreatedBy.system,
    muscleGroups: {MuscleGroup.push, MuscleGroup.pull},
    muscles: TargetMuscles(
      primary: {Muscle.chest, Muscle.lats},
      secondary: {Muscle.triceps, Muscle.biceps},
    ),
    description: 'A complete full body workout targeting major muscle groups.',
  );

  group('WorkoutHeaderCard widget tests', () {
    testWidgets('renders WorkoutHeaderCard with MusclesCarousel', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          WorkoutHeaderCard(
            sizes: sizes,
            workoutDto: workoutDto,
            actionButtonPress: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutHeaderCard), findsOneWidget);
      expect(find.byType(MusclesCarousel), findsOneWidget);
      expect(find.text('Version 1'), findsOneWidget);
      expect(find.textContaining('Sets'), findsOneWidget);
      expect(find.textContaining('Reps'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text(workoutDto.description!), findsOneWidget);

      // Verify carousel tabs
      expect(find.text('Diagram'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
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

        final xsSizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

        await tester.pumpWidget(
          buildTestableWidget(
            WorkoutHeaderCard(
              sizes: xsSizes,
              workoutDto: workoutDto,
              actionButtonPress: () {},
            ),
            textScaler: const TextScaler.linear(2.0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutHeaderCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
