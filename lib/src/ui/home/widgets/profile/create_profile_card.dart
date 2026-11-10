// Copyright (C) 2026 afonsobarracha
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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';

class CreateProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateProfileCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final DataDisplaySizesList sizes = DataDisplaySizes.getDataDisplaySizes(
      breakPoint.screenSize,
    );
    return Card(
      elevation: 1,
      margin: EdgeInsets.all(sizes.padding * 1.25),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding * 1.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your Fitness Tale starts here",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.titleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.spacing * 0.5),
              Text(
                "Please create your profile",
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(fontSize: sizes.subtitleFontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.spacing * 0.75),
              Icon(
                Icons.add,
                size: sizes.subtitleFontSize * 2.5,
                color: Theme.of(context).primaryColorLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
