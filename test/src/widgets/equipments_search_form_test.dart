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
import 'package:myfitnesstale/src/ui/core/widgets/created_by_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/favourite_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_form_button.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/equipments/equipments_search_form.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestWidget({
    String initialName = '',
    bool initialIsFavorite = false,
    CreatedBy? initialCreatedBy,
    required void Function({
      required String name,
      required bool isFavorite,
      required CreatedBy? createdBy,
    })
    onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Builder(
            builder: (context) => EquipmentsSearchForm(
              theme: Theme.of(context),
              sizes: sizes,
              isLoading: false,
              initialName: initialName,
              initialIsFavorite: initialIsFavorite,
              initialCreatedBy: initialCreatedBy,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders favorite, createdBy, search field, and submit button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required isFavorite, required createdBy}) {},
      ),
    );
    await tester.pump();

    expect(find.byType(HeartCheckbox), findsOneWidget);
    expect(find.byType(CreatedByCheckbox), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search Equipments...'), findsOneWidget);
    expect(find.byType(SearchFormButton), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('renders initial favorite and createdBy states', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialName: 'Bar',
        initialIsFavorite: true,
        initialCreatedBy: CreatedBy.user,
        onSubmit: ({required name, required isFavorite, required createdBy}) {},
      ),
    );
    await tester.pump();

    expect(find.text('Bar'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsNothing);
  });

  testWidgets('toggles favorite and createdBy filters and submits', (
    tester,
  ) async {
    String? submittedName;
    bool? submittedFavorite;
    CreatedBy? submittedCreatedBy = CreatedBy.system;

    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required isFavorite, required createdBy}) {
          submittedName = name;
          submittedFavorite = isFavorite;
          submittedCreatedBy = createdBy;
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(HeartCheckbox));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byType(CreatedByCheckbox));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Barbell');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SearchFormButton));
    await tester.pumpAndSettle();

    expect(submittedName, 'Barbell');
    expect(submittedFavorite, isTrue);
    expect(submittedCreatedBy, CreatedBy.user);

    await tester.tap(find.byType(HeartCheckbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CreatedByCheckbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SearchFormButton));
    await tester.pumpAndSettle();

    expect(submittedName, '');
    expect(submittedFavorite, isFalse);
    expect(submittedCreatedBy, isNull);
  });

  testWidgets('syncs updated initial props in didUpdateWidget', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialName: 'Initial',
        initialIsFavorite: false,
        initialCreatedBy: null,
        onSubmit: ({required name, required isFavorite, required createdBy}) {},
      ),
    );
    await tester.pump();

    expect(find.text('Initial'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    await tester.pumpWidget(
      buildTestWidget(
        initialName: 'Updated',
        initialIsFavorite: true,
        initialCreatedBy: CreatedBy.user,
        onSubmit: ({required name, required isFavorite, required createdBy}) {},
      ),
    );
    await tester.pump();

    expect(find.text('Updated'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('fits narrow phone with 200% text scaling', (tester) async {
    const phoneSize = Size(320, 568);
    final xsSizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
    await tester.binding.setSurfaceSize(phoneSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    bool? submittedFavorite;
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
                builder: (context) => EquipmentsSearchForm(
                  theme: Theme.of(context),
                  sizes: xsSizes,
                  isLoading: false,
                  initialName: '',
                  initialIsFavorite: false,
                  onSubmit:
                      ({
                        required name,
                        required isFavorite,
                        required createdBy,
                      }) {
                        submittedFavorite = isFavorite;
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
    await tester.tap(find.byType(HeartCheckbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CreatedByCheckbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SearchFormButton));
    await tester.pump();
    expect(submittedFavorite, isTrue);
    expect(submittedCreatedBy, CreatedBy.user);
    expect(tester.takeException(), isNull);
  });
}
