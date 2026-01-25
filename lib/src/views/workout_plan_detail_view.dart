import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_plan_cubit.dart';
import '../cubits/states/workout_plan_state.dart';
import '../models/enums.dart';
import '../services/dtos/workout_dto.dart';
import '../services/dtos/workout_plan_dto.dart';
import '../models/workout_plan_day_model.dart';
import '../models/workout_plan_week_model.dart';
import '../models/workout_plan_workout_model.dart';
import '../services/current_workout_plan_record_service.dart';
import '../services/workout_plan_service.dart';
import '../services/workout_service.dart';
import '../widgets/layout/responsive_scaffold.dart';

class WorkoutPlanDetailView extends StatefulWidget {
  final int workoutPlanId;

  const WorkoutPlanDetailView({
    super.key,
    required this.workoutPlanId,
  });

  @override
  State<WorkoutPlanDetailView> createState() => _WorkoutPlanDetailViewState();
}

class _WorkoutPlanDetailViewState extends State<WorkoutPlanDetailView> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final WorkoutService _workoutService = WorkoutService();
  final CurrentWorkoutPlanRecordService _currentWorkoutPlanRecordService =
      CurrentWorkoutPlanRecordService();

  WorkoutPlanDto? _plan;
  List<WorkoutPlanWeek> _weeks = [];
  Map<int, List<WorkoutPlanDay>> _daysByWeek = {};
  Map<int, List<WorkoutPlanWorkout>> _workoutsByDay = {};
  final Map<int, WorkoutDto> _workoutCache = {};
  bool _isLoading = true;
  bool _isActive = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlanDetails();
    context.read<WorkoutPlanCubit>().getWorkoutPlan(widget.workoutPlanId);
  }

  Future<void> _loadPlanDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load plan
      final planResult =
          await _workoutPlanService.getWorkoutPlan(widget.workoutPlanId);
      if (planResult.isErr()) {
        setState(() {
          _error = 'Failed to load workout plan';
          _isLoading = false;
        });
        return;
      }
      final plan = planResult.value;

      // Check if plan is active
      final currentPlanResult =
          await _currentWorkoutPlanRecordService.getCurrentWorkoutPlanRecord();
      final isActive = currentPlanResult.isOk() &&
          currentPlanResult.value.workoutPlanId == widget.workoutPlanId;

      // Load weeks
      final weeks =
          await _workoutPlanService.getWorkoutPlanWeeks(widget.workoutPlanId);

      // Load days and workouts for each week
      final daysByWeek = <int, List<WorkoutPlanDay>>{};
      final workoutsByDay = <int, List<WorkoutPlanWorkout>>{};

      for (final week in weeks) {
        final days = await _workoutPlanService.getWorkoutPlanDays(
          workoutPlanId: widget.workoutPlanId,
          workoutPlanWeekId: week.id,
        );
        daysByWeek[week.id!] = days;

        for (final day in days) {
          final workouts = await _workoutPlanService.getWorkoutPlanWorkouts(
            workoutPlanId: widget.workoutPlanId,
            workoutPlanDayId: day.id,
          );
          workoutsByDay[day.id!] = workouts;

          // Pre-load workout details
          for (final planWorkout in workouts) {
            if (!_workoutCache.containsKey(planWorkout.workoutId)) {
              final workoutResult =
                  await _workoutService.getWorkout(planWorkout.workoutId);
              if (workoutResult.isOk()) {
                _workoutCache[planWorkout.workoutId] = workoutResult.value;
              }
            }
          }
        }
      }

      setState(() {
        _plan = plan;
        _weeks = weeks;
        _daysByWeek = daysByWeek;
        _workoutsByDay = workoutsByDay;
        _isActive = isActive;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.beginnerIntermediate:
        return Colors.lightGreen;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.intermediateAdvanced:
        return Colors.deepOrange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  String _dayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Day $day';
    }
  }

  Future<void> _startPlan() async {
    final success = await context
        .read<WorkoutPlanCubit>()
        .startWorkoutPlan(widget.workoutPlanId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout plan started successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: _plan?.name ?? 'Workout Plan',
      body: BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
        listener: (context, state) {
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
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null || _plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _error ?? 'Workout plan not found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final difficulty = Difficulty.fromValue(_plan!.difficulty);
          final difficultyColor = _difficultyColor(difficulty);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _plan!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: difficultyColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _difficultyLabel(difficulty),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_plan!.description != null &&
                            _plan!.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _plan!.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${_plan!.totalWeeks} ${_plan!.totalWeeks == 1 ? 'week' : 'weeks'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        if (_isActive) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                const Text(
                                  'This plan is currently active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!_isActive) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _startPlan,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Plan'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Weekly Breakdown
                Text(
                  'Weekly Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                ..._weeks.map((week) => _buildWeekCard(week, difficultyColor)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekCard(WorkoutPlanWeek week, Color difficultyColor) {
    final days = _daysByWeek[week.id] ?? [];
    final isExpanded =
        week.id == _weeks.first.id; // Expand first week by default

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(
          'Week ${week.startWeek}${week.endWeek > week.startWeek ? ' - ${week.endWeek}' : ''}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: days.map((day) => _buildDayCard(day)).toList(),
      ),
    );
  }

  Widget _buildDayCard(WorkoutPlanDay day) {
    final workouts = _workoutsByDay[day.id] ?? [];

    return ExpansionTile(
      title: Text(
        _dayName(day.day),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: workouts.map((planWorkout) {
        final workout = _workoutCache[planWorkout.workoutId];
        return _buildWorkoutCard(planWorkout, workout);
      }).toList(),
    );
  }

  Widget _buildWorkoutCard(
      WorkoutPlanWorkout planWorkout, WorkoutDto? workout) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.fitness_center,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        workout?.name ?? 'Unknown Workout',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        planWorkout.timeOfDay,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: workout != null
          ? () {
              context.push('/workouts/${workout.id}');
            }
          : null,
    );
  }
}
