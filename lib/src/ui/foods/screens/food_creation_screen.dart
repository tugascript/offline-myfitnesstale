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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/food_cubit.dart';
import '../view_models/states/food_state.dart';
import '../widgets/food_form_widget.dart';

class FoodCreationScreen extends StatelessWidget {
  static const name = 'food_creation';

  const FoodCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return ResponsiveScaffold(
      title: 'Create Food',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.padding,
              vertical: sizes.padding * 2,
            ),
            child: BlocConsumer<FoodCubit, FoodState>(
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
                return FoodFormWidget(
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
