import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/meal_plan_cubit.dart';
import '../view_models/meal_plan_record_cubit.dart';
import '../view_models/states/meal_plan_state.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/search_favorite_form.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/meal_plan_list_item_widget.dart';

class MealPlanListScreen extends StatefulWidget {
  static const name = 'meal_plans';

  const MealPlanListScreen({super.key});

  @override
  State<MealPlanListScreen> createState() => _MealPlanListScreenState();
}

class _MealPlanListScreenState extends State<MealPlanListScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    final cubit = context.read<MealPlanCubit>();
    cubit.getMealPlans(
      search: cubit.state.mealPlanPagination.search,
      isFavorite: cubit.state.mealPlanPagination.isFavorite,
      limit: 50,
      offset: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Meal Plans',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<MealPlanCubit, MealPlanState>(
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
            return Column(
              children: [
                SearchFavoriteForm(
                  theme: theme,
                  nameLabel: 'meal plans',
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  isLoading: state.isLoading,
                  initialName: state.mealPlanPagination.search ?? '',
                  initialIsFavorite:
                      state.mealPlanPagination.isFavorite ?? false,
                  onSubmit: ({required String name, required bool isFavorite}) {
                    context.read<MealPlanCubit>().getMealPlans(
                      search: name.trim().isEmpty ? null : name.trim(),
                      isFavorite: isFavorite ? true : null,
                      limit: 50,
                      offset: 0,
                    );
                  },
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: state.isLoading && state.mealPlans.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : state.mealPlans.isEmpty
                      ? Center(
                          child: Text(
                            'No meal plans found.',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.mealPlans.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: sizes.spacing / 2),
                          itemBuilder: (context, index) {
                            final plan = state.mealPlans[index];

                            return MealPlanListItemWidget(
                              key: ValueKey('meal-plan-card-${plan.id}'),
                              plan: plan,
                              sizes: sizes,
                              onStart: () async {
                                final success = await context
                                    .read<MealPlanRecordCubit>()
                                    .startMealPlan(mealPlanId: plan.id);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Started meal plan: ${plan.name}',
                                        style: TextStyle(
                                          fontSize: sizes.fontSize,
                                        ),
                                      ),
                                      action: SnackBarAction(
                                        label: 'Tracker',
                                        onPressed: () {
                                          context.push(
                                            Routes.macroTracker.name,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              onView: () {
                                context.push(
                                  Routes.mealPlanDetails.name.replaceFirst(
                                    ':id',
                                    plan.id.toString(),
                                  ),
                                );
                              },
                              onToggleFavorite: () {
                                context.read<MealPlanCubit>().toggleFavorite(
                                  plan.id,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('meal-plan-add-fab'),
        onPressed: () {
          context.push(Routes.mealPlanCreation.name);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
