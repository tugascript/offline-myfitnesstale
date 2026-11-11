// Copyright (C) 2026 Afonso Barracha
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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/muscles_carousel.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/details/workout_header_card.dart';

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
