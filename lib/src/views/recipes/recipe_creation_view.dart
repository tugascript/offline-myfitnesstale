import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/recipe_cubit.dart';
import '../../cubits/states/recipe_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/recipes/recipe_form_widget.dart';

class RecipeCreationView extends StatelessWidget {
  static const routeName = '/recipes/create';
  static const name = 'recipe_creation';

  const RecipeCreationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<RecipeCubit, RecipeState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Create Recipe',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: RecipeFormWidget(
              theme: theme,
              sizes: sizes,
              isLoading: state.isLoading,
              onSubmit: ({
                required name,
                description,
                required servingsYield,
                required items,
              }) async {
                final success = await context.read<RecipeCubit>().createRecipe(
                      name: name,
                      description: description,
                      servingsYield: servingsYield,
                      items: items,
                    );
                if (success && context.mounted) {
                  context.pop();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
