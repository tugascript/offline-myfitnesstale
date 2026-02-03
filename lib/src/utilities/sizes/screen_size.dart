import 'package:flutter/material.dart';

enum ScreenSize {
  xl(1536),
  lg(1200),
  md(900),
  sm(600),
  xs(0);

  final int value;

  const ScreenSize(this.value);
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

  bool get lessSM => width < ScreenSize.sm.value;

  bool get lessMD => width < ScreenSize.md.value;

  bool get lessLG => width < ScreenSize.lg.value;

  bool get lessXL => width < ScreenSize.xl.value;

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
