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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/exercise_details.dart';
import '../../../data/utils/json_data.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import '../widgets/equipments/edit_equipment_modal.dart';
import '../widgets/equipments/equipment_header_card.dart';
import '../widgets/exercises_list.dart';

const _skeletonEquipment = EquipmentDto(
  id: 0,
  name: 'Loading Equipment Name',
  rarity: EquipmentRarity.common,
  isFavorite: false,
  createdBy: CreatedBy.system,
);

const _skeletonExerciseOne = ExerciseDto(
  id: -1,
  name: 'Loading Exercise Name',
  description: '',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  difficulty: Difficulty.beginner,
  createdBy: CreatedBy.system,
);

const _skeletonExerciseTwo = ExerciseDto(
  id: -2,
  name: 'Loading Exercise Name',
  description: '',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.pull,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  difficulty: Difficulty.intermediate,
  createdBy: CreatedBy.system,
);

const _skeletonExerciseThree = ExerciseDto(
  id: -3,
  name: 'Loading Exercise Name',
  description: '',
  details: StrengthExerciseDetails(
    muscleGroup: MuscleGroup.legs,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    weightProgress: ExerciseWeightProgress.positive,
  ),
  difficulty: Difficulty.advanced,
  createdBy: CreatedBy.system,
);

const _skeletonSelectedEquipment = SelectedEquipment(
  equipment: _skeletonEquipment,
  relatedExercises: [
    _skeletonExerciseOne,
    _skeletonExerciseTwo,
    _skeletonExerciseThree,
  ],
);

class EquipmentDetailsScreen extends StatefulWidget {
  static const name = 'equipment_details';

  final int equipmentId;

  const EquipmentDetailsScreen({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getEquipment(widget.equipmentId);
  }

  void _toggleFavorite(bool isFavorite) {
    final cubit = context.read<ExerciseCubit>();
    if (cubit.state.isLoading) return;
    cubit.updateEquipmentFavorite(widget.equipmentId, !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<ExerciseCubit, ExerciseState>(
      listenWhen: (previous, current) =>
          (previous.selectedEquipment != current.selectedEquipment &&
              previous.isLoading != current.isLoading) ||
          (previous.error != current.error && current.error != null),
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
        final isSkeletonLoading =
            state.isLoading &&
            (state.selectedEquipment == null ||
                state.selectedEquipment!.equipment.id != widget.equipmentId);

        if (!isSkeletonLoading &&
            (state.selectedEquipment == null ||
                state.selectedEquipment!.equipment.id != widget.equipmentId)) {
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

        final selectedEquipment = isSkeletonLoading
            ? _skeletonSelectedEquipment
            : state.selectedEquipment!;
        final equipment = selectedEquipment.equipment;
        final relatedExercises = selectedEquipment.relatedExercises;
        return AppScaffold(
          title: isSkeletonLoading ? "Equipment details" : equipment.name,
          isEntity: !isSkeletonLoading,
          body: Skeletonizer(
            enabled: isSkeletonLoading,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EquipmentHeaderCard(
                              sizes: sizes,
                              equipment: equipment,
                              relatedExercisesCount: relatedExercises.length,
                              theme: theme,
                              onFavoriteToggle: () =>
                                  _toggleFavorite(equipment.isFavorite),
                            ),
                            SizedBox(height: sizes.spacing * 1.25),
                            Text(
                              'Related Exercises',
                              style: TextStyle(
                                fontSize: sizes.titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: isDarkTheme
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            ExercisesList(
                              theme: theme,
                              sizes: sizes,
                              isLoading: isSkeletonLoading
                                  ? false
                                  : state.isLoading,
                              exercises: relatedExercises,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              emptyHeight: sizes.buttonSize * 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (equipment.createdBy == CreatedBy.user) ...[
                      SizedBox(height: sizes.spacing),
                      MutationButtons(
                        isLoading: state.isLoading,
                        theme: theme,
                        sizes: sizes,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditEquipmentModal(
                              theme: theme,
                              sizes: sizes,
                              equipment: equipment,
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => ConfirmationDialog(
                              title: 'Delete ${equipment.name}',
                              content: 'Are you sure you want to delete this equipment? This action cannot be undone.',
                              onConfirm: () {
                                context.read<ExerciseCubit>().deleteEquipment(
                                  equipment.id,
                                );
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(Routes.equipments.name);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
