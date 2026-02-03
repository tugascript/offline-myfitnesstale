import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../cubits/states/weight_record_state.dart';
import '../../cubits/weight_record_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/home_sizes.dart';

final class StatsOverviewWidget extends StatefulWidget {
  final HomeSizesList sizes;

  const StatsOverviewWidget({
    super.key,
    required this.sizes,
  });

  @override
  State<StatsOverviewWidget> createState() => _StatsOverviewWidgetState();
}

class _StatsOverviewWidgetState extends State<StatsOverviewWidget> {
  @override
  void initState() {
    super.initState();
    context.read<WeightRecordCubit>().getLatestRecordedWeightRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stats",
          style: TextStyle(
            fontSize: widget.sizes.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: widget.sizes.breaks / 3),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                sizes: widget.sizes,
                icon: Icons.fitness_center,
                title: "Weekly Workouts",
                value: "0",
                // TODO: Calculate from workout records
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: widget.sizes.breaks / 2),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => Row(
            children: [
              Expanded(
                child: _StatCard(
                  sizes: widget.sizes,
                  icon: Icons.person,
                  title: "Height",
                  value: state.profile != null
                      ? state.system?.units == Units.metric
                          ? "${state.profile!.height} cm"
                          : Converters.formatImperialHeight(
                              state.profile!.height,
                            )
                      : "Not set",
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: widget.sizes.breaks / 2),
              Expanded(
                child: BlocBuilder<WeightRecordCubit, WeightRecordState>(
                  buildWhen: (previous, current) =>
                      previous.latestWeightRecord != current.latestWeightRecord,
                  builder: (context, state2) => _StatCard(
                    sizes: widget.sizes,
                    icon: Icons.monitor_weight,
                    title: "Weight",
                    value: state2.latestWeightRecord != null
                        ? state.system?.units == Units.metric
                            ? Converters.formatMetricWeight(
                                state2.latestWeightRecord!.weight,
                              )
                            : Converters.formatImperialWeight(
                                state2.latestWeightRecord!.weight,
                              )
                        : "Not logged",
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final HomeSizesList sizes;
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.sizes,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: BeveledRectangleBorder(),
      child: Container(
        padding: EdgeInsets.all(sizes.padding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: sizes.titleFontSize,
                ),
                SizedBox(width: sizes.breaks / 3),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: sizes.breaks / 3),
            Text(
              value,
              style: TextStyle(
                fontSize: sizes.sectionTitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
