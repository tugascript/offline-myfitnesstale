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

import '../../../core/sizes/data_display_sizes.dart';

class EmptySetsCard extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const EmptySetsCard({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding * 2),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: sizes.titleFontSize,
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
