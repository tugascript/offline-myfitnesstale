import 'screen_size.dart';

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
