import 'screen_size.dart';

class WorkoutsSizesList {
  final double padding;
  final double radius;
  final double inputSpacing;
  final double gridSpacing;
  final double bigIcon;
  final double loadingSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double fontSize;
  final double cardElevation;
  final double cardPadding;
  final double cardSpacing;
  final double arrowIconSize;
  final double buttonIconSize;
  final double buttonSize;
  final double elevation;

  const WorkoutsSizesList({
    required this.padding,
    required this.radius,
    required this.inputSpacing,
    required this.gridSpacing,
    required this.bigIcon,
    required this.loadingSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.fontSize,
    required this.cardElevation,
    required this.cardPadding,
    required this.cardSpacing,
    required this.arrowIconSize,
    required this.buttonIconSize,
    required this.buttonSize,
    required this.elevation,
  });
}

sealed class WorkoutsSizes {
  static const double _padding = 20;
  static const double _radius = 10;
  static const double _inputSpacing = 15;
  static const double _gridSpacing = 20;
  static const double _bigIcon = 80;
  static const double _loadingSize = 30;
  static const double _titleFontSize = 24;
  static const double _subtitleFontSize = 16;
  static const double _fontSize = 14;
  static const double _cardElevation = 2;
  static const double _cardPadding = 16;
  static const double _cardSpacing = 12;
  static const double _arrowIconSize = 16;
  static const double _buttonIconSize = 30;
  static const double _buttonSize = 65;
  static const double _elevation = 2;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static WorkoutsSizesList _sizeByRatio(double ratio) => WorkoutsSizesList(
        padding: _padding * ratio,
        radius: _radius * ratio,
        inputSpacing: _inputSpacing * ratio,
        gridSpacing: _gridSpacing * ratio,
        bigIcon: _bigIcon * ratio,
        loadingSize: _loadingSize * ratio,
        titleFontSize: _titleFontSize * ratio,
        subtitleFontSize: _subtitleFontSize * ratio,
        fontSize: _fontSize * ratio,
        cardElevation: _cardElevation * ratio,
        cardPadding: _cardPadding * ratio,
        cardSpacing: _cardSpacing * ratio,
        arrowIconSize: _arrowIconSize * ratio,
        buttonIconSize: _buttonIconSize * ratio,
        buttonSize: _buttonSize * ratio,
        elevation: _elevation * ratio,
      );

  static WorkoutsSizesList getWorkoutsSizes(ScreenSize screenSize) {
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
