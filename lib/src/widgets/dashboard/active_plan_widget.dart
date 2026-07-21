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

// TODO: fix this widget layout
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
          final currentPlanRecord = state.currentPlanRecord;

          if (currentPlanRecord.workoutPlan == null) {
            return EmptyActivePlan(sizes: widget.sizes);
          }

          final plan = currentPlanRecord.workoutPlan!;
          final progressFraction = currentPlanRecord.totalWorkouts == 0
              ? 0.0
              : currentPlanRecord.completedWorkouts /
                  currentPlanRecord.totalWorkouts;

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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: TextStyle(
                                  fontSize: widget.sizes.subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DifficultyBadge(
                              difficulty: plan.difficulty,
                              spacing: widget.sizes.spacing,
                              fontSize: widget.sizes.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
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
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '${(progressFraction * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: widget.sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            LinearProgressIndicator(
                              value: progressFraction,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            Text(
                              '${currentPlanRecord.completedWorkouts} of ${currentPlanRecord.totalWorkouts} workouts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (currentPlanRecord.todaysWorkouts.isNotEmpty) ...[
                          SizedBox(height: widget.sizes.spacing),
                          Container(
                            padding: EdgeInsets.all(widget.sizes.padding),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).primaryColor,
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
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        currentPlanRecord
                                            .todaysWorkouts.first.name,
                                        style: TextStyle(
                                          fontSize: widget.sizes.fontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: Theme.of(context).primaryColor,
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
