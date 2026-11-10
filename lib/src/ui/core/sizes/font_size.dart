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

class FontSize {
  static const double _scale = 14.0;

  static double get _xs => _scale * 0.8;

  static double get _sm => _scale * 0.9;

  static double get _md => _scale;

  static double get _lg => _scale * 1.15;

  static double get _xl => _scale * 1.30;

  static double getFontSize(ScreenSize screenSize) {
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
