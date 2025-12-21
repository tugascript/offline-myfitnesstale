import 'screen_size.dart';

class ExercisesListSizesList {
  final double padding;
  final double radius;
  final double inputSpacing;
  final double buttonIconSize;

  const ExercisesListSizesList({
    required this.padding,
    required this.radius,
    required this.inputSpacing,
    required this.buttonIconSize,
  });
}

sealed class ExercisesListSizes {
  static const double _padding = 20;
  static const double _radius = 10;
  static const double _inputSpacing = 15;
  static const double _buttonIconSize = 45;

  static const double _xlRatio = 1.2;
  static const double _lgRatio = 1.1;
  static const double _mdRatio = 1;
  static const double _smRatio = 0.9;
  static const double _xsRatio = 0.8;

  static ExercisesListSizesList _sizeByRatio(double ratio) =>
      ExercisesListSizesList(
        padding: _padding * ratio,
        radius: _radius * ratio,
        inputSpacing: _inputSpacing * ratio,
        buttonIconSize: _buttonIconSize * ratio,
      );

  static ExercisesListSizesList getExercisesListSizes(ScreenSize screenSize) {
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
