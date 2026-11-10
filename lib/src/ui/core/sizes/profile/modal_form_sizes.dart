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

import '../screen_size.dart';

class ModalFormSizesList {
  final double height;
  final double width;
  final double fontSize;
  final double iconSize;

  const ModalFormSizesList({
    required this.height,
    required this.width,
    required this.fontSize,
    required this.iconSize,
  });
}

sealed class ModalFormSizes {
  static const double _height = 80.0;
  static const double _fontSize = 20.0;
  static const double _iconSize = 22.0;

  static ModalFormSizesList _xl(double width) => ModalFormSizesList(
    height: _height * 1.3,
    width: width * 0.3,
    fontSize: _fontSize * 1.3,
    iconSize: _iconSize * 1.3,
  );

  static ModalFormSizesList _lg(double width) => ModalFormSizesList(
    height: _height * 1.15,
    width: width * 0.4,
    fontSize: _fontSize * 1.15,
    iconSize: _iconSize * 1.15,
  );

  static ModalFormSizesList _md(double width) => ModalFormSizesList(
    height: _height,
    width: width * 0.55,
    fontSize: _fontSize,
    iconSize: _iconSize,
  );

  static ModalFormSizesList _sm(double width) => ModalFormSizesList(
    height: _height * 0.9,
    width: width * 0.7,
    fontSize: _fontSize * 0.9,
    iconSize: _iconSize * 0.9,
  );

  static ModalFormSizesList _xs(double width) => ModalFormSizesList(
    height: _height * 0.75,
    width: width * 0.85,
    fontSize: _fontSize * 0.75,
    iconSize: _iconSize * 0.75,
  );

  static ModalFormSizesList getNavFormSizes(
    ScreenSize screenSize,
    double width,
  ) {
    switch (screenSize) {
      case ScreenSize.xl:
        return _xl(width);
      case ScreenSize.lg:
        return _lg(width);
      case ScreenSize.md:
        return _md(width);
      case ScreenSize.sm:
        return _sm(width);
      case ScreenSize.xs:
        return _xs(width);
    }
  }
}
