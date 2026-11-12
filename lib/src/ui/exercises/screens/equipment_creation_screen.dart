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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/equipment_form.dart';

class EquipmentCreationScreen extends StatelessWidget {
  static const String name = 'equipment_creation';

  const EquipmentCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      title: "Create Equipment",
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listenWhen: (previous, current) {
            return previous.selectedEquipment != current.selectedEquipment;
          },
          listener: (context, state) {
            if (state.isLoading) {
              return;
            }

            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!.description)));
            }

            if (state.selectedEquipment != null) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.equipments.name);
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                SizedBox(height: breakPoint.height * 0.2),
                Icon(
                  Icons.fitness_center,
                  size: sizes.titleFontSize * 4,
                  color: theme.primaryColor,
                ),
                SizedBox(height: sizes.spacing * 2),
                EquipmentForm(
                  theme: theme,
                  sizes: sizes,
                  initialName: '',
                  isLoading: state.isLoading,
                  submitLabel: "CREATE",
                  onSubmit: ({required String name}) {
                    final cubit = context.read<ExerciseCubit>();
                    cubit.createEquipment(EquipmentInput(name: name));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
