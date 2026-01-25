import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_model.dart';

class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final bool isList;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    this.isList = false,
  });

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.beginnerIntermediate:
        return Colors.lightGreen;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.intermediateAdvanced:
        return Colors.deepOrange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = Difficulty.fromValue(plan.difficulty);
    final difficultyLabel = _difficultyLabel(difficulty);
    final difficultyColor = _difficultyColor(difficulty);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/workout-plans/${plan.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: isList ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: difficultyColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  difficultyLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: difficultyColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.totalWeeks} ${plan.totalWeeks == 1 ? 'week' : 'weeks'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (plan.description != null && plan.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description!,
                  style: TextStyle(
                    fontSize: isList ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: isList ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/workout-plans/${plan.id}');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

