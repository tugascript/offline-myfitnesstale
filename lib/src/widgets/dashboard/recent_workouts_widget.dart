import 'package:flutter/material.dart';

class RecentWorkoutsWidget extends StatelessWidget {
  const RecentWorkoutsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Workouts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full workout history
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentWorkoutsList(),
      ],
    );
  }

  Widget _buildRecentWorkoutsList() {
    // TODO: Replace with actual workout data
    final recentWorkouts = <Map<String, dynamic>>[]; // Empty for now

    if (recentWorkouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No Recent Workouts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start your first workout to see your activity here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to workout selection
              },
              icon: const Icon(Icons.add),
              label: const Text("Start Workout"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentWorkouts.length,
      itemBuilder: (context, index) {
        final workout = recentWorkouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.fitness_center,
                color: Colors.blue[700],
              ),
            ),
            title: Text(workout['name'] ?? 'Unknown Workout'),
            subtitle: Text(workout['date'] ?? 'Unknown Date'),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
            onTap: () {
              // TODO: Navigate to workout details
            },
          ),
        );
      },
    );
  }
}
