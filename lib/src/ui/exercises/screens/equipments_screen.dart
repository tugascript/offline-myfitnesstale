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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/equipments_grid.dart';
import '../widgets/equipments_search_form.dart';

class EquipmentsScreen extends StatefulWidget {
  static const name = 'equipments';

  const EquipmentsScreen({super.key});

  @override
  State<EquipmentsScreen> createState() => _EquipmentsScreenState();
}

class _EquipmentsScreenState extends State<EquipmentsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.equipments.isEmpty) {
      final pagination = cubit.state.equipmentPagination;
      cubit.getEquipments(name: pagination.name, limit: 50, offset: 0);
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
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoints.screenSize);

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
