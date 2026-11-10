import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/recipe_cubit.dart';
import 'package:myfitnesstale/src/data/models/recipe_model.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();
  final service = RecipeRepository();

  setUp(database.initialize);
  tearDown(database.destroy);

  test('RecipeRepository toggleFavorite toggles favorite flag', () async {
    final db = await database.db;
    final id = await db.insert(
      Recipe.table,
      Recipe.create(
        name: 'Pancakes',
        servingsYield: 2,
        servingCalories: 400,
        servingProtein: 15,
        servingCarbs: 60,
        servingFat: 10,
        isFavorite: false,
      ).toMap(),
    );

    final res1 = await service.toggleFavorite(id);
    expect(res1.isOk(), isTrue);
    expect(res1.value.isFavorite, isTrue);

    final updatedRow1 = await db.query(
      Recipe.table,
      where: '${RecipeColumns.id.value} = ?',
      whereArgs: [id],
    );
    expect(updatedRow1.first[RecipeColumns.isFavorite.value], 1);

    final res2 = await service.toggleFavorite(id);
    expect(res2.isOk(), isTrue);
    expect(res2.value.isFavorite, isFalse);

    final updatedRow2 = await db.query(
      Recipe.table,
      where: '${RecipeColumns.id.value} = ?',
      whereArgs: [id],
    );
    expect(updatedRow2.first[RecipeColumns.isFavorite.value], 0);
  });

  test('RecipeRepository getRecipes filters by isFavorite', () async {
    final db = await database.db;
    await db.insert(
      Recipe.table,
      Recipe.create(
        name: 'Fav Recipe',
        servingsYield: 1,
        servingCalories: 200,
        servingProtein: 10,
        servingCarbs: 20,
        servingFat: 5,
        isFavorite: true,
      ).toMap(),
    );
    await db.insert(
      Recipe.table,
      Recipe.create(
        name: 'Non Fav Recipe',
        servingsYield: 1,
        servingCalories: 200,
        servingProtein: 10,
        servingCarbs: 20,
        servingFat: 5,
        isFavorite: false,
      ).toMap(),
    );

    final all = await service.getRecipes(isFavorite: false);
    expect(all.isOk(), isTrue);
    expect(all.value.data.length, 2);

    final favsOnly = await service.getRecipes(isFavorite: true);
    expect(favsOnly.isOk(), isTrue);
    expect(favsOnly.value.data.length, 1);
    expect(favsOnly.value.data.first.name, 'Fav Recipe');
  });

  test(
    'RecipeCubit toggleFavorite and getRecipes with isFavorite filter',
    () async {
      final db = await database.db;
      final id = await db.insert(
        Recipe.table,
        Recipe.create(
          name: 'Oatmeal',
          servingsYield: 1,
          servingCalories: 300,
          servingProtein: 10,
          servingCarbs: 50,
          servingFat: 5,
          isFavorite: false,
        ).toMap(),
      );

      final cubit = RecipeCubit();
      addTearDown(cubit.close);

      await cubit.getRecipes();
      expect(cubit.state.recipes.length, 1);
      expect(cubit.state.recipes.first.isFavorite, isFalse);

      final success = await cubit.toggleFavorite(id);
      expect(success, isTrue);
      expect(cubit.state.recipes.first.isFavorite, isTrue);

      // Filter by favorites
      await cubit.getRecipes(isFavorite: true);
      expect(cubit.state.recipePagination.isFavorite, isTrue);
      expect(cubit.state.recipes.length, 1);
      expect(cubit.state.recipePagination.total, 1);

      // Toggle back to not favorite while favorites filter is active
      await cubit.toggleFavorite(id);
      expect(cubit.state.recipes, isEmpty);
      expect(cubit.state.recipePagination.total, 0);
    },
  );
}
