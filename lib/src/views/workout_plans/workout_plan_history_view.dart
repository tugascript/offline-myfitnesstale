import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../models/enums.dart';
import '../../services/dtos/workout_plan_record_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';

class WorkoutPlanHistoryView extends StatefulWidget {
  static const routeName = '/workout-plans/:id/history';

  final int workoutPlanId;

  const WorkoutPlanHistoryView({
    super.key,
    required this.workoutPlanId,
  });

  static String location(int workoutPlanId) =>
      routeName.replaceFirst(':id', workoutPlanId.toString());

  @override
  State<WorkoutPlanHistoryView> createState() => _WorkoutPlanHistoryViewState();
}

class _WorkoutPlanHistoryViewState extends State<WorkoutPlanHistoryView> {
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() {
    return context.read<WorkoutPlanRecordCubit>().getWorkoutPlanRecords(
          workoutPlanId: widget.workoutPlanId,
          limit: _pageSize,
          offset: 0,
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final cubit = context.read<WorkoutPlanRecordCubit>();
    final state = cubit.state;
    final isNearBottom = _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
    final hasMore = state.planRecords.length < state.pagination.total;

    if (isNearBottom && hasMore && !state.isLoading) {
      cubit.getWorkoutPlanRecords(
        workoutPlanId: widget.workoutPlanId,
        progressStatus: state.pagination.progressStatus,
        limit: state.pagination.limit,
        offset: state.planRecords.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return AppScaffold(
      title: 'Plan History',
      body: BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
        builder: (context, state) {
          if (state.isLoading && state.planRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.planRecords.isEmpty) {
            return _HistoryMessage(
              icon: Icons.error_outline,
              title: 'Could not load plan history',
              description: state.error!.description,
              action: ElevatedButton(
                onPressed: _loadFirstPage,
                child: const Text('Retry'),
              ),
            );
          }

          if (state.planRecords.isEmpty) {
            return const _HistoryMessage(
              icon: Icons.event_note_outlined,
              title: 'No Plan History',
              description: 'Start this plan to create its first history entry.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFirstPage,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(sizes.viewPadding),
              itemCount: state.planRecords.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.planRecords.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return _WorkoutPlanHistoryCard(
                  record: state.planRecords[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WorkoutPlanHistoryCard extends StatelessWidget {
  final WorkoutPlanRecordDto record;

  const _WorkoutPlanHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(record.status);
    final localDateFormat = DateFormat.yMMMd().add_jm();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(status.icon, color: status.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('Version ${record.workoutPlanVersion}'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Started: ${localDateFormat.format(record.startedAt.toLocal())}',
            ),
            if (record.completedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed: ${localDateFormat.format(record.completedAt!.toLocal())}',
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Last reached: Week ${record.currentWeek} • Day ${record.currentDay} • Workout ${record.currentWorkoutPosition}',
            ),
          ],
        ),
      ),
    );
  }
}

({String label, IconData icon, Color color}) _statusPresentation(
  ProgressStatus status,
) {
  return switch (status) {
    ProgressStatus.inProgress => (
        label: 'In Progress',
        icon: Icons.play_circle_outline,
        color: Colors.blue,
      ),
    ProgressStatus.completed => (
        label: 'Completed',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
    ProgressStatus.skipped => (
        label: 'Skipped',
        icon: Icons.skip_next_outlined,
        color: Colors.orange,
      ),
    ProgressStatus.abandoned => (
        label: 'Abandoned',
        icon: Icons.cancel_outlined,
        color: Colors.red,
      ),
  };
}

class _HistoryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
