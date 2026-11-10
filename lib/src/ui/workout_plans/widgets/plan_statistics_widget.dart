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

import 'package:flutter/material.dart';

import '../../core/sizes/data_display_sizes.dart';

class PlanStatisticsWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final int completedWorkouts;
  final int totalWorkouts;
  final double progressPercentage;
  final int completedWeeks;
  final int totalWeeks;
  final bool isDarkTheme;

  const PlanStatisticsWidget({
    super.key,
    required this.sizes,
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.progressPercentage,
    required this.completedWeeks,
    required this.totalWeeks,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final halfSpacing = sizes.spacing / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                '$completedWorkouts',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            SizedBox(width: halfSpacing),
            Expanded(
              child: _buildStatCard(
                context,
                'Total',
                '$totalWorkouts',
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: halfSpacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Remaining',
                '${totalWorkouts - completedWorkouts}',
                Icons.pending,
                Colors.orange,
              ),
            ),
            SizedBox(width: halfSpacing),
            Expanded(
              child: _buildStatCard(
                context,
                'Progress',
                '${progressPercentage.toStringAsFixed(1)}%',
                Icons.trending_up,
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: halfSpacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Weeks Completed',
                '$completedWeeks',
                Icons.date_range,
                Colors.purple,
              ),
            ),
            SizedBox(width: halfSpacing),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Weeks',
                '$totalWeeks',
                Icons.calendar_view_week,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final halfSpacing = sizes.spacing / 2;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: sizes.fontSize * 2),
                SizedBox(width: halfSpacing),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: isDarkTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: halfSpacing),
            Text(
              value,
              style: TextStyle(
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
