import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/food_cubit.dart';
import '../view_models/states/food_state.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routing.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../widgets/food_list_item_widget.dart';
import '../widgets/food_search_form.dart';
import '../../core/widgets/layout/app_scaffold.dart';

class FoodsView extends StatefulWidget {
  static const name = 'foods';

  const FoodsView({super.key});

  @override
  State<FoodsView> createState() => _FoodsViewState();
}

class _FoodsViewState extends State<FoodsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<FoodCubit>();
    final cubitState = cubit.state;

    if (cubitState.foods.isEmpty) {
      cubit.getFoods(
        search: cubitState.foodPagination.name.trim().isEmpty
            ? null
            : cubitState.foodPagination.name.trim(),
        category: cubitState.foodPagination.category,
        isFavorite: cubitState.foodPagination.isFavorite,
        limit: 30,
        offset: 0,
      );
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = context.read<FoodCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.foodPagination.total > cubit.state.foods.length) {
        final pagination = cubit.state.foodPagination;
        cubit.getFoods(
          search: pagination.name.trim().isEmpty
              ? null
              : pagination.name.trim(),
          category: pagination.category,
          isFavorite: pagination.isFavorite,
          offset: cubit.state.foods.length,
          limit: 30,
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Foods',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<FoodCubit, FoodState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error!.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                FoodSearchForm(
                  nameLabel: 'foods',
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  isLoading: state.isLoading,
                  initialName: state.foodPagination.name,
                  initialCategory: state.foodPagination.category,
                  initialIsFavorite: state.foodPagination.isFavorite,
                  onSubmit:
                      ({
                        required String name,
                        required FoodCategory? category,
                        required bool isFavorite,
                      }) {
                        context.read<FoodCubit>().getFoods(
                          search: name.trim().isEmpty ? null : name.trim(),
                          category: category,
                          isFavorite: isFavorite,
                          limit: 30,
                          offset: 0,
                        );
                      },
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading && state.foods.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.foods.isEmpty) {
                        return Center(
                          child: Text(
                            'No foods found.',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            state.foods.length + (state.isLoading ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            SizedBox(height: sizes.spacing / 2),
                        itemBuilder: (context, index) {
                          if (index >= state.foods.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(sizes.padding / 2),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }

                          final food = state.foods[index];
                          return FoodListItemWidget(
                            key: ValueKey('food-item-${food.id}'),
                            food: food,
                            sizes: sizes,
                            onTap: () {
                              context.push(
                                Routes.foodDetails.name.replaceFirst(
                                  ':id',
                                  food.id.toString(),
                                ),
                              );
                            },
                            onToggleFavorite: () {
                              context.read<FoodCubit>().toggleFavorite(food.id);
                            },
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
        key: const ValueKey('foods-add-fab'),
        onPressed: () {
          context.push(Routes.foodCreation.name);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
