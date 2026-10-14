import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_elevated_button.dart';

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
