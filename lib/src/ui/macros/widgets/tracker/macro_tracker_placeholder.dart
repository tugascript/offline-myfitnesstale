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

import 'package:material_ui/material_ui.dart';

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_button.dart';

class MacroTrackerPlaceholder extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String? errorDescription;
  final bool isLoading;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateGoal;

  const MacroTrackerPlaceholder({
    super.key,
    required this.sizes,
    this.errorDescription,
    this.isLoading = false,
    this.onRetry,
    this.onCreateGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorDescription != null;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            minHeight: constraints.hasBoundedHeight
                ? constraints.maxHeight
                : 0.0,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  hasError ? Icons.error_outline : Icons.snooze,
                  size: sizes.doubleBtnIconSize,
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  hasError
                      ? 'Could not load macro goal'
                      : 'No Active Macro Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sizes.subtitleFontSize),
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  errorDescription ?? 'Set a daily macro goal (2000 kcal recommended) to start tracking your nutrition.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                if (hasError && onRetry != null) ...[
                  SizedBox(height: sizes.spacing),
                  AppElevatedButton(
                    key: const ValueKey('macro-tracker-retry-goal'),
                    theme: theme,
                    isLoading: isLoading,
                    sizes: sizes,
                    onPressed: onRetry,
                    label: 'Retry',
                    icon: Icons.refresh,
                  ),
                ] else if (onCreateGoal != null) ...[
                  SizedBox(height: sizes.spacing),
                  AppTextButton(
                    key: const ValueKey('macro-tracker-set-goal-btn'),
                    isLoading: isLoading,
                    sizes: sizes,
                    onPressed: onCreateGoal,
                    label: 'Set Macro Goal',
                    icon: Icons.flag_outlined,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
