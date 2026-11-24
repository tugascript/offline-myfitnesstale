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
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/states/weight_record_state.dart';
import '../../view_models/weight_record_cubit.dart';
import './editor/edit_weight_record_modal.dart';
import './empty_weight_record.dart';
import './latest_weight_record_card.dart';

class LatestWeightRecord extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final Units units;

  const LatestWeightRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
  });

  @override
  State<LatestWeightRecord> createState() => _LatestWeightRecordState();
}

class _LatestWeightRecordState extends State<LatestWeightRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WeightRecordCubit>().getLatestRecordedWeightRecord();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeightRecordCubit, WeightRecordState>(
      builder: (context, state) {
        if (!state.isLoadingLatest && state.latestWeightRecord == null) {
          return EmptyWeightRecord(sizes: widget.sizes, theme: widget.theme);
        }

        return LatestWeightRecordCard(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoadingLatest,
          weightRecord: state.latestWeightRecord,
          onEdit: () {
            if (state.latestWeightRecord != null) {
              showDialog(
                context: context,
                builder: (context) => EditWeightRecordModal(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  units: widget.units,
                  record: state.latestWeightRecord!,
                ),
              );
            }
          },
        );
      },
    );
  }
}
