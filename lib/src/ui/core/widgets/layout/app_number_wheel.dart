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
