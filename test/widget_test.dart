import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/my_app.dart';

void main() {
  test('MyApp is the root application widget', () {
    expect(const MyApp(), isA<Widget>());
  });
}
