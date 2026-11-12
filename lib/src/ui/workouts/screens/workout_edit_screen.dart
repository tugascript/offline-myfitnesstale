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
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/workouts/inputs/workout_input.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../../../utils/nullable.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/states/workout_state.dart';
import '../view_models/workout_cubit.dart';
import '../widgets/details/advanced_editor/advanced_editor.dart';
import '../widgets/details/basic_editor/basic_editor.dart';
import '../widgets/details/workout_header_card.dart';
import '../widgets/details/workout_header_edit_card.dart';

class WorkoutEditScreen extends StatefulWidget {
  static const name = "workout_edit";

  final int workoutId;

  const WorkoutEditScreen({super.key, required this.workoutId});

  @override
  State<WorkoutEditScreen> createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  bool _isEditingHeader = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutCubit>();

    if (cubit.state.selectedWorkout?.id != widget.workoutId) {
      cubit.getWorkout(widget.workoutId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
    final theme = Theme.of(context);

    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final workout = state.selectedWorkout;

        if (workout == null) {
          return const AppScaffold(
            title: "Edit Workout",
            isEntity: true,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool hasComplexSets = (workout.sets ?? []).any(
          (set) => set.setType != WorkoutSetType.standard,
        );
        final bool useAdvancedEditor =
            workout.editorType == EditorType.advanced || hasComplexSets;

        final Widget editor = useAdvancedEditor
            ? AdvancedEditor(
                workoutId: widget.workoutId,
                initialSets: workout.sets ?? [],
              )
            : BasicEditor(
                workoutId: widget.workoutId,
                initialSets: workout.sets ?? [],
              );

        return ResponsiveScaffold(
          title: workout.name,
          showBackButton: false,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingHeader)
                  WorkoutHeaderEditCard(
                    theme: theme,
                    sizes: sizes,
                    workout: workout,
                    isLoading: state.isLoading,
                    onCancel: () {
                      setState(() {
                        _isEditingHeader = false;
                      });
                    },
                    onSubmit:
                        ({
                          required String name,
                          required bool isFavorite,
                          required Difficulty difficulty,
                          required EditorType editorType,
                          String? description,
                        }) async {
                          await context.read<WorkoutCubit>().updateWorkout(
                            workout.id,
                            WorkoutInput(
                              name: name,
                              isFavorite: isFavorite,
                              difficulty: difficulty,
                              editorType: editorType,
                              description: Nullable(description),
                              picture: Nullable(
                                workout.picture != null
                                    ? PictureData(
                                        uri: workout.picture!.uri,
                                        storage: workout.picture!.storage,
                                      )
                                    : null,
                              ),
                              video: Nullable(
                                workout.video != null
                                    ? VideoData(
                                        uri: workout.video!.uri,
                                        platform: workout.video!.platform,
                                      )
                                    : null,
                              ),
                              phase: Nullable(workout.phase),
                            ),
                          );

                          if (!mounted) return;

                          setState(() {
                            _isEditingHeader = false;
                          });
                        },
                  )
                else
                  WorkoutHeaderCard(
                    actionButtonIcon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
                    actionButtonPress: () {
                      setState(() {
                        _isEditingHeader = true;
                      });
                    },
                    sizes: sizes,
                    workoutDto: workout,
                  ),
                // Workout Sets
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sizes.spacing / 2),
                    Text(
                      'Sets',
                      style: TextStyle(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.brightness == Brightness.dark
                            ? Colors.grey[200]
                            : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    editor,
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
