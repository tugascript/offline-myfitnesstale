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

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:myfitnesstale/src/data/utils/picture_utils.dart';

Uint8List _createPngBytes(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgba(x, y, (x * 7) % 256, (y * 11) % 256, 120, 255);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PictureUtils URL validation', () {
    test('accepts valid http and https image URLs', () {
      expect(
        PictureUtils.isValidNetworkUrl('https://example.com/barbell.jpg'),
        isTrue,
      );
      expect(
        PictureUtils.isValidNetworkUrl('http://localhost/images/rack.png'),
        isTrue,
      );
      expect(PictureUtils.validateOptionalUrl(''), isNull);
      expect(
        PictureUtils.validateRequiredUrl('https://cdn.site.org/pic.webp'),
        isNull,
      );
    });

    test('rejects invalid schemes and malformed URLs', () {
      expect(
        PictureUtils.isValidNetworkUrl('ftp://example.com/a.jpg'),
        isFalse,
      );
      expect(PictureUtils.isValidNetworkUrl('not-a-url'), isFalse);
      expect(PictureUtils.isValidNetworkUrl('https://nodot'), isFalse);
      expect(PictureUtils.validateRequiredUrl('   '), isNotNull);
      expect(PictureUtils.validateOptionalUrl('file:///tmp/a.png'), isNotNull);
    });
  });

  group('PictureUtils image processing & compression', () {
    test(
      'compressHorizontalPicture crops non-4:3 and downscales oversized photos',
      () async {
        final raw = _createPngBytes(2000, 3000);
        final compressed = await PictureUtils.compressHorizontalPicture(raw);

        final decoded = img.decodeJpg(compressed);
        expect(decoded, isNotNull);
        expect(decoded!.width, lessThanOrEqualTo(PictureUtils.defaultMaxWidth));
        expect(
          decoded.height,
          lessThanOrEqualTo(PictureUtils.defaultMaxHeight),
        );
        expect(
          decoded.width / decoded.height,
          closeTo(PictureUtils.horizontalAspectRatio, 0.02),
        );
        expect(
          compressed.length,
          lessThanOrEqualTo(PictureUtils.defaultMaxBytes),
        );
      },
    );

    test('compressHorizontalPicture preserves small 4:3 dimensions without upscaling', () async {
      final raw = _createPngBytes(400, 300);
      final compressed = await PictureUtils.compressHorizontalPicture(raw);

      final decoded = img.decodeJpg(compressed);
      expect(decoded, isNotNull);
      expect(decoded!.width, 400);
      expect(decoded.height, 300);
    });

    test('prepareForCropping caps max dimension and rotateClockwise90 swaps dimensions', () async {
      final large = _createPngBytes(2600, 1300);
      final prepared = await PictureUtils.prepareForCropping(
        large,
        maxDimension: 1000,
      );
      final preparedDecoded = img.decodeJpg(prepared);
      expect(preparedDecoded, isNotNull);
      expect(preparedDecoded!.width, 1000);
      expect(preparedDecoded.height, 500);

      final rotated = await PictureUtils.rotateClockwise90(prepared);
      final rotatedDecoded = img.decodeJpg(rotated);
      expect(rotatedDecoded, isNotNull);
      expect(rotatedDecoded!.width, 500);
      expect(rotatedDecoded.height, 1000);
    });

    test('throws FormatException on invalid bytes', () async {
      expect(
        () => PictureUtils.prepareForCropping(Uint8List.fromList([1, 2])),
        throwsFormatException,
      );
      expect(
        () =>
            PictureUtils.compressHorizontalPicture(Uint8List.fromList([1, 2])),
        throwsFormatException,
      );
    });
  });
}
