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

import '../../../../data/utils/enums.dart';
import '../../../core/utils/converters.dart';

class ExerciseRecordReps extends StatelessWidget {
  final Units units;
  final int reps;
  final int weight;
  final double fontSize;

  const ExerciseRecordReps({
    super.key,
    required this.units,
    required this.fontSize,
    required this.reps,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.repeat_one, size: fontSize * 1.2),
        Text(
          " $reps Reps ",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
        ),
        Icon(Icons.close, size: fontSize),
        Text(
          " ",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
        ),
        Icon(Icons.scale, size: fontSize * 1.2),
        Text(
          units == Units.imperial
              ? " ${Converters.gramsToLbs(weight).toStringAsFixed(2)} LBS"
              : " ${Converters.gramsToKg(weight).toStringAsFixed(2)} KG",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
