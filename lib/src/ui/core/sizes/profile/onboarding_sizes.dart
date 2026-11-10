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

import '../screen_size.dart';

final class OnboardingSizesList {
  final double padding;
  final double marginTop;
  final double titleFontSize;
  final double subtitleFontSize;
  final double icon;
  final double breaks;
  final double formBreaks;

  const OnboardingSizesList({
    required this.padding,
    required this.marginTop,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.icon,
    required this.breaks,
    required this.formBreaks,
  });
}

sealed class OnboardingSizes {
  static const double _padding = 30;
  static const double _marginTop = 50;
  static const double _titleFontSize = 35;
  static const double _subtitleFontSize = 20;
  static const double _icon = 100;
  static const double _breaks = 15;
  static const double _formBreaks = 20;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static OnboardingSizesList _sizeByRatio(double ratio) => OnboardingSizesList(
    padding: _padding * ratio,
    marginTop: _marginTop * ratio,
    icon: _icon * ratio,
    breaks: _breaks * ratio,
    formBreaks: _formBreaks * ratio,
    titleFontSize: _titleFontSize * ratio,
    subtitleFontSize: _subtitleFontSize * ratio,
  );

  static OnboardingSizesList getOnboardingSizes(ScreenSize screenSize) {
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
