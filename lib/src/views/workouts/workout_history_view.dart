import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_record_state.dart';
import '../../cubits/workout_record_cubit.dart';
import '../../services/dtos/workout_dto.dart';
import '../../services/workout_service.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';

class WorkoutHistoryView extends StatefulWidget {
  static const routeName = '/workouts/history';

  final int? workoutId;

  const WorkoutHistoryView({
    super.key,
    this.workoutId,
  });

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  final Map<int, WorkoutDto> _workoutCache = {};
  final WorkoutService _workoutService = WorkoutService();

  @override
  void initState() {
    super.initState();
    _loadWorkoutRecords();
  }

  Future<void> _loadWorkoutRecords() {
    return context.read<WorkoutRecordCubit>().getWorkoutRecords(
          workoutId: widget.workoutId,
          limit: 50,
          offset: 0,
        );
  }

  Future<WorkoutDto?> _getWorkout(int workoutId) async {
    if (_workoutCache.containsKey(workoutId)) {
      return _workoutCache[workoutId];
    }

    final workoutResult = await _workoutService.getWorkout(workoutId);
    if (workoutResult.isOk()) {
      _workoutCache[workoutId] = workoutResult.value;
      return workoutResult.value;
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    if (recordDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _title() {
    return widget.workoutId == null ? 'All Workout History' : 'Workout History';
  }

  String _emptyTitle() {
    return widget.workoutId == null ? 'No Workout History' : 'No Records Yet';
  }

  String _emptySubtitle() {
    return widget.workoutId == null
        ? 'Complete some workouts to see your history here'
        : 'This workout does not have any saved records yet';
  }

  String _statusLabel(bool isCompleted) {
    return isCompleted ? 'Completed' : 'In Progress';
  }

  Color _statusColor(ThemeData theme, bool isCompleted) {
    return isCompleted ? Colors.green : theme.colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );
    final iconSize = sizes.buttonIconSize;

    return AppScaffold(
      title: _title(),
      body: BlocConsumer<WorkoutRecordCubit, WorkoutRecordState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!.description),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.workoutRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.workoutRecords.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(sizes.padding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: iconSize * 1.6,
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.75),
                      ),
                      SizedBox(height: sizes.spacing),
                      Text(
                        _emptyTitle(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: sizes.spacing / 2),
                      Text(
                        _emptySubtitle(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWorkoutRecords,
            child: ListView(
              padding: EdgeInsets.all(sizes.padding / 2),
              children: state.workoutRecords.map((record) {
                return FutureBuilder<WorkoutDto?>(
                  future: _getWorkout(record.workoutId),
                  builder: (context, snapshot) {
                    final workout = snapshot.data;
                    final isCompleted = record.completedAt != null;
                    final statusColor = _statusColor(theme, isCompleted);

                    return Container(
                      margin: EdgeInsets.only(bottom: sizes.spacing),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: theme.colorScheme.surface,
                        child: InkWell(
                          onTap: () {
                            context.push('/workout-records/${record.id}');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(sizes.padding * 0.9),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: iconSize * 2,
                                      height: iconSize * 2,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.12),
                                      ),
                                      child: Icon(
                                        Icons.fitness_center,
                                        color: theme.colorScheme.primary,
                                        size: iconSize,
                                      ),
                                    ),
                                    SizedBox(width: sizes.spacing),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            workout?.name ?? 'Unknown Workout',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: sizes.spacing / 2),
                                          Text(
                                            _formatDate(record.startedAt),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                SizedBox(height: sizes.spacing),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sizes.spacing * 0.9,
                                    vertical: sizes.spacing * 0.55,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: iconSize * 0.8,
                                        color: statusColor,
                                      ),
                                      SizedBox(width: sizes.spacing / 2),
                                      Text(
                                        _statusLabel(isCompleted),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
