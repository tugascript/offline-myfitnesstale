import '../../widgets/foods/food_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/food_cubit.dart';
import '../../cubits/states/food_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'food_creation_view.dart';
import 'food_details_view.dart';

class FoodsView extends StatefulWidget {
  static const routeName = '/foods';
  static const name = 'foods';

  const FoodsView({super.key});

  @override
  State<FoodsView> createState() => _FoodsViewState();
}

class _FoodsViewState extends State<FoodsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  FoodCategory? _selectedCategory;
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadFoods(reset: true);
    _scrollController.addListener(_onScroll);
  }

  void _loadFoods({bool reset = false}) {
    final cubit = context.read<FoodCubit>();
    final currentCount = reset ? 0 : cubit.state.foods.length;
    cubit.getFoods(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      category: _selectedCategory,
      isFavorite: _onlyFavorites ? true : null,
      offset: currentCount,
      limit: 30,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      final cubit = context.read<FoodCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.foodPagination.total > cubit.state.foods.length) {
        _loadFoods();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
        child: Column(
          children: [
            // Search Bar
            TextField(
              key: const ValueKey('foods-search-input'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: Icon(Icons.search, size: sizes.buttonIconSize),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: sizes.buttonIconSize),
                        onPressed: () {
                          _searchController.clear();
                          _loadFoods(reset: true);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadFoods(reset: true),
            ),
            SizedBox(height: sizes.spacing),
            // Filter row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    key: const ValueKey('foods-filter-favorites'),
                    label: Text('Favorites',
                        style: TextStyle(fontSize: sizes.fontSize)),
                    selected: _onlyFavorites,
                    onSelected: (val) {
                      setState(() {
                        _onlyFavorites = val;
                      });
                      _loadFoods(reset: true);
                    },
                  ),
                  SizedBox(width: sizes.spacing / 2),
                  ...FoodCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: sizes.padding / 2),
                      child: FilterChip(
                        label: Text(
                            cat.value[0].toUpperCase() + cat.value.substring(1),
                            style: TextStyle(fontSize: sizes.fontSize)),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = val ? cat : null;
                          });
                          _loadFoods(reset: true);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: sizes.spacing),
            // Foods List
            Expanded(
              child: BlocBuilder<FoodCubit, FoodState>(
                builder: (context, state) {
                  if (state.isLoading && state.foods.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
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
                    itemCount: state.foods.length + (state.isLoading ? 1 : 0),
                    separatorBuilder: (_, __) =>
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
                              FoodDetailsView.routeName
                                  .replaceFirst(':id', food.id.toString()),
                            );
                          },
                          onToggleFavorite: () {
                            context.read<FoodCubit>().toggleFavorite(food.id);
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
        key: const ValueKey('foods-add-fab'),
        onPressed: () {
          context.push(FoodCreationView.routeName);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
