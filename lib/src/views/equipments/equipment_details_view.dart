import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/edit_button.dart';
import '../../widgets/exercise/exercises_list.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../loading_view.dart';

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
    final sizes = DataDisplaySizes.getWorkoutDetailSizes(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Related Exercises',
                      style: TextStyle(
                        fontSize: sizes.titleFountSize,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                    if (equipment.createdBy == CreatedBy.user)
                      EditButton(
                        theme: theme,
                        sizes: sizes,
                        onPressed: () {},
                      ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: ExercisesList(
                    sizes: sizes,
                    isLoading: state.isLoading,
                    exercises: relatedExercises,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
