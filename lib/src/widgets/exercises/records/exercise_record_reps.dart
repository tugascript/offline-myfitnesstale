import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../utilities/converters.dart';

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
        Icon(
          Icons.repeat_one,
          size: fontSize * 1.2,
        ),
        Text(
          " $reps Reps ",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(
          Icons.close,
          size: fontSize,
        ),
        Text(
          " ",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(
          Icons.scale,
          size: fontSize * 1.2,
        ),
        Text(
          units == Units.imperial
              ? " ${Converters.gramsToLbs(
                  weight,
                ).toStringAsFixed(2)} LBS"
              : " ${Converters.gramsToKg(
                  weight,
                ).toStringAsFixed(2)} KG",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
