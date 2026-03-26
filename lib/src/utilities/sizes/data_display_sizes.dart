import 'screen_size.dart';

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
  static const double _titleFontSize = 24;
  static const double _subtitleFontSize = 16;
  static const double _fontSize = 14;
  static const double _smallFontSize = 11;
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
