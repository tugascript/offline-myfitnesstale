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

class CurrentWorkoutPlanPlaceholder extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String? errorDescription;
  final VoidCallback onRetry;
  final VoidCallback? onBrowsePlans;

  const CurrentWorkoutPlanPlaceholder({
    super.key,
    required this.sizes,
    required this.onRetry,
    this.onBrowsePlans,
    this.errorDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorDescription != null;
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              hasError ? Icons.error_outline : Icons.snooze,
              size: sizes.subtitleFontSize * 2,
            ),
            SizedBox(height: sizes.spacing),
            Text(
              hasError
                  ? 'Could not load current plan'
                  : 'No Active Workout Plan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: sizes.subtitleFontSize),
            ),
            SizedBox(height: sizes.spacing),
            Text(
              errorDescription ??
                  'Choose an existing plan or create a new one to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: sizes.fontSize),
            ),
            if (hasError) ...[
              SizedBox(height: sizes.spacing),
              AppElevatedButton(
                theme: theme,
                isLoading: false,
                sizes: sizes,
                onPressed: onRetry,
                label: 'Retry',
                icon: Icons.refresh,
              ),
            ] else if (onBrowsePlans != null) ...[
              SizedBox(height: sizes.spacing),
              SizedBox(
                width: double.infinity,
                child: AppElevatedButton(
                  key: const ValueKey('current-plan-browse-plans'),
                  theme: theme,
                  isLoading: false,
                  sizes: sizes,
                  onPressed: onBrowsePlans,
                  label: 'Browse Plans',
                  icon: Icons.book,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
