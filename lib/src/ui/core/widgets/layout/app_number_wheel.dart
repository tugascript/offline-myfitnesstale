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

import 'package:flutter/cupertino.dart';

class AppNumberWheel extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final double itemExtent;
  final double fontSize;
  final FixedExtentScrollController? scrollController;
  final ValueChanged<int>? onSelectedItemChanged;

  const AppNumberWheel({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.itemExtent,
    required this.fontSize,
    this.scrollController,
    this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(maxValue - minValue + 1, (i) => minValue + i);
    return CupertinoPicker(
      scrollController: scrollController,
      itemExtent: itemExtent,
      onSelectedItemChanged: onSelectedItemChanged,
      children: items
          .map(
            (v) => Center(
              child: Text(
                '$v',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
