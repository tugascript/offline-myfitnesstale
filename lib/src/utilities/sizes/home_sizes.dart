import 'screen_size.dart';

class HomeSizesList {
  final double padding;
  final double radius;
  final double titleFontSize;
  final double subtitleFontSize;
  final double sectionTitleFontSize;
  final double breaks;

  const HomeSizesList({
    required this.padding,
    required this.radius,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.sectionTitleFontSize,
    required this.breaks,
  });
}

sealed class HomeSizes {
  static const double _padding = 20;
  static const double _radius = 10;
  static const double _titleFoundSize = 30;
  static const double _subtitleFoundSize = 20;
  static const double _sectionTitleFoundSize = 25;
  static const double _breaks = 30;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static HomeSizesList _sizeByRatio(double ratio) => HomeSizesList(
        padding: _padding * ratio,
        radius: _radius * ratio,
        titleFontSize: _titleFoundSize * ratio,
        subtitleFontSize: _subtitleFoundSize * ratio,
        sectionTitleFontSize: _sectionTitleFoundSize * ratio,
        breaks: _breaks * ratio,
      );

  static HomeSizesList getHomeSizes(ScreenSize screenSize) {
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
