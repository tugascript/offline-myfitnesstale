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
import '../loading_view.dart';

class FoodUpdateView extends StatefulWidget {
  static const routeName = '/foods/:id/edit';
  static const name = 'food_update';

  final int foodId;

  const FoodUpdateView({super.key, required this.foodId});

  @override
  State<FoodUpdateView> createState() => _FoodUpdateViewState();
}

class _FoodUpdateViewState extends State<FoodUpdateView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FoodCubit>();
    if (cubit.state.selectedFood?.id != widget.foodId) {
      cubit.getFood(widget.foodId);
    }
  }

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
        if (state.isLoading && state.selectedFood == null) {
          return const LoadingView(
            title: 'Edit Food',
            message: 'Loading food...',
          );
        }

        final food = state.selectedFood;
        if (food == null) {
          return AppScaffold(
            title: 'Food Not Found',
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ),
          );
        }

        return AppScaffold(
          title: 'Edit ${food.name}',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: FoodFormWidget(
              theme: theme,
              sizes: sizes,
              initialFood: food,
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
                final success = await context.read<FoodCubit>().updateFood(
                      id: food.id,
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
