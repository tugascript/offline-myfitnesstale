import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/food_cubit.dart';
import '../../cubits/states/food_state.dart';
import '../../models/common.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/foods/food_form_widget.dart';
import '../../widgets/layout/app_scaffold.dart';

class FoodCreationView extends StatelessWidget {
  static const routeName = '/foods/create';
  static const name = 'food_creation';

  const FoodCreationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<FoodCubit, FoodState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Create Food',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: FoodFormWidget(
              theme: theme,
              sizes: sizes,
              isLoading: state.isLoading,
              onSubmit: ({
                required name,
                brand,
                barcode,
                required category,
                required servingSizeBase,
                required caloriesBase,
                required proteinBase,
                required carbsBase,
                required fatBase,
                fiberBase,
                sodiumMg,
                required portions,
              }) async {
                final micros = sodiumMg != null
                    ? Micronutrients(sodiumMg: sodiumMg)
                    : null;
                final success = await context.read<FoodCubit>().createFood(
                      name: name,
                      brand: brand,
                      barcode: barcode,
                      category: category,
                      servingSizeBase: servingSizeBase,
                      caloriesBase: caloriesBase,
                      proteinBase: proteinBase,
                      carbsBase: carbsBase,
                      fatBase: fatBase,
                      fiberBase: fiberBase,
                      micros: micros,
                      portions: portions,
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
