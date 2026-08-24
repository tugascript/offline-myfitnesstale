import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../services/dtos/profile_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/difficulty_badge.dart';
import 'active_plan/empty_active_plan.dart';

class ActivePlanWidget extends StatefulWidget {
  final DataDisplaySizesList sizes;

  const ActivePlanWidget({
    super.key,
    required this.sizes,
  });

  @override
  State<ActivePlanWidget> createState() => _ActivePlanWidgetState();
}

class _ActivePlanWidgetState extends State<ActivePlanWidget> {
  bool _hasAttemptedLoad = false;

  @override
  void initState() {
    super.initState();
    // Check if profile is already loaded when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profileState = context.read<ProfileCubit>().state;
        if (profileState.profile != null && !profileState.isLoading) {
          _loadActivePlanIfNeeded(profileState.profile);
        }
      }
    });
  }

  void _loadActivePlanIfNeeded(ProfileDto? profile) {
    if (_hasAttemptedLoad || profile == null) {
      return;
    }

    final cubit = context.read<WorkoutPlanRecordCubit>();
    // Only load if not already loading and no plan exists
    if (!cubit.state.isLoading &&
        cubit.state.currentPlanRecord.workoutPlan == null) {
      _hasAttemptedLoad = true;
      // Load active plan record
      cubit.getLatestActivePlanRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, profileState) {
        // Load active plan when profile becomes available (only once)
        if (profileState.profile != null && !profileState.isLoading) {
          _loadActivePlanIfNeeded(profileState.profile);
        }
      },
      child: BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final currentPlanRecord = state.currentPlanRecord;

          if (currentPlanRecord.workoutPlan == null) {
            return EmptyActivePlan(sizes: widget.sizes);
          }

          final plan = currentPlanRecord.workoutPlan!;
          final rawProgress = currentPlanRecord.totalWorkouts == 0
              ? 0.0
              : currentPlanRecord.completedWorkouts /
                  currentPlanRecord.totalWorkouts;
          final progressFraction = rawProgress.clamp(0.0, 1.0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Workout Plan',
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: widget.sizes.spacing),
              Card(
                elevation: widget.sizes.elevation,
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: () {
                    context.push('/workout-plans/${plan.id}/active');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(widget.sizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final title = Text(
                              plan.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widget.sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                            final difficulty = DifficultyBadge(
                              difficulty: plan.difficulty,
                              spacing: widget.sizes.spacing,
                              fontSize: widget.sizes.fontSize,
                              fontWeight: FontWeight.w600,
                            );
                            if (constraints.maxWidth < 400) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  title,
                                  SizedBox(height: widget.sizes.spacing / 2),
                                  difficulty,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: title),
                                SizedBox(width: widget.sizes.spacing),
                                difficulty,
                              ],
                            );
                          },
                        ),
                        SizedBox(height: widget.sizes.spacing),
                        // Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: widget.sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${(progressFraction * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: widget.sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            LinearProgressIndicator(
                              value: progressFraction,
                              minHeight: 6,
                              backgroundColor: colors.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            Text(
                              '${currentPlanRecord.completedWorkouts} of ${currentPlanRecord.totalWorkouts} workouts',
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (currentPlanRecord.todaysWorkouts.isNotEmpty) ...[
                          SizedBox(height: widget.sizes.spacing),
                          Container(
                            padding: EdgeInsets.all(widget.sizes.padding),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: colors.onPrimaryContainer,
                                  size: widget.sizes.fontSize * 2,
                                ),
                                SizedBox(width: widget.sizes.spacing),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Today's Workout",
                                        style: TextStyle(
                                          fontSize: widget.sizes.smallFontSize,
                                          color: colors.onPrimaryContainer,
                                        ),
                                      ),
                                      Text(
                                        currentPlanRecord
                                            .todaysWorkouts.first.name,
                                        style: TextStyle(
                                          fontSize: widget.sizes.fontSize,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onPrimaryContainer,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: colors.onPrimaryContainer,
                                    size: widget.sizes.fontSize * 2,
                                  ),
                                  onPressed: () {
                                    context.push(
                                        '/workout-plans/${plan.id}/active');
                                  },
                                  tooltip: 'Start Workout',
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: widget.sizes.spacing),
                        TextButton.icon(
                          onPressed: () {
                            context.push('/workout-plans/${plan.id}');
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            size: widget.sizes.fontSize * 1.2,
                          ),
                          label: Text(
                            'View Plan Details',
                            style: TextStyle(
                              fontSize: widget.sizes.fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
