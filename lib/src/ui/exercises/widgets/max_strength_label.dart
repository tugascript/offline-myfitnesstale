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

import '../../../data/utils/enums.dart';
import '../../core/utils/converters.dart';

class MaxStrengthLabel extends StatelessWidget {
  final Units units;
  final int maxStrength;
  final double fontSize;

  const MaxStrengthLabel({
    super.key,
    required this.units,
    required this.maxStrength,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isMetric = units == Units.metric;
    final weightUnit = isMetric ? 'KG' : 'LBS';
    final maxStrengthValue = isMetric
        ? Converters.gramsToKg(maxStrength).toStringAsFixed(2)
        : Converters.gramsToLbs(maxStrength).toStringAsFixed(2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💪', style: TextStyle(fontSize: fontSize * 1.15)),
        Text(
          ' $maxStrengthValue $weightUnit',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
