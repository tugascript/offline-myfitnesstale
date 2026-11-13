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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/base_common_search_form.dart';
import 'package:myfitnesstale/src/ui/core/widgets/created_by_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/favourite_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_form_button.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestWidget({
    String nameLabel = 'Workouts',
    String initialName = '',
    Difficulty? initialDifficulty,
    MuscleGroup? initialMuscleGroup,
    bool initialIsFavorite = false,
    CreatedBy? initialCreatedBy,
    bool showMuscleGroup = true,
    bool showCreatedBy = true,
    required void Function({
      required String name,
      required Difficulty? difficulty,
      required MuscleGroup? muscleGroup,
      required int? equipmentId,
      required bool isFavourite,
      required CreatedBy? createdBy,
    })
    onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Builder(
            builder: (context) => BaseCommonSearchForm(
              theme: Theme.of(context),
              nameLabel: nameLabel,
              padding: sizes.padding,
              fontSize: sizes.fontSize,
              spacing: sizes.inputSpacing,
              isLoading: false,
              initialName: initialName,
              initialDifficulty: initialDifficulty,
              initialMuscleGroup: initialMuscleGroup,
              initialIsFavorite: initialIsFavorite,
              initialCreatedBy: initialCreatedBy,
              showMuscleGroup: showMuscleGroup,
              showCreatedBy: showCreatedBy,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders person icon button when showCreatedBy is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({
          required name,
          required difficulty,
          required muscleGroup,
          required equipmentId,
          required isFavourite,
          required createdBy,
        }) {},
      ),
    );
    await tester.pump();

    expect(find.byType(HeartCheckbox), findsOneWidget);
    expect(find.byType(CreatedByCheckbox), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(find.byTooltip('Filter by created by user'), findsOneWidget);
  });

  testWidgets('renders filled person icon when initialCreatedBy is user', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialCreatedBy: CreatedBy.user,
        onSubmit: ({
          required name,
          required difficulty,
          required muscleGroup,
          required equipmentId,
          required isFavourite,
          required createdBy,
        }) {},
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsNothing);
    expect(find.byTooltip('Show all items'), findsOneWidget);
  });

  testWidgets('toggles createdBy on person button tap and submits', (
    tester,
  ) async {
    CreatedBy? submittedCreatedBy = CreatedBy.system;

    await tester.pumpWidget(
      buildTestWidget(
        onSubmit:
            ({
              required name,
              required difficulty,
              required muscleGroup,
              required equipmentId,
              required isFavourite,
              required createdBy,
            }) {
              submittedCreatedBy = createdBy;
            },
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(CreatedByCheckbox));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person), findsOneWidget);

    await tester.tap(find.byType(SearchFormButton));
    await tester.pumpAndSettle();
    expect(submittedCreatedBy, CreatedBy.user);

    await tester.tap(find.byType(CreatedByCheckbox));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    await tester.tap(find.byType(SearchFormButton));
    await tester.pumpAndSettle();
    expect(submittedCreatedBy, isNull);
  });

  testWidgets('hides muscle group dropdown when showMuscleGroup is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        nameLabel: 'Plans',
        showMuscleGroup: false,
        onSubmit: ({
          required name,
          required difficulty,
          required muscleGroup,
          required equipmentId,
          required isFavourite,
          required createdBy,
        }) {},
      ),
    );
    await tester.pump();

    expect(find.text('All Difficulties'), findsOneWidget);
    expect(find.text('All Muscle Groups'), findsNothing);
    expect(find.byType(CreatedByCheckbox), findsOneWidget);
  });

  testWidgets('hides person button when showCreatedBy is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        showCreatedBy: false,
        onSubmit: ({
          required name,
          required difficulty,
          required muscleGroup,
          required equipmentId,
          required isFavourite,
          required createdBy,
        }) {},
      ),
    );
    await tester.pump();

    expect(find.byType(CreatedByCheckbox), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets(
    'fits narrow phone with 200% text scaling when createdBy and muscleGroup are shown',
    (tester) async {
      const phoneSize = Size(320, 568);
      final xsSizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
      await tester.binding.setSurfaceSize(phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CreatedBy? submittedCreatedBy;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: phoneSize,
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(xsSizes.viewPadding),
                child: Builder(
                  builder: (context) => BaseCommonSearchForm(
                    theme: Theme.of(context),
                    nameLabel: 'Workouts',
                    padding: xsSizes.padding,
                    fontSize: xsSizes.fontSize,
                    spacing: xsSizes.inputSpacing,
                    isLoading: false,
                    initialName: '',
                    initialDifficulty: null,
                    initialMuscleGroup: null,
                    initialIsFavorite: false,
                    showCreatedBy: true,
                    onSubmit:
                        ({
                          required name,
                          required difficulty,
                          required muscleGroup,
                          required equipmentId,
                          required isFavourite,
                          required createdBy,
                        }) {
                          submittedCreatedBy = createdBy;
                        },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(CreatedByCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SearchFormButton));
      await tester.pump();
      expect(submittedCreatedBy, CreatedBy.user);
      expect(tester.takeException(), isNull);
    },
  );
}
