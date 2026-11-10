import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/ui/core/sizes/data_display_sizes.dart';
import '../../../lib/src/ui/core/sizes/screen_size.dart';
import '../../../lib/src/ui/core/widgets/favourite_checkbox.dart';
import '../../../lib/src/ui/core/widgets/search_favorite_form.dart';
import '../../../lib/src/ui/core/widgets/search_form_button.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  Widget buildTestWidget({
    String initialName = '',
    bool initialIsFavorite = false,
    bool isLoading = false,
    required void Function({required String name, required bool isFavorite})
    onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: SearchFavoriteForm(
            theme: ThemeData(),
            nameLabel: 'recipes',
            padding: sizes.padding,
            fontSize: sizes.fontSize,
            spacing: sizes.inputSpacing,
            isLoading: isLoading,
            initialName: initialName,
            initialIsFavorite: initialIsFavorite,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  testWidgets('renders search input, favorite heart, and submit button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(onSubmit: ({required name, required isFavorite}) {}),
    );
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search recipes...'), findsOneWidget);
    expect(find.byType(HeartCheckbox), findsOneWidget);
    expect(find.byType(SearchFormButton), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byTooltip('Filter favorite recipes'), findsOneWidget);
  });

  testWidgets('renders heart as filled when initially favorite', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialIsFavorite: true,
        onSubmit: ({required name, required isFavorite}) {},
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byTooltip('Show all recipes'), findsOneWidget);
  });

  testWidgets('toggles favorite heart on tap and submits', (tester) async {
    bool? submittedFavorite;
    String? submittedName;

    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required isFavorite}) {
          submittedName = name;
          submittedFavorite = isFavorite;
        },
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byType(HeartCheckbox));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pasta');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SearchFormButton));
    await tester.pumpAndSettle();

    expect(submittedName, 'Pasta');
    expect(submittedFavorite, isTrue);
  });

  testWidgets('submits form on keyboard submission', (tester) async {
    String? submittedName;
    await tester.pumpWidget(
      buildTestWidget(
        onSubmit: ({required name, required isFavorite}) {
          submittedName = name;
        },
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Curry');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submittedName, 'Curry');
  });

  testWidgets('clears search input with clear icon', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        initialName: 'Soup',
        onSubmit: ({required name, required isFavorite}) {},
      ),
    );
    await tester.pump();

    expect(find.text('Soup'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Soup'), findsNothing);
  });
}
