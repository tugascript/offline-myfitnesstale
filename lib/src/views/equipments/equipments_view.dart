import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/equipment/equipments_grid.dart';
import '../../widgets/equipment/equipments_search_form.dart';
import '../../widgets/layout/app_scaffold.dart';

// TODO: delete this in favor of a modal
class EquipmentsView extends StatefulWidget {
  static const routeName = '/equipments';
  static const name = 'equipments';

  const EquipmentsView({super.key});

  @override
  State<EquipmentsView> createState() => _EquipmentsViewState();
}

class _EquipmentsViewState extends State<EquipmentsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.equipments.isEmpty) {
      final pagination = cubit.state.equipmentPagination;
      cubit.getEquipments(
        name: pagination.name,
        limit: 50,
        offset: 0,
      );
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = context.read<ExerciseCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.equipmentPagination.total >
              cubit.state.equipments.length) {
        final pagination = cubit.state.equipmentPagination;
        cubit.getEquipments(
          name: pagination.name,
          offset: cubit.state.equipments.length,
          limit: 50,
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
    final theme = Theme.of(context);
    final breakPoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakPoints.screenSize,
    );

    return AppScaffold(
      title: "Equipments",
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocBuilder<ExerciseCubit, ExerciseState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                EquipmentsSearchForm(
                  theme: theme,
                  sizes: sizes,
                  isLoading: state.isLoading,
                  initialName: state.equipmentPagination.name,
                  onSubmit: ({String? name}) {
                    context.read<ExerciseCubit>().getEquipments(
                          name: name,
                          limit: 50,
                          offset: 0,
                        );
                  },
                ),
                SizedBox(height: sizes.inputSpacing),
                Expanded(
                  child: EquipmentsGrid(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    equipments: state.equipments,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: sizes.buttonSize,
        height: sizes.buttonSize,
        child: FloatingActionButton(
          key: const ValueKey('equipment-add'),
          elevation: sizes.elevation,
          onPressed: () {
            context.push("/equipments/create");
          },
          shape: BeveledRectangleBorder(),
          child: Icon(Icons.add, size: sizes.buttonIconSize),
        ),
      ),
    );
  }
}
