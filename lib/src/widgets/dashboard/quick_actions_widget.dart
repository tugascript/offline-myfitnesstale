import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/equipments/equipments_view.dart';
import '../../views/exercises/exercises_view.dart';
import '../../views/weight/weight_goals_view.dart';
import '../../views/weight/weight_records_view.dart';
import '../../views/workouts/workouts_view.dart';

class QuickActionsWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;

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
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: sizes.margins,
          mainAxisSpacing: sizes.margins,
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
                context.push(WeightRecordsView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Text(
                '🏋️',
                style: TextStyle(fontSize: sizes.titleFontSize),
              ),
              title: "Workouts",
              subtitle: "Start a workout",
              onTap: () {
                context.push(WorkoutsView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Text(
                '💪',
                style: TextStyle(fontSize: sizes.titleFontSize),
              ),
              title: "Exercises",
              subtitle: "Explore exercises",
              onTap: () {
                context.push(ExercisesView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Icon(
                Icons.fitness_center,
                size: sizes.titleFontSize,
                color: Colors.green,
              ),
              title: "Equipments",
              subtitle: "Browse equipments",
              onTap: () {
                context.push(EquipmentsView.routeName);
              },
            ),
            _ActionCard(
              sizes: sizes,
              isDarkTheme: isDarkTheme,
              icon: Icon(
                Icons.notifications,
                size: sizes.titleFontSize,
                color: Colors.deepPurple,
              ),
              title: "Reminders",
              subtitle: "Set or update reminders",
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
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
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: sizes.spacing / 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizes.spacing / 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: sizes.fontSize,
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
