import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/cubits/recipe_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/routing/routing.dart';
import 'package:myfitnesstale/src/services/dtos/recipe_dto.dart';
import 'package:myfitnesstale/src/views/recipes/recipe_details_view.dart';
import 'package:myfitnesstale/src/views/recipes/recipes_view.dart';
import 'package:myfitnesstale/src/ui/core/widgets/favourite_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_favorite_form.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_form_button.dart';

class _FakeRecipeCubit extends RecipeCubit {
  int? toggledRecipeId;
  String? lastSearch;
  bool? lastIsFavorite;

  _FakeRecipeCubit(List<RecipeDto> recipes) {
    emit(
      state.copyWith(
        recipes: recipes,
        selectedRecipe: recipes.isNotEmpty ? Nullable(recipes.first) : null,
      ),
    );
  }

  @override
  Future<void> getRecipes({
    String? search,
    bool isFavorite = false,
    int limit = 20,
    int offset = 0,
  }) async {
    lastSearch = search;
    lastIsFavorite = isFavorite;
  }

  @override
  Future<void> getRecipe(int id) async {
    final found = state.recipes.where((r) => r.id == id).firstOrNull;
    if (found != null) {
      emit(state.copyWith(selectedRecipe: Nullable(found)));
    }
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    toggledRecipeId = id;
    final updated = state.recipes.map((r) {
      if (r.id == id) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();
    final updatedSelected = state.selectedRecipe?.id == id
        ? state.selectedRecipe!.copyWith(
            isFavorite: !state.selectedRecipe!.isFavorite,
          )
        : null;
    emit(
      state.copyWith(
        recipes: updated,
        selectedRecipe: Nullable(updatedSelected),
      ),
    );
    return true;
  }
}

void main() {
  const testRecipe = RecipeDto(
    id: 42,
    name: 'Protein Oatmeal',
    servingsYield: 1,
    servingCalories: 350,
    servingProtein: 25,
    servingCarbs: 45,
    servingFat: 7,
    isFavorite: false,
    createdBy: CreatedBy.user,
  );

  testWidgets(
    'RecipesView renders SearchFavoriteForm and allows search with favorite filter',
    (tester) async {
      final cubit = _FakeRecipeCubit([testRecipe]);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: Routes.recipes.name,
        routes: [
          GoRoute(
            path: Routes.recipes.name,
            builder: (_, _) => const RecipesView(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<RecipeCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SearchFavoriteForm), findsOneWidget);
      expect(find.text('Protein Oatmeal'), findsOneWidget);

      // Toggle favorite filter in SearchFavoriteForm
      await tester.tap(find.byType(HeartCheckbox));
      await tester.pumpAndSettle();

      // Submit search
      await tester.tap(find.byType(SearchFormButton));
      await tester.pumpAndSettle();

      expect(cubit.lastIsFavorite, isTrue);
    },
  );

  testWidgets('RecipesView allows toggling favorite from list item', (
    tester,
  ) async {
    final cubit = _FakeRecipeCubit([testRecipe]);
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: Routes.recipes.name,
      routes: [
        GoRoute(
          path: Routes.recipes.name,
          builder: (_, _) => const RecipesView(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<RecipeCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // List item favorite button
    final itemHeart = find.descendant(
      of: find.byKey(const ValueKey('recipe-item-42')),
      matching: find.byType(IconButton),
    );
    expect(itemHeart, findsOneWidget);

    await tester.tap(itemHeart);
    await tester.pumpAndSettle();

    expect(cubit.toggledRecipeId, 42);
    expect(cubit.state.recipes.first.isFavorite, isTrue);
  });

  testWidgets('RecipeDetailsView allows toggling favorite', (tester) async {
    final cubit = _FakeRecipeCubit([testRecipe]);
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: '/recipes/42',
      routes: [
        GoRoute(
          path: Routes.recipeDetails.name,
          builder: (_, _) => const RecipeDetailsView(recipeId: 42),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<RecipeCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Servings: 1'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(cubit.toggledRecipeId, 42);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
