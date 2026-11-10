import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../models/enums.dart';
import '../../routing/routing.dart';
import '../../services/dtos/workout_plan_record_dto.dart';
import '../../ui/core/sizes/data_display_sizes.dart';
import '../../ui/core/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';

class WorkoutPlanHistoryView extends StatefulWidget {
  final int? workoutPlanId;

  const WorkoutPlanHistoryView({super.key, this.workoutPlanId});

  static String location([int? workoutPlanId]) => workoutPlanId != null
      ? '${Routes.workoutPlanHistory.name}?id=$workoutPlanId'
      : Routes.workoutPlanHistory.name;

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
    final isNearBottom =
        _scrollController.offset >=
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
      body: BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
        listenWhen: (previous, current) =>
            previous.error != current.error &&
            current.error != null &&
            current.planRecords.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!.description)));
        },
        builder: (context, state) {
          if (state.isLoading && state.planRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.planRecords.isEmpty) {
            return _HistoryMessage(
              sizes: sizes,
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
            return _HistoryMessage(
              sizes: sizes,
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
                  return Padding(
                    padding: EdgeInsets.all(sizes.padding),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return _WorkoutPlanHistoryCard(
                  record: state.planRecords[index],
                  sizes: sizes,
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
  final DataDisplaySizesList sizes;

  const _WorkoutPlanHistoryCard({required this.record, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(record.status);
    final localDateFormat = DateFormat.yMMMd().add_jm();

    return Card(
      margin: EdgeInsets.only(bottom: sizes.margins),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.workoutPlan != null) ...[
              Text(
                record.workoutPlan!.name,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: sizes.spacing / 2),
            ],
            Row(
              children: [
                Icon(status.icon, color: status.color),
                SizedBox(width: sizes.spacing / 2),
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
            SizedBox(height: sizes.spacing),
            Text(
              'Started: ${localDateFormat.format(record.startedAt.toLocal())}',
            ),
            if (record.completedAt != null) ...[
              SizedBox(height: sizes.spacing / 3),
              Text(
                'Completed: ${localDateFormat.format(record.completedAt!.toLocal())}',
              ),
            ],
            SizedBox(height: sizes.spacing / 2),
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
  final DataDisplaySizesList sizes;
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const _HistoryMessage({
    required this.sizes,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: sizes.largeIconSize, color: Colors.grey),
            SizedBox(height: sizes.spacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sizes.spacing / 2),
            Text(description, textAlign: TextAlign.center),
            if (action != null) ...[SizedBox(height: sizes.spacing), action!],
          ],
        ),
      ),
    );
  }
}
