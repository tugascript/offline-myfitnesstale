import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/foods/food_search_form.dart';

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
