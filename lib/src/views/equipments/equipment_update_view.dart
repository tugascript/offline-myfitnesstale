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

class EquipmentUpdateView extends StatefulWidget {
  static const String routeName = '/equipments/:id/update';
  static const String name = 'equipment_update';

  final int equipmentId;

  const EquipmentUpdateView({
    super.key,
    required this.equipmentId,
  });

  @override
  State<EquipmentUpdateView> createState() => _EquipmentUpdateViewState();
}

class _EquipmentUpdateViewState extends State<EquipmentUpdateView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();

    if (cubit.state.selectedEquipment?.equipment.id != widget.equipmentId) {
      cubit.getEquipment(widget.equipmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);
    final theme = Theme.of(context);

    return BlocConsumer<ExerciseCubit, ExerciseState>(
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        final selectedEquipment = state.selectedEquipment;
        return ResponsiveScaffold(
          title: selectedEquipment?.equipment.name ?? "Update Equipment",
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: Column(
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
                  initialName: selectedEquipment?.equipment.name ?? '',
                  isLoading: state.isLoading,
                  submitLabel: "UPDATE",
                  onSubmit: ({required String name}) {
                    context.read<ExerciseCubit>().updateEquipment(
                          id: widget.equipmentId,
                          name: name,
                        );
                    if (context.mounted) {
                      if (state.error == null) {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }

                        context.go(EquipmentsView.routeName);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
