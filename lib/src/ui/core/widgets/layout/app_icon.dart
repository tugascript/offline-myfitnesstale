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
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final String iconPath =
        'assets/icons/icon_${isLightTheme ? 'light' : 'dark'}.svg';

    return GestureDetector(
      child: SvgPicture.asset(
        iconPath,
        height: size,
        width: size,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            size: size * 0.6,
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
              debugPrint('Failed to load SVG icon: $iconPath - $exception');
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: size * 0.6,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
      ),
    );
  }
}
