import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routing.dart';
import '../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/equipment_form.dart';

class EquipmentUpdateScreen extends StatefulWidget {
  static const String name = 'equipment_update';

  final int equipmentId;

  const EquipmentUpdateScreen({super.key, required this.equipmentId});

  @override
  State<EquipmentUpdateScreen> createState() => _EquipmentUpdateScreenState();
}

class _EquipmentUpdateScreenState extends State<EquipmentUpdateScreen> {
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!.description)));
        }
      },
      builder: (context, state) {
        final selectedEquipment = state.selectedEquipment;
        return ResponsiveScaffold(
          title: selectedEquipment?.equipment.name ?? "Update Equipment",
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
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
                    final existingPicture =
                        selectedEquipment?.equipment.picture;
                    context.read<ExerciseCubit>().updateEquipment(
                      widget.equipmentId,
                      EquipmentInput(
                        name: name,
                        picture: Nullable(
                          existingPicture != null
                              ? PictureData(
                                  uri: existingPicture.uri,
                                  storage: existingPicture.storage,
                                )
                              : null,
                        ),
                        isFavorite:
                            selectedEquipment?.equipment.isFavorite ?? false,
                      ),
                    );
                    if (context.mounted) {
                      if (state.error == null) {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }

                        context.go(Routes.equipments.name);
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
