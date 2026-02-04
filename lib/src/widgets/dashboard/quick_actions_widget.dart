import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/home_sizes.dart';
import '../../views/exercise_library_view.dart';
import '../../views/weight_goal_view.dart';
import '../../views/weight_log_view.dart';
import '../../views/workouts_view.dart';

class QuickActionsWidget extends StatelessWidget {
  final HomeSizesList sizes;

  const QuickActionsWidget({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: sizes.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.breaks / 3),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: sizes.breaks / 2,
          mainAxisSpacing: sizes.breaks / 2,
          childAspectRatio: 1.5,
          children: [
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Icon(
                Icons.flag,
                size: sizes.titleFontSize,
                color: Colors.orange,
              ),
              title: "Set Goal",
              subtitle: "Create weight goal",
              onTap: () {
                context.push(WeightGoalView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Icon(
                Icons.monitor_weight,
                size: sizes.titleFontSize,
                color: Colors.blue,
              ),
              title: "Log Weight",
              subtitle: "Log your weight",
              onTap: () {
                context.push(WeightLogView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Text(
                '🏋️',
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 0.9,
                ),
              ),
              title: "Workouts",
              subtitle: "Browse workouts",
              onTap: () {
                context.push(WorkoutsView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Text(
                '💪',
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 0.9,
                ),
              ),
              title: "Exercises",
              subtitle: "Browse exercises",
              onTap: () {
                context.push(ExerciseLibraryView.routeName);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final HomeSizesList sizes;
  final bool isDarkTheme;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.sizes,
    required this.isDarkTheme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: BeveledRectangleBorder(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: sizes.breaks / 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 0.6,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizes.breaks / 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize * 0.7,
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
