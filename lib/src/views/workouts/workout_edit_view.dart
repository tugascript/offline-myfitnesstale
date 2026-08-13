import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/entitlement_cubit.dart';
import '../../cubits/states/entitlement_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../models/enums.dart';
import '../../services/entitlement_guard.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/details/basic_editor/basic_editor.dart';
import '../../widgets/workouts/details/premium_editor/premium_editor.dart';
import '../../widgets/workouts/details/workout_header_card.dart';
import '../../widgets/workouts/details/workout_header_edit_card.dart';
import 'workouts_view.dart';

class WorkoutEditView extends StatefulWidget {
  static const name = "workout_edit";
  static const routeName = "/workouts/:id/edit";

  final int workoutId;

  const WorkoutEditView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutEditView> createState() => _WorkoutEditViewState();
}

class _WorkoutEditViewState extends State<WorkoutEditView> {
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

        return BlocBuilder<EntitlementCubit, EntitlementCubitState>(
          builder: (context, entitlementState) {
            final bool hasComplexSets = (workout.sets ?? [])
                .any((set) => set.setType != WorkoutSetType.standard);
            final bool canUsePremium =
                EntitlementGuard.canUsePremium(entitlementState.snapshot);
            final bool wantsPremiumEditor =
                workout.editorType == EditorType.advanced;

            Widget editor = BasicEditor(
              workoutId: widget.workoutId,
              initialSets: workout.sets ?? [],
            );

            if (wantsPremiumEditor && canUsePremium) {
              editor = PremiumEditor(
                workoutId: widget.workoutId,
                initialSets: workout.sets ?? [],
              );
            } else if (wantsPremiumEditor || hasComplexSets) {
              editor = const _LockedPremiumEditor();
            }

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
                        canUsePremiumEditor: canUsePremium,
                        isLoading: state.isLoading,
                        onCancel: () {
                          setState(() {
                            _isEditingHeader = false;
                          });
                        },
                        onSubmit: ({
                          required String name,
                          required bool isFavorite,
                          required Difficulty difficulty,
                          required EditorType editorType,
                          String? description,
                        }) async {
                          await context.read<WorkoutCubit>().updateWorkout(
                                id: workout.id,
                                name: name,
                                isFavorite: isFavorite,
                                difficulty: difficulty,
                                editorType: editorType,
                                description: description,
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
                            color:
                                theme.colorScheme.brightness == Brightness.dark
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
      },
    );
  }
}

class _LockedPremiumEditor extends StatelessWidget {
  const _LockedPremiumEditor();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Premium Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This workout uses advanced set types. Premium editing is unavailable in this build.',
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.go(WorkoutsView.routeName);
              },
              child: const Text('Back to Workouts'),
            ),
          ],
        ),
      ),
    );
  }
}
