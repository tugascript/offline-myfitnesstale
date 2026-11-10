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

import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/foods/widgets/food_search_form.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestWidget({
    String initialName = '',
    FoodCategory? initialCategory,
    bool initialIsFavorite = false,
    bool isLoading = false,
    required void Function({
      required String name,
      required FoodCategory? category,
      required bool isFavorite,
    })
    onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: FoodSearchForm(
            padding: sizes.padding,
            fontSize: sizes.fontSize,
            spacing: sizes.inputSpacing,
            isLoading: isLoading,
            initialName: initialName,
            initialCategory: initialCategory,
            initialIsFavorite: initialIsFavorite,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  testWidgets('renders search input, favorite heart, and category dropdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required category, required isFavorite}) {},
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('foods-search-input')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('foods-filter-favorites')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('foods-filter-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('foods-search-button')), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byTooltip('Filter favorite foods'), findsOneWidget);
  });

  testWidgets('renders heart as filled when initially favorite', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialIsFavorite: true,
        onSubmit: ({required name, required category, required isFavorite}) {},
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byTooltip('Show all foods'), findsOneWidget);
  });

  testWidgets('toggles favorite heart on tap', (tester) async {
    bool? submittedFavorite;
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required category, required isFavorite}) {
          submittedFavorite = isFavorite;
        },
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('foods-filter-favorites')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('foods-search-button')));
    await tester.pumpAndSettle();

    expect(submittedFavorite, isTrue);
  });

  testWidgets('selects category from dropdown and submits', (tester) async {
    FoodCategory? submittedCategory;
    String? submittedName;

    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required category, required isFavorite}) {
          submittedName = name;
          submittedCategory = category;
        },
      ),
    );
    await tester.pump();

    // Enter search text
    await tester.enterText(
      find.byKey(const ValueKey('foods-search-input')),
      'Chicken',
    );
    await tester.pump();

    // Open category dropdown
    await tester.tap(find.byKey(const ValueKey('foods-filter-category')));
    await tester.pumpAndSettle();

    // Select Meat and Poultry
    await tester.tap(find.text('Meat and Poultry').last);
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.byKey(const ValueKey('foods-search-button')));
    await tester.pumpAndSettle();

    expect(submittedName, 'Chicken');
    expect(submittedCategory, FoodCategory.meatAndPoultry);
  });

  testWidgets('submits form on keyboard submission', (tester) async {
    String? submittedName;
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required category, required isFavorite}) {
          submittedName = name;
        },
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('foods-search-input')),
      'Salmon',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submittedName, 'Salmon');
  });

  testWidgets('clears search input with clear icon', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialName: 'Apples',
        onSubmit: ({required name, required category, required isFavorite}) {},
      ),
    );
    await tester.pump();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsNothing);
  });
}
