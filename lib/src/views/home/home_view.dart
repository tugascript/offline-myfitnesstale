import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/dashboard/active/active_plans_carousel.dart';
import '../../widgets/dashboard/progress_section.dart';
import '../../widgets/dashboard/quick_actions_widget.dart';
import '../../widgets/dashboard/welcome_section.dart';
import '../../widgets/layout/responsive_scaffold.dart';

class HomeView extends StatelessWidget {
  static const routeName = "/";
  static const name = "home";

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);

    return ResponsiveScaffold(
      title: "My Fitness Tale",
      showBackButton: false,
      body: Container(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            WelcomeSection(sizes: sizes),
            SizedBox(height: sizes.spacing),

            // Active workout and meal plans
            ActivePlansCarousel(theme: theme, sizes: sizes),
            SizedBox(height: sizes.spacing),

            // Quick Actions
            QuickActionsWidget(theme: theme, sizes: sizes),
            SizedBox(height: sizes.spacing),

            // Progress & Activity Section
            ProgressSection(sizes: sizes),
          ],
        ),
      ),
    );
  }
}
