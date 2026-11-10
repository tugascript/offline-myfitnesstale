import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/food_cubit.dart';
import '../view_models/states/food_state.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../widgets/food_form_widget.dart';
import '../../core/widgets/layout/app_scaffold.dart';

class FoodCreationScreen extends StatelessWidget {
  static const name = 'food_creation';

  const FoodCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<FoodCubit, FoodState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error!.description,
                style: TextStyle(fontSize: sizes.fontSize),
              ),
            ),
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
              onSubmit: (input) async {
                final success = await context.read<FoodCubit>().createFood(
                  input,
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
