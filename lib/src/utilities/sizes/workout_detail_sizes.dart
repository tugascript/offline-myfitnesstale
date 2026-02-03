import 'screen_size.dart';

final class WorkoutDetailSizesList {
  final double padding;
  final double spacing;
  final double titleFountSize;
  final double subtitleFontSize;
  final double fontSize;
  final double smallFontSize;

  const WorkoutDetailSizesList({
    required this.padding,
    required this.spacing,
    required this.titleFountSize,
    required this.subtitleFontSize,
    required this.fontSize,
    required this.smallFontSize,
  });
}

sealed class WorkoutDetailSizes {
  static const double _padding = 18;
  static const double _spacing = 14;
  static const double _titleFontSize = 24;
  static const double _subtitleFontSize = 16;
  static const double _fontSize = 14;
  static const double _smallFontSize = 11;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static WorkoutDetailSizesList _sizeByRatio(double ratio) =>
      WorkoutDetailSizesList(
        padding: _padding * ratio,
        spacing: _spacing * ratio,
        titleFountSize: _titleFontSize * ratio,
        subtitleFontSize: _subtitleFontSize * ratio,
        fontSize: _fontSize * ratio,
        smallFontSize: _smallFontSize * ratio,
      );

  static WorkoutDetailSizesList getWorkoutDetailSizes(ScreenSize screenSize) {
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
