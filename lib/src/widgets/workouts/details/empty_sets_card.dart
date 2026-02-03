import 'package:flutter/material.dart';

import '../../../utilities/sizes/workout_detail_sizes.dart';

class EmptySetsCard extends StatelessWidget {
  final WorkoutDetailSizesList sizes;

  const EmptySetsCard({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding * 2),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: sizes.titleFountSize,
                color: Colors.grey[400],
              ),
              SizedBox(height: sizes.spacing),
              Text(
                'No sets configured',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: sizes.spacing / 2),
              Text(
                'Add sets and exercises to this workout',
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
