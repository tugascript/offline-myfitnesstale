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

import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

sealed class PictureUtils {
  static const double horizontalAspectRatio = 4 / 3;
  static const int defaultMaxWidth = 1200;
  static const int defaultMaxHeight = 900;
  static const int defaultMaxBytes = 400 * 1024;
  static const int defaultEditorMaxDimension = 2048;

  static bool isValidNetworkUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return false;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return false;
    }

    final host = uri.host.trim();
    if (host.isEmpty) {
      return false;
    }

    return host == 'localhost' || host.contains('.');
  }

  static String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!isValidNetworkUrl(value)) {
      return 'Please enter a valid HTTP or HTTPS image URL';
    }
    return null;
  }

  static String? validateRequiredUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an image URL';
    }
    return validateOptionalUrl(value);
  }

  static Future<Uint8List> prepareForCropping(
    Uint8List bytes, {
    int maxDimension = defaultEditorMaxDimension,
  }) async {
    try {
      return await _prepareWithDartImage(bytes, maxDimension: maxDimension);
    } on FormatException {
      // Fallback to Flutter's native platform codec for formats not decoded by
      // package:image (such as iPhone HEIC/HEIF photos).
      return _prepareWithPlatformCodec(bytes, maxDimension: maxDimension);
    }
  }

  static Future<Uint8List> _prepareWithDartImage(
    Uint8List bytes, {
    required int maxDimension,
  }) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unable to decode image bytes');
      }

      final oriented = img.bakeOrientation(decoded);
      final maxEdge = math.max(oriented.width, oriented.height);
      if (maxEdge <= maxDimension) {
        return Uint8List.fromList(img.encodeJpg(oriented, quality: 92));
      }

      final scale = maxDimension / maxEdge;
      final resized = img.copyResize(
        oriented,
        width: math.max(1, (oriented.width * scale).round()),
        height: math.max(1, (oriented.height * scale).round()),
        interpolation: img.Interpolation.average,
      );
      return Uint8List.fromList(img.encodeJpg(resized, quality: 92));
    });
  }

  static Future<Uint8List> _prepareWithPlatformCodec(
    Uint8List bytes, {
    required int maxDimension,
  }) async {
    ui.Codec? probeCodec;
    try {
      probeCodec = await ui.instantiateImageCodec(bytes);
      final probeFrame = await probeCodec.getNextFrame();
      final probeImage = probeFrame.image;
      final width = probeImage.width;
      final height = probeImage.height;

      final maxEdge = math.max(width, height);
      var targetImage = probeImage;
      ui.Codec? scaledCodec;

      try {
        if (maxEdge > maxDimension) {
          final scale = maxDimension / maxEdge;
          final targetWidth = math.max(1, (width * scale).round());
          final targetHeight = math.max(1, (height * scale).round());
          try {
            scaledCodec = await ui.instantiateImageCodec(
              bytes,
              targetWidth: targetWidth,
              targetHeight: targetHeight,
            );
            final scaledFrame = await scaledCodec.getNextFrame();
            targetImage = scaledFrame.image;
          } catch (_) {
            targetImage = await _resizeUiImage(
              probeImage,
              targetWidth,
              targetHeight,
            );
          }
        }

        final byteData = await targetImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData == null) {
          throw const FormatException('Unable to encode image bytes');
        }
        return byteData.buffer.asUint8List();
      } finally {
        if (!identical(targetImage, probeImage)) {
          targetImage.dispose();
        }
        probeImage.dispose();
        scaledCodec?.dispose();
      }
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw const FormatException('Unable to decode image bytes');
    } finally {
      probeCodec?.dispose();
    }
  }

  static Future<ui.Image> _resizeUiImage(
    ui.Image source,
    int targetWidth,
    int targetHeight,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final srcRect = ui.Rect.fromLTWH(
      0,
      0,
      source.width.toDouble(),
      source.height.toDouble(),
    );
    final dstRect = ui.Rect.fromLTWH(
      0,
      0,
      targetWidth.toDouble(),
      targetHeight.toDouble(),
    );
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.drawImageRect(source, srcRect, dstRect, paint);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(targetWidth, targetHeight);
    } finally {
      picture.dispose();
    }
  }

  static Future<Uint8List> rotateClockwise90(Uint8List bytes) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unable to decode image bytes');
      }
      final rotated = img.copyRotate(decoded, angle: 90);
      return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
    });
  }

  static Future<Uint8List> compressHorizontalPicture(
    Uint8List bytes, {
    int maxWidth = defaultMaxWidth,
    int maxHeight = defaultMaxHeight,
    int initialQuality = 82,
    int minQuality = 45,
    int maxBytes = defaultMaxBytes,
  }) async {
    try {
      return await _compressWithDartImage(
        bytes,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        initialQuality: initialQuality,
        minQuality: minQuality,
        maxBytes: maxBytes,
      );
    } on FormatException {
      final transcoded = await _prepareWithPlatformCodec(
        bytes,
        maxDimension: math.max(maxWidth, maxHeight),
      );
      return _compressWithDartImage(
        transcoded,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        initialQuality: initialQuality,
        minQuality: minQuality,
        maxBytes: maxBytes,
      );
    }
  }

  static Future<Uint8List> _compressWithDartImage(
    Uint8List bytes, {
    required int maxWidth,
    required int maxHeight,
    required int initialQuality,
    required int minQuality,
    required int maxBytes,
  }) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unable to decode image bytes');
      }

      var current = img.bakeOrientation(decoded);

      // Ensure horizontal 4:3 aspect ratio if input deviates meaningfully.
      final currentRatio = current.width / current.height;
      if ((currentRatio - horizontalAspectRatio).abs() > 0.02) {
        final int cropWidth;
        final int cropHeight;
        if (currentRatio > horizontalAspectRatio) {
          cropHeight = current.height;
          cropWidth = math.max(1, (cropHeight * horizontalAspectRatio).round());
        } else {
          cropWidth = current.width;
          cropHeight = math.max(1, (cropWidth / horizontalAspectRatio).round());
        }
        final offsetX = ((current.width - cropWidth) / 2).round();
        final offsetY = ((current.height - cropHeight) / 2).round();
        current = img.copyCrop(
          current,
          x: offsetX,
          y: offsetY,
          width: cropWidth,
          height: cropHeight,
        );
      }

      if (current.width > maxWidth || current.height > maxHeight) {
        final widthScale = maxWidth / current.width;
        final heightScale = maxHeight / current.height;
        final scale = math.min(widthScale, heightScale);
        current = img.copyResize(
          current,
          width: math.max(1, (current.width * scale).round()),
          height: math.max(1, (current.height * scale).round()),
          interpolation: img.Interpolation.average,
        );
      }

      var quality = initialQuality;
      var encoded = Uint8List.fromList(
        img.encodeJpg(current, quality: quality),
      );

      while (encoded.length > maxBytes && quality > minQuality) {
        quality = math.max(minQuality, quality - 10);
        encoded = Uint8List.fromList(img.encodeJpg(current, quality: quality));
      }

      if (encoded.length > maxBytes && current.width > 640) {
        final downscaled = img.copyResize(
          current,
          width: 640,
          height: 480,
          interpolation: img.Interpolation.average,
        );
        encoded = Uint8List.fromList(
          img.encodeJpg(downscaled, quality: minQuality),
        );
      }

      return encoded;
    });
  }
}
