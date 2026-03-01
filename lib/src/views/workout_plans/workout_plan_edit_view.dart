import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfitnesstale/src/widgets/workout_plan/editor/workout_plan_header_edit_card.dart';

import '../../cubits/states/workout_plan_state.dart';
import '../../cubits/workout_plan_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/workout_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workout_plan/details/workout_plan_header.dart';
import '../../widgets/workout_plan/editor/weeks/workout_plan_weeks_editor.dart';

class WorkoutPlanEditView extends StatefulWidget {
  static const String name = 'workout_plan_edit';
  static const String routeName = '/workout-plans/:id/edit';

  final int workoutPlanId;

  const WorkoutPlanEditView({
    super.key,
    required this.workoutPlanId,
  });

  @override
  State<WorkoutPlanEditView> createState() => _WorkoutPlanEditViewState();
}

class _WorkoutPlanEditViewState extends State<WorkoutPlanEditView> {
  bool _isEditingHeader = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutPlanCubit>();

    if (cubit.state.selectedWorkoutPlan?.id != widget.workoutPlanId) {
      cubit.getWorkoutPlan(widget.workoutPlanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
    final theme = Theme.of(context);
    final isDarkTheme = theme.colorScheme.brightness == Brightness.dark;

    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        final plan = state.selectedWorkoutPlan;

        if (plan == null) {
          return const AppScaffold(
            title: "Edit Workout Plan",
            isEntity: true,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ResponsiveScaffold(
          title: plan.name,
          isEntity: true,
          showBackButton: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WorkoutPlanEditHeader(
                sizes: sizes,
                plan: plan,
                theme: theme,
                onCancel: () {
                  setState(() {
                    _isEditingHeader = false;
                  });
                },
                onSubmit: ({
                  String? description,
                  required Difficulty difficulty,
                  required bool isFavorite,
                  required String name,
                }) async {
                  await context.read<WorkoutPlanCubit>().updateWorkoutPlan(
                        id: plan.id,
                        name: name,
                        isFavorite: isFavorite,
                        difficulty: difficulty,
                        description: description,
                      );
                  if (mounted) {
                    setState(() {
                      _isEditingHeader = false;
                    });
                  }
                },
                onEdit: () {
                  setState(() {
                    _isEditingHeader = true;
                  });
                },
                isEditing: _isEditingHeader,
                isLoading: state.isLoading,
              ),
              SizedBox(height: sizes.spacing * 1.25),
              Padding(
                padding: EdgeInsets.all(sizes.spacing / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sizes.spacing / 2),
                    Text(
                      'Weekly Breakdown',
                      style: TextStyle(
                        fontSize: sizes.titleFountSize,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    WorkoutPlanWeeksEditor(
                      theme: theme,
                      sizes: sizes,
                      workoutPlanId: plan.id,
                      currentVersion: plan.currentVersion,
                      initialWeeks: plan.weeks ?? const [],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.description),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
    );
  }
}

class _WorkoutPlanEditHeader extends StatelessWidget {
  final WorkoutPlanDto plan;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onCancel;
  final void Function({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    String? description,
  }) onSubmit;

  final VoidCallback onEdit;
  final bool isEditing;
  final bool isLoading;

  const _WorkoutPlanEditHeader({
    required this.plan,
    required this.sizes,
    required this.theme,
    required this.onCancel,
    required this.onSubmit,
    required this.onEdit,
    required this.isEditing,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return WorkoutPlanHeader(
        actionButtonIcon: Icon(
          Icons.edit_outlined,
          color: theme.colorScheme.onSurface,
        ),
        actionButtonPress: onEdit,
        sizes: sizes,
        plan: plan,
      );
    }

    return WorkoutPlanHeaderEditCard(
      sizes: sizes,
      theme: theme,
      plan: plan,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
    );
  }
}
