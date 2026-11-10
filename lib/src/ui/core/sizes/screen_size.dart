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
  final double _height;

  const BreakPoint(this._width, this._height);

  factory BreakPoint.fromContext(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    return BreakPoint(width, height);
  }

  double get width => _width;

  double get height => _height;

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
