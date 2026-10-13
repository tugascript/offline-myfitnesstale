import '../../widgets/meal_plans/meal_plan_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/meal_plan_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../cubits/states/meal_plan_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../macros/macro_tracker_view.dart';
import 'meal_plan_creation_view.dart';
import 'meal_plan_details_view.dart';

class MealPlanListView extends StatefulWidget {
  static const routeName = '/meal-plans';
  static const name = 'meal_plans';

  const MealPlanListView({super.key});

  @override
  State<MealPlanListView> createState() => _MealPlanListViewState();
}

class _MealPlanListViewState extends State<MealPlanListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    context.read<MealPlanCubit>().getMealPlans(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          isFavorite: _onlyFavorites ? true : null,
          limit: 50,
          offset: 0,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Meal Plans',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('meal-plans-search-input'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meal plans...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPlans();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadPlans(),
            ),
            SizedBox(height: sizes.spacing),
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                key: const ValueKey('meal-plans-filter-favorites'),
                label: const Text('Favorites Only'),
                selected: _onlyFavorites,
                onSelected: (val) {
                  setState(() {
                    _onlyFavorites = val;
                  });
                  _loadPlans();
                },
              ),
            ),
            SizedBox(height: sizes.spacing),
            Expanded(
              child: BlocConsumer<MealPlanCubit, MealPlanState>(
                listener: (context, state) {
                  if (!state.isLoading && state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error!.description)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.mealPlans.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (state.mealPlans.isEmpty) {
                    return Center(
                      child: Text(
                        'No meal plans found.',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: state.mealPlans.length,
                    separatorBuilder: (_, __) =>
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
                                  content:
                                      Text('Started meal plan: ${plan.name}'),
                                  action: SnackBarAction(
                                    label: 'Tracker',
                                    onPressed: () {
                                      context.push(MacroTrackerView.routeName);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          onView: () {
                            context.push(
                              MealPlanDetailsView.routeName
                                  .replaceFirst(':id', plan.id.toString()),
                            );
                          },
                          onToggleFavorite: () {
                            context
                                .read<MealPlanCubit>()
                                .toggleFavorite(plan.id);
                          });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('meal-plan-add-fab'),
        onPressed: () {
          context.push(MealPlanCreationView.routeName);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
