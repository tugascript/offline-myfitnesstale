import 'screen_size.dart';

class AppBarSizesList {
  final double height;
  final double title;
  final double icon;
  final double btnPadding;

  const AppBarSizesList({
    required this.height,
    required this.title,
    required this.icon,
    required this.btnPadding,
  });

  factory AppBarSizesList.multiply(double x) => AppBarSizesList(
        height: 65.0 * x,
        title: 25.0 * x,
        icon: 50.0 * x,
        btnPadding: 10.0 * x,
      );
}

class AppBarSizes {
  static AppBarSizesList get _xl => AppBarSizesList.multiply(1.3);

  static AppBarSizesList get _lg => AppBarSizesList.multiply(1.15);

  static AppBarSizesList get _md => AppBarSizesList.multiply(1.0);

  static AppBarSizesList get _sm => AppBarSizesList.multiply(0.9);

  static AppBarSizesList get _xs => AppBarSizesList.multiply(0.75);

  static AppBarSizesList getAppBarSizes(ScreenSize screenSize) {
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
