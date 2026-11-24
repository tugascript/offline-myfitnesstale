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
import '../../../../data/repositories/macros/inputs/week_macro_goal_input.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_button.dart';
import '../../utils/macro_goal_form_defaults.dart';
import '../../view_models/macro_tracking_cubit.dart';
import './macro_goal_form.dart';

class MacroGoalFormModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MacroGoalDto? existingGoal;
  final MacroGoalFormDefaults? defaults;

  const MacroGoalFormModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.existingGoal,
    this.defaults,
  });

  @override
  State<MacroGoalFormModal> createState() => _MacroGoalFormModalState();
}

class _MacroGoalFormModalState extends State<MacroGoalFormModal> {
  bool _isSubmitting = false;
  bool _savedPendingRefresh = false;
  String? _submitError;

  Future<void> _handleSubmit(WeekMacroGoalInput input) async {
    if (_isSubmitting || _savedPendingRefresh) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final cubit = context.read<MacroTrackingCubit>();
    final existingGoal = widget.existingGoal;
    final MacroGoalSaveStatus status;
    try {
      status = existingGoal != null
          ? await cubit.updateMacroGoal(existingGoal.id, input)
          : await cubit.createMacroGoal(input);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) return;
    switch (status) {
      case MacroGoalSaveStatus.saved:
        Navigator.of(context).pop();
      case MacroGoalSaveStatus.savedRefreshFailed:
        setState(() {
          _savedPendingRefresh = true;
          _submitError =
              'Macro goal saved, but failed to refresh goals: '
              '${cubit.state.error?.description ?? 'Unknown error'}';
        });
      case MacroGoalSaveStatus.failed:
        setState(() {
          _submitError =
              cubit.state.error?.description ?? 'Failed to save macro goal';
        });
    }
  }

  Future<void> _handleReload() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final cubit = context.read<MacroTrackingCubit>();
    final bool refreshed;
    try {
      refreshed = await cubit.refreshMacroGoals();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) return;
    if (refreshed) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitError =
          'Macro goal saved, but failed to refresh goals: '
          '${cubit.state.error?.description ?? 'Unknown error'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendedNote = !_savedPendingRefresh && widget.existingGoal == null
        ? widget.defaults?.recommendedNote
        : null;

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: widget.theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(
          side: BorderSide(
            color: widget.theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        insetPadding: EdgeInsets.all(widget.sizes.margins),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.sizes.modalMaxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.sizes.padding * 2,
              horizontal: widget.sizes.padding,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: widget.sizes.spacing / 2,
                    runSpacing: widget.sizes.spacing / 2,
                    children: [
                      Text(
                        widget.existingGoal != null
                            ? 'Edit Macro Goal'
                            : 'Create Macro Goal',
                        style: TextStyle(
                          fontSize: widget.sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('macro-goal-modal-close-btn'),
                        tooltip: 'Close',
                        icon: Icon(
                          Icons.close,
                          size: widget.sizes.buttonIconSize,
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  if (recommendedNote != null) ...[
                    SizedBox(height: widget.sizes.halfSpacing),
                    Text(
                      recommendedNote,
                      key: const ValueKey('macro-goal-recommended-note'),
                      style: TextStyle(
                        fontSize: widget.sizes.smallFontSize,
                        color: widget.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (_submitError != null) ...[
                    SizedBox(height: widget.sizes.halfSpacing),
                    Text(
                      _submitError!,
                      key: const ValueKey('macro-goal-submit-error'),
                      style: TextStyle(
                        fontSize: widget.sizes.smallFontSize,
                        color: widget.theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  SizedBox(height: widget.sizes.spacing),
                  if (_savedPendingRefresh)
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: widget.sizes.spacing,
                      runSpacing: widget.sizes.halfSpacing,
                      children: [
                        AppTextButton(
                          key: const ValueKey('macro-goal-reload-close-btn'),
                          isLoading: _isSubmitting,
                          isSecondary: true,
                          sizes: widget.sizes,
                          onPressed: () => Navigator.of(context).pop(),
                          label: 'Close',
                          icon: Icons.close,
                        ),
                        AppElevatedButton(
                          key: const ValueKey('macro-goal-reload-button'),
                          theme: widget.theme,
                          isLoading: _isSubmitting,
                          sizes: widget.sizes,
                          onPressed: _handleReload,
                          label: 'Reload',
                          icon: Icons.refresh,
                        ),
                      ],
                    )
                  else
                    MacroGoalForm(
                      theme: widget.theme,
                      sizes: widget.sizes,
                      existingGoal: widget.existingGoal,
                      defaults: widget.defaults,
                      isLoading: _isSubmitting,
                      onSubmit: _handleSubmit,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
