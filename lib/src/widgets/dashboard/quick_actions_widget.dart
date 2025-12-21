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
              icon: Icons.fitness_center,
              title: "Start Workout",
              subtitle: "Begin a new session",
              color: Colors.blue,
              onTap: () {
                context.go(WorkoutsView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              icon: Icons.monitor_weight,
              title: "Log Weight",
              subtitle: "Track your progress",
              color: Colors.green,
              onTap: () {
                context.go(WeightLogView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              icon: Icons.flag,
              title: "Set Goal",
              subtitle: "Create weight goal",
              color: Colors.orange,
              onTap: () {
                context.go(WeightGoalView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              icon: Icons.fitness_center,
              title: "Browse Exercises",
              subtitle: "Find new exercises",
              color: Colors.purple,
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
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(sizes.radius),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: sizes.titleFontSize,
                color: color,
              ),
              SizedBox(height: sizes.breaks / 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 0.6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizes.breaks / 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize * 0.7,
                  color: Colors.grey[600],
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
