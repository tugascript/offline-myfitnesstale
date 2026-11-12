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

import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/macro_tracking_cubit.dart';
import './macro_goal_form.dart';

class MacroGoalFormModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MacroGoalDto? existingGoal;

  const MacroGoalFormModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.existingGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      insetPadding: EdgeInsets.all(sizes.margins),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.modalMaxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: sizes.padding * 2,
            horizontal: sizes.padding,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existingGoal != null
                      ? 'Edit Macro Goal'
                      : 'Create Macro Goal',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                MacroGoalForm(
                  theme: theme,
                  sizes: sizes,
                  existingGoal: existingGoal,
                  onSubmit: (input) {
                    final cubit = context.read<MacroTrackingCubit>();
                    if (existingGoal != null) {
                      cubit.updateMacroGoal(existingGoal!.id, input);
                    } else {
                      cubit.createMacroGoal(input);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
