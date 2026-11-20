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

import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/exercise_record_cubit.dart';
import '../view_models/states/exercise_record_state.dart';
import '../widgets/progress/exercise_progress_history.dart';
import '../widgets/progress/latest_exercise_progress_record.dart';

class ExerciseProgressScreen extends StatefulWidget {
  const ExerciseProgressScreen({super.key});

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<ExerciseRecordCubit>();
    final dateRange = cubit.state.recordPagination.dateRange;
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: dateRange?.$1 ?? now.subtract(const Duration(days: 90)),
      end: dateRange?.$2 ?? now,
    );
  }

  Future<void> _openExerciseRecords(int exerciseId) async {
    await context.push<void>(
      Routes.exerciseRecords.name.replaceFirst(':id', exerciseId.toString()),
    );
    if (!mounted) {
      return;
    }

    final cubit = context.read<ExerciseRecordCubit>();
    await Future.wait([
      cubit.getLatestExerciseRecord(),
      cubit.getExerciseRecords(
        dateRange: (_dateRange.start, _dateRange.end),
        limit: ExerciseProgressHistory.pageSize,
        offset: 0,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return ResponsiveScaffold(
      title: 'Exercise Progress',
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final units = profileState.system?.units ?? Units.metric;

          return Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: BlocConsumer<ExerciseRecordCubit, ExerciseRecordState>(
              listenWhen: (previous, current) =>
                  current.error != null && current.error != previous.error,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LatestExerciseProgressRecord(
                      sizes: sizes,
                      theme: theme,
                      units: units,
                      onOpenExerciseRecords: _openExerciseRecords,
                    ),
                    SizedBox(height: sizes.spacing),
                    ExerciseProgressHistory(
                      theme: theme,
                      breakPoint: breakpoints,
                      sizes: sizes,
                      units: units,
                      dateRange: _dateRange,
                      onDateRangeChanged: (range) {
                        setState(() => _dateRange = range);
                      },
                      onOpenExerciseRecords: _openExerciseRecords,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
