import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/equipment/equipment_form.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import 'equipments_view.dart';

class EquipmentCreationView extends StatelessWidget {
  static const String routeName = '/equipments/create';
  static const String name = 'equipment_creation';

  const EquipmentCreationView({super.key});

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!.description)),
              );
            }

            if (state.selectedEquipment != null) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(EquipmentsView.routeName);
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
                    cubit.createEquipment(name);
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
