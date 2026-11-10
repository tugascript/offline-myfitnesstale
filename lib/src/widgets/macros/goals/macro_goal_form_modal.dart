import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/macro_tracking_cubit.dart';
import '../../../services/dtos/macro_tracking_dto.dart';
import '../../../ui/core/sizes/data_display_sizes.dart';
import 'macro_goal_form.dart';

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
