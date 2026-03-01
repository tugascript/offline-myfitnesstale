import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/entitlement_cubit.dart';
import '../../../cubits/states/entitlement_state.dart';
import '../../../cubits/states/workout_plan_state.dart';
import '../../../cubits/workout_plan_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/entitlement_guard.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/mutation_button.dart';
import '../../layout/app_modal.dart';
import '../../layout/app_primary_button.dart';
import 'workout_plan_base_form.dart';

class CreateWorkoutPlanModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateWorkoutPlanModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  State<CreateWorkoutPlanModal> createState() => _CreateWorkoutPlanModalState();
}

class _CreateWorkoutPlanModalState extends State<CreateWorkoutPlanModal> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanCubit>().countCreatedWorkoutPlans();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntitlementCubit, EntitlementCubitState>(
      builder: (context, entitlementState) {
        final bool canUsePremium =
            EntitlementGuard.canUsePremium(entitlementState.snapshot);

        return AppModal(
          theme: widget.theme,
          sizes: widget.sizes,
          child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
            builder: (context, state) {
              if (!canUsePremium && state.createdWorkoutPlansCount >= 3) {
                return _LockedPremiumEditor(
                  theme: widget.theme,
                  sizes: widget.sizes,
                );
              }

              return WorkoutPlanBaseForm(
                theme: widget.theme,
                sizes: widget.sizes,
                isLoading: state.isLoading,
                submitLabel: "CREATE WORKOUT PLAN",
                initialName: "",
                initialIsFavorite: false,
                initialDifficulty: Difficulty.beginner,
                initialDescription: null,
                onSubmit: ({
                  required String name,
                  required bool isFavorite,
                  required Difficulty difficulty,
                  String? description,
                }) async {
                  await context.read<WorkoutPlanCubit>().createWorkoutPlan(
                        name: name,
                        isFavorite: isFavorite,
                        difficulty: difficulty,
                        description: description,
                      );
                  await Future.delayed(const Duration(milliseconds: 10));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final cubitState = context.read<WorkoutPlanCubit>().state;
                    if (cubitState.selectedWorkoutPlan != null) {
                      context.push(
                        "/workout-plans/${cubitState.selectedWorkoutPlan!.id}",
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _LockedPremiumEditor extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const _LockedPremiumEditor({
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "FREE WORKOUT PLANS LIMIT REACHED",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: sizes.spacing * 2),
          Text(
            "Free users can only create 3 workout plans.",
            style: TextStyle(
              fontSize: sizes.fontSize,
            ),
          ),
          SizedBox(height: sizes.spacing),
          Text(
            "Upgrade to premium to create unlimited workout plans",
            style: TextStyle(
              fontSize: sizes.fontSize,
            ),
          ),
          SizedBox(height: sizes.spacing),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              theme: theme,
              isLoading: false,
              icon: Icons.star,
              label: "UPGRADE TO PREMIUM",
              onPressed: () {
                Navigator.of(context).pop();
              },
              sizes: sizes,
            ),
          ),
          SizedBox(height: sizes.spacing),
          SizedBox(
            width: double.infinity,
            child: MutationButton(
              theme: theme,
              isLoading: false,
              icon: Icons.close,
              label: "NO THANKS",
              color: theme.colorScheme.onSurface,
              onPressed: () {
                Navigator.of(context).pop();
              },
              sizes: sizes,
            ),
          ),
        ],
      ),
    );
  }
}
