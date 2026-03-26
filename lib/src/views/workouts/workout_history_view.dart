import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/workout_record_state.dart';
import '../../cubits/states/workout_state.dart';
import '../../cubits/workout_cubit.dart';
import '../../cubits/workout_record_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workouts/progress/history/latest_workout_record.dart';
import '../../widgets/workouts/progress/history/single_workout_record_list.dart';

class WorkoutHistoryView extends StatefulWidget {
  static const routeName = '/workouts/:id/history';

  final int workoutId;

  const WorkoutHistoryView({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final workoutCubit = context.read<WorkoutCubit>();
    if (workoutCubit.state.selectedWorkout?.id != widget.workoutId) {
      workoutCubit.getWorkout(widget.workoutId);
    }

    final cubit = context.read<WorkoutRecordCubit>();
    final pagination = cubit.state.pagination;
    if (cubit.state.workoutRecords.isEmpty ||
        pagination.workoutId != widget.workoutId) {
      cubit.getWorkoutRecords(
        workoutId: widget.workoutId,
        limit: 20,
        offset: 0,
      );
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = context.read<WorkoutRecordCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.pagination.total > cubit.state.workoutRecords.length) {
        cubit.getWorkoutRecords(
          workoutId: widget.workoutId,
          limit: 20,
          offset: cubit.state.workoutRecords.length,
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, workoutState) {
        return ResponsiveScaffold(
          title: workoutState.selectedWorkout?.name ?? 'Workout History',
          isEntity: true,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final units = profileState.system?.units ?? Units.metric;
              return Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: BlocConsumer<WorkoutRecordCubit, WorkoutRecordState>(
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
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        LatestWorkoutRecord(
                          sizes: sizes,
                          theme: theme,
                          units: units,
                          workoutId: widget.workoutId,
                        ),
                        SizedBox(height: sizes.spacing * 2),
                        SizedBox(
                          height: breakpoints.height / 2.5,
                          child: SingleWorkoutRecordList(
                            sizes: sizes,
                            units: units,
                            isLoading: state.isLoading,
                            workoutRecords: state.workoutRecords,
                            pagination: state.pagination,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
