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

import './screen_size.dart';

class AppBarSizesList {
  final double height;
  final double title;
  final double icon;
  final double btnPadding;
  final double backBtnSize;

  const AppBarSizesList({
    required this.height,
    required this.title,
    required this.icon,
    required this.btnPadding,
    required this.backBtnSize,
  });

  factory AppBarSizesList.multiply(double x) => AppBarSizesList(
    height: 65.0 * x,
    title: 25.0 * x,
    icon: 50.0 * x,
    btnPadding: 10.0 * x,
    backBtnSize: 24.0 * x,
  );
}

class AppBarSizes {
  static AppBarSizesList get _xl => AppBarSizesList.multiply(1.3);

  static AppBarSizesList get _lg => AppBarSizesList.multiply(1.15);

  static AppBarSizesList get _md => AppBarSizesList.multiply(1.0);

  static AppBarSizesList get _sm => AppBarSizesList.multiply(0.9);

  static AppBarSizesList get _xs => AppBarSizesList.multiply(0.75);

  static AppBarSizesList getAppBarSizes(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.xl:
        return _xl;
      case ScreenSize.lg:
        return _lg;
      case ScreenSize.md:
        return _md;
      case ScreenSize.sm:
        return _sm;
      case ScreenSize.xs:
        return _xs;
    }
  }
}
