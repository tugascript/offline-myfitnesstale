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

// TODO: add edit header
class WorkoutEditView extends StatefulWidget {
  static const name = "workout_edit";
  static const routeName = "/workouts/:id/edit";

  final int workoutId; // If provided, we're editing

  const WorkoutEditView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutEditView> createState() => _WorkoutEditViewState();
}

class _WorkoutEditViewState extends State<WorkoutEditView> {
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
              editor = _LockedPremiumEditor(
                isPurchasing: entitlementState.isPurchasing,
                isRestoring: entitlementState.isRestoring,
                onPurchase: () {
                  context.read<EntitlementCubit>().purchasePremium();
                },
                onRestore: () {
                  context.read<EntitlementCubit>().restorePurchases();
                },
              );
            }

            return ResponsiveScaffold(
              title: workout.name,
              showBackButton: false,
              isEntity: true,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkoutHeaderCard(
                    actionButtonIcon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
                    actionButtonPress: () {},
                    sizes: sizes,
                    workoutDto: workout,
                  ),
                  // Workout Sets
                  Padding(
                    padding: EdgeInsets.all(sizes.spacing / 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: sizes.spacing / 2),
                        Text(
                          'Sets',
                          style: TextStyle(
                            fontSize: sizes.titleFountSize,
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LockedPremiumEditor extends StatelessWidget {
  final bool isPurchasing;
  final bool isRestoring;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const _LockedPremiumEditor({
    required this.isPurchasing,
    required this.isRestoring,
    required this.onPurchase,
    required this.onRestore,
  });

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
              'This workout uses premium set types. Subscribe or restore your purchases to edit it.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isPurchasing ? null : onPurchase,
              child: isPurchasing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Subscribe to Premium'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: isRestoring ? null : onRestore,
              child: isRestoring
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restore Purchases'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }

                context.push("/workouts");
              },
              child: const Text('Back to Workouts'),
            ),
          ],
        ),
      ),
    );
  }
}
