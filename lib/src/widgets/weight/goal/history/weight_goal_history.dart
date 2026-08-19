import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../cubits/profile_cubit.dart';
import '../../../../cubits/states/profile_state.dart';
import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/weight_goal_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/not_found_list.dart';
import 'weight_goal_card.dart';

class WeightGoalHistory extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const WeightGoalHistory({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  State<WeightGoalHistory> createState() => _WeightGoalHistoryState();
}

class _WeightGoalHistoryState extends State<WeightGoalHistory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WeightRecordCubit>();

    if (cubit.state.weightGoals.isEmpty) {
      cubit.getWeightGoals(
        skipInProgress: true,
        offset: 0,
        limit: 20,
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
      final cubit = context.read<WeightRecordCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.goalPagination.total > cubit.state.weightGoals.length) {
        final pagination = cubit.state.goalPagination;
        cubit.getWeightGoals(
          skipInProgress: true,
          offset: cubit.state.weightGoals.length,
          limit: pagination.limit,
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
    return BlocBuilder<WeightRecordCubit, WeightRecordState>(
        builder: (context, weightState) {
      if (!weightState.isLoading && weightState.weightGoals.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weight Goals History",
              style: TextStyle(
                fontSize: widget.sizes.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: widget.sizes.spacing),
            Expanded(
              child: NotFoundList(
                sizes: widget.sizes,
                message: "Empty history",
                icon: Icons.history,
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: widget.sizes.spacing / 2,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "Weight Goals History",
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          SizedBox(height: widget.sizes.spacing),
          Expanded(
            child: Skeletonizer(
              enabled: weightState.isLoading && weightState.weightGoals.isEmpty,
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final stateIsLoading =
                      weightState.isLoading && weightState.weightGoals.isEmpty;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        stateIsLoading ? 3 : weightState.weightGoals.length,
                    itemBuilder: (context, index) {
                      if (stateIsLoading) {
                        return WeightGoalCard(
                          theme: widget.theme,
                          units: state.system?.units ?? Units.metric,
                          weightGoal: WeightGoalDto.empty(),
                          sizes: widget.sizes,
                        );
                      }

                      final weightGoal = weightState.weightGoals[index];
                      return WeightGoalCard(
                        theme: widget.theme,
                        units: state.system?.units ?? Units.metric,
                        weightGoal: weightGoal,
                        sizes: widget.sizes,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
