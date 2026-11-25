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

import '../../../routing/routes.dart';
import '../../core/screens/entity_error_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../widgets/active/active_workout_plan_content.dart';

class ActiveWorkoutPlanScreen extends StatefulWidget {
  final int workoutPlanId;

  const ActiveWorkoutPlanScreen({super.key, required this.workoutPlanId});

  @override
  State<ActiveWorkoutPlanScreen> createState() =>
      _ActiveWorkoutPlanScreenState();
}

class _ActiveWorkoutPlanScreenState extends State<ActiveWorkoutPlanScreen> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<WorkoutPlanRecordCubit>();
        if (!cubit.state.isLoading &&
            cubit.state.currentPlanRecord.workoutPlan?.id !=
                widget.workoutPlanId) {
          cubit.getOrCreateActivePlanRecord(widget.workoutPlanId);
        }
      }
    });
  }

  void _confirmDeleteRecord(int recordId) {
    final cubit = context.read<WorkoutPlanRecordCubit>();
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete Workout Plan Record',
        content: 'Are you sure you want to delete this workout plan record? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          if (!mounted || _isDeleting) return;
          setState(() => _isDeleting = true);
          final deleted = await cubit.deleteWorkoutPlanRecord(recordId);
          if (!mounted) return;
          if (!deleted) {
            setState(() => _isDeleting = false);
            return;
          }
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(
              Routes.workoutPlanDetail.name.replaceFirst(
                ':id',
                widget.workoutPlanId.toString(),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
      listenWhen: (previous, current) =>
          current.error != null &&
          current.error != previous.error &&
          current.currentPlanRecord.workoutPlan != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!.description),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      },
      builder: (context, state) {
        final isBusy = state.isLoading || _isDeleting;
        final current = state.currentPlanRecord;
        final activeRecord = current.currentPlanRecord;

        if (current.workoutPlan == null && !isBusy) {
          return EntityErrorScreen(
            sizes: sizes,
            entityName: "Workout Plan",
            errorDescription: state.error?.description,
          );
        }

        return AppScaffold(
          title: "Active Workout Plan",
          isEntity: false,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ActiveWorkoutPlanContent(
              state: current,
              isLoading: isBusy,
              sizes: sizes,
              deleteButtonKey: const ValueKey(
                'active-workout-plan-record-delete',
              ),
              onDelete:
                  !isBusy &&
                      current.workoutPlan?.id == widget.workoutPlanId &&
                      activeRecord != null
                  ? () => _confirmDeleteRecord(activeRecord.id)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
