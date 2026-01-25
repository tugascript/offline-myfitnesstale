import 'package:flutter/material.dart';

import '../utilities/sizes/home_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/dashboard/active_plan_widget.dart';
import '../widgets/dashboard/quick_actions_widget.dart';
import '../widgets/dashboard/recent_workouts_widget.dart';
import '../widgets/dashboard/stats_overview_widget.dart';
import '../widgets/dashboard/welcome_section.dart';
import '../widgets/layout/responsive_scaffold.dart';

class HomeView extends StatelessWidget {
  static const routeName = "/";
  static const name = "home";

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = HomeSizes.getHomeSizes(breakPoint.screenSize);

    return ResponsiveScaffold(
      title: "My Fitness Tale",
      body: Container(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            WelcomeSection(sizes: sizes),
            SizedBox(height: sizes.breaks),

            // Active Plan
            ActivePlanWidget(sizes: sizes), // TODO: fix this widget
            SizedBox(height: sizes.breaks),

            // Quick Actions
            QuickActionsWidget(sizes: sizes),
            SizedBox(height: sizes.breaks),

            // // Stats Overview
            StatsOverviewWidget(sizes: sizes),
            SizedBox(height: sizes.breaks),

            // Recent Workouts
            const RecentWorkoutsWidget(), // TODO: fix this widget
          ],
        ),
      ),
    );
  }
}
