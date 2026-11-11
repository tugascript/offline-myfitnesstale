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

import 'package:material_ui/material_ui.dart';

import '../../../../core/sizes/data_display_sizes.dart';
import '../editor/create_weight_goal_modal.dart';

class EmptyWeightGoal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const EmptyWeightGoal({super.key, required this.theme, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) =>
                  CreateWeightGoalModal(theme: theme, sizes: sizes),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sizes.padding * 2,
              horizontal: sizes.padding,
            ),
            child: Column(
              children: [
                Icon(Icons.scale, size: sizes.titleFontSize * 2),
                SizedBox(height: sizes.spacing),
                Text(
                  'No Weight Goal',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  'Create a weight goal',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
