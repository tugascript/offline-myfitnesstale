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

import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/utils/picture_utils.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/picture/app_picture_editor.dart';

Uint8List _sampleJpgBytes(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(240, 120, 40));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  testWidgets('AppPictureEditor configures 4:3 Crop and cancels cleanly', (tester) async {
    final theme = ThemeData();
    var cancelled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: AppPictureEditor(
              theme: theme,
              sizes: sizes,
              imageBytes: _sampleJpgBytes(800, 600),
              preparePicture: (bytes) async => bytes,
              onSaved: (_) {},
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final crop = tester.widget<Crop>(find.byType(Crop));
    expect(crop.aspectRatio, closeTo(PictureUtils.horizontalAspectRatio, 0.001));

    await tester.tap(find.text('CANCEL'));
    await tester.pump();
    expect(cancelled, isTrue);
  });

  testWidgets('AppPictureEditor crops and compresses to 4:3 JPEG on SAVE', (tester) async {
    final theme = ThemeData();
    Uint8List? savedBytes;
    final sample = _sampleJpgBytes(800, 600);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: AppPictureEditor(
              theme: theme,
              sizes: sizes,
              imageBytes: sample,
              preparePicture: (bytes) async => bytes,
              compressPicture: PictureUtils.compressHorizontalPicture,
              onSaved: (bytes) => savedBytes = bytes,
              onCancel: () {},
            ),
          ),
        ),
      ),
    );

    // Let Crop's internal compute() image parser complete and mark ready.
    for (var i = 0; i < 30; i++) {
      await tester.pump();
      final saveBtn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('SAVE'),
          matching: find.byType(ElevatedButton),
        ),
      );
      if (saveBtn.onPressed != null) {
        break;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    }

    await tester.tap(find.text('SAVE'));
    for (var i = 0; i < 40 && savedBytes == null; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    }

    expect(savedBytes, isNotNull);
    final decoded = img.decodeJpg(savedBytes!);
    expect(decoded, isNotNull);
    expect(decoded!.width / decoded.height, closeTo(4 / 3, 0.03));
  });
}
