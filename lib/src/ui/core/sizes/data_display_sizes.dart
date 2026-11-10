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

import './screen_size.dart';

final class DataDisplaySizesList {
  final double padding;
  final double viewPadding;
  final double spacing;
  final double margins;
  final double titleFontSize;
  final double subtitleFontSize;
  final double fontSize;
  final double smallFontSize;

  final double inputSpacing;
  final double buttonSize;
  final double buttonIconSize;
  final double elevation;

  double get compactIconSize => buttonIconSize * 0.75;

  double get largeIconSize => buttonIconSize * 2.5;

  double get formFieldMinWidth => fontSize * 12;

  double get modalMaxWidth => buttonSize * 8;

  double get svgMaxHeight => buttonSize * 5;

  const DataDisplaySizesList({
    required this.padding,
    required this.viewPadding,
    required this.spacing,
    required this.margins,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.fontSize,
    required this.smallFontSize,
    required this.inputSpacing,
    required this.buttonSize,
    required this.buttonIconSize,
    required this.elevation,
  });
}

sealed class DataDisplaySizes {
  static const double _padding = 16;
  static const double _viewPadding = 10;
  static const double _spacing = 14;
  static const double _margins = 10;
  static const double _titleFontSize = 26;
  static const double _subtitleFontSize = 18;
  static const double _fontSize = 16;
  static const double _smallFontSize = 13;
  static const double _inputSpacing = 15;
  static const double _buttonSize = 65;
  static const double _buttonIconSize = 25;
  static const double _elevation = 2;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static DataDisplaySizesList _sizeByRatio(double ratio) =>
      DataDisplaySizesList(
        padding: _padding * ratio,
        viewPadding: _viewPadding * ratio,
        spacing: _spacing * ratio,
        margins: _margins * ratio,
        titleFontSize: _titleFontSize * ratio,
        subtitleFontSize: _subtitleFontSize * ratio,
        fontSize: _fontSize * ratio,
        smallFontSize: _smallFontSize * ratio,
        inputSpacing: _inputSpacing * ratio,
        buttonSize: _buttonSize * ratio,
        buttonIconSize: _buttonIconSize * ratio,
        elevation: _elevation * ratio,
      );

  static DataDisplaySizesList getDataDisplaySizes(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.xl:
        return _sizeByRatio(_xlRatio);
      case ScreenSize.lg:
        return _sizeByRatio(_lgRatio);
      case ScreenSize.md:
        return _sizeByRatio(_mdRatio);
      case ScreenSize.sm:
        return _sizeByRatio(_smRatio);
      case ScreenSize.xs:
        return _sizeByRatio(_xsRatio);
    }
  }
}
