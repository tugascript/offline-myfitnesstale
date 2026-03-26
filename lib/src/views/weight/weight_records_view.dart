import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/weight/records/editor/create_weight_record_modal.dart';
import '../../widgets/weight/records/latest_weight_record.dart';
import '../../widgets/weight/records/weight_records_history.dart';

class WeightRecordsView extends StatelessWidget {
  static const routeName = "/weight-records";
  static const name = "weight-records";

  const WeightRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    return ResponsiveScaffold(
      title: "Weight Logs",
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return Column(
              children: [
                LatestWeightRecord(
                  sizes: sizes,
                  theme: theme,
                  units: state.system?.units ?? Units.metric,
                ),
                SizedBox(height: sizes.spacing * 2),
                WeightRecordsHistory(
                  theme: theme,
                  sizes: sizes,
                  breakPoint: breakpoints,
                  units: state.system?.units ?? Units.metric,
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateWeightRecordModal(
              theme: theme,
              sizes: sizes,
            ),
          );
        },
        child: Icon(
          Icons.add,
          size: sizes.buttonIconSize,
        ),
      ),
    );
  }
}
