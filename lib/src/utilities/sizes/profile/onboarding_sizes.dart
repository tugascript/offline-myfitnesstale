import '../screen_size.dart';

class OnboardingSizesList {
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
