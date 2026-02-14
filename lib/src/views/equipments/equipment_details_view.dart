import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/mutation_buttons.dart';
import '../../widgets/exercises/exercises_list.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../loading_view.dart';
import 'equipment_update_view.dart';

class EquipmentDetailsView extends StatefulWidget {
  static const routeName = '/equipments/:id';
  static const name = 'equipment_details';

  final int equipmentId;

  const EquipmentDetailsView({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsView> createState() => _EquipmentDetailsViewState();
}

class _EquipmentDetailsViewState extends State<EquipmentDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getEquipment(widget.equipmentId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

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
        if (state.isLoading && state.selectedEquipment == null) {
          return const LoadingView(
            title: "Equipment details",
            message: "Loading equipment details...",
          );
        }

        if (state.selectedEquipment == null) {
          return AppScaffold(
            title: "Unknown Equipment",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.error?.description ?? 'Equipment not found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final equipment = state.selectedEquipment!.equipment;
        final relatedExercises = state.selectedEquipment!.relatedExercises;
        return AppScaffold(
          title: equipment.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Exercises',
                  style: TextStyle(
                    fontSize: sizes.titleFountSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: ExercisesList(
                    theme: theme,
                    sizes: sizes,
                    isLoading: state.isLoading,
                    exercises: relatedExercises,
                  ),
                ),
                if (equipment.createdBy == CreatedBy.user) ...[
                  SizedBox(height: sizes.spacing),
                  MutationButtons(
                    isLoading: state.isLoading,
                    theme: theme,
                    sizes: sizes,
                    onEdit: () {
                      context.push(
                        EquipmentUpdateView.routeName.replaceFirst(
                          ':id',
                          equipment.id.toString(),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Delete ${equipment.name}',
                          content:
                              'Are you sure you want to delete this equipment? This action cannot be undone.',
                          onConfirm: () {
                            context
                                .read<ExerciseCubit>()
                                .deleteEquipment(equipment.id);
                            context.pop();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
