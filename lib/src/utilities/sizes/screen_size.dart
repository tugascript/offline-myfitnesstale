import 'package:flutter/material.dart';

enum ScreenSize {
  xl,
  lg,
  md,
  sm,
  xs,
}

extension ScreenSizesExtension on ScreenSize {
  static const Map<ScreenSize, int> _values = {
    ScreenSize.xl: 1536,
    ScreenSize.lg: 1200,
    ScreenSize.md: 900,
    ScreenSize.sm: 600,
    ScreenSize.xs: 0,
  };

  int get value => _values[this]!;
}

class BreakPoint {
  final double _width;

  const BreakPoint(this._width);

  factory BreakPoint.fromContext(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return BreakPoint(width);
  }

  double get width => _width;

  bool get greatSM => width >= ScreenSize.sm.value;

  bool get greatMD => width >= ScreenSize.md.value;

  bool get greatLG => width >= ScreenSize.lg.value;

  bool get greatXL => width >= ScreenSize.xl.value;

  ScreenSize get screenSize {
    if (greatXL) {
      return ScreenSize.xl;
    } else if (greatLG) {
      return ScreenSize.lg;
    } else if (greatMD) {
      return ScreenSize.md;
    } else if (greatSM) {
      return ScreenSize.sm;
    } else {
      return ScreenSize.xs;
    }
  }
}
