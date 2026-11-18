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

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/core/dtos/picture_dto.dart';
import 'package:myfitnesstale/src/data/services/storage/local_file_storage_service.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/picture/app_picture.dart';

Uint8List _tinyValidJpg() {
  final image = img.Image(width: 80, height: 60);
  img.fill(image, color: img.ColorRgb8(255, 128, 0));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  testWidgets('AppPicture.memory enforces 4:3 AspectRatio and renders Image.memory', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: AppPicture.memory(
              memoryBytes: _tinyValidJpg(),
              sizes: sizes,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspect.aspectRatio, closeTo(4 / 3, 0.001));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AppPicture renders existing PictureStorage.files photo and fallback when missing', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('mft_app_pic_');
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final storage = LocalFileStorageService.create(
      directoryProvider: () async => tempDir,
    );
    late String savedUri;
    await tester.runAsync(() async {
      savedUri = await storage.savePictureBytes(_tinyValidJpg(), prefix: 'test');
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: AppPicture(
              picture: PictureDto(storage: PictureStorage.files, uri: savedUri),
              sizes: sizes,
              storageService: storage,
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 10 && find.byType(Image).evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Local photo unavailable'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: AppPicture(
              picture: const PictureDto(
                storage: PictureStorage.files,
                uri: 'missing.jpg',
              ),
              sizes: sizes,
              storageService: storage,
            ),
          ),
        ),
      ),
    );
    for (var i = 0;
        i < 10 && find.text('Local photo unavailable').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('Local photo unavailable'), findsOneWidget);
  });

  testWidgets('AppPicture handles PictureStorage.assets and PictureStorage.network', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 240,
                child: AppPicture(
                  picture: const PictureDto(
                    storage: PictureStorage.assets,
                    uri: 'assets/nonexistent.png',
                  ),
                  sizes: sizes,
                ),
              ),
              SizedBox(
                width: 240,
                child: AppPicture(
                  picture: const PictureDto(
                    storage: PictureStorage.network,
                    uri: 'https://example.com/equip.jpg',
                  ),
                  sizes: sizes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AspectRatio), findsNWidgets(2));
    expect(find.byType(Image), findsNWidgets(2));
  });
}
