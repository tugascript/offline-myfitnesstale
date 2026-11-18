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
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef DirectoryProvider = Future<Directory> Function();

final class LocalFileStorageService {
  static const String picturesFolderName = 'pictures';
  static final Logger _logger = Logger('LocalFileStorageService');
  static final Random _random = Random();

  final DirectoryProvider _directoryProvider;

  const LocalFileStorageService({DirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;

  factory LocalFileStorageService.create({
    DirectoryProvider? directoryProvider,
  }) => LocalFileStorageService(directoryProvider: directoryProvider);

  Future<Directory> getPicturesDirectory() async {
    final baseDir = await _directoryProvider();
    final picturesDir = Directory(p.join(baseDir.path, picturesFolderName));
    if (!await picturesDir.exists()) {
      await picturesDir.create(recursive: true);
    }
    return picturesDir;
  }

  Future<String> savePictureBytes(
    Uint8List bytes, {
    String extension = 'jpg',
    String prefix = 'picture',
  }) async {
    final cleanPrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final cleanExt = extension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final resolvedExt = cleanExt.isEmpty ? 'jpg' : cleanExt.toLowerCase();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(1 << 20).toRadixString(16).padLeft(5, '0');
    final fileName = '${cleanPrefix}_${timestamp}_$suffix.$resolvedExt';

    final picturesDir = await getPicturesDirectory();
    final file = File(p.join(picturesDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    _logger.info('Saved picture bytes to $fileName (${bytes.length} bytes)');
    return fileName;
  }

  Future<File?> resolvePictureFile(String uri) async {
    final trimmed = uri.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (p.isAbsolute(trimmed)) {
      return File(trimmed);
    }

    try {
      final picturesDir = await getPicturesDirectory();
      final picturesRoot = p.normalize(p.absolute(picturesDir.path));
      final resolvedPath = p.normalize(p.join(picturesRoot, trimmed));
      if (!p.isWithin(picturesRoot, resolvedPath)) {
        _logger.warning('Rejected picture path outside storage root: $uri');
        return null;
      }

      return File(resolvedPath);
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> pictureExists(String uri) async {
    final file = await resolvePictureFile(uri);
    if (file == null) return false;
    return file.exists();
  }

  Future<bool> deletePicture(String uri) async {
    final trimmed = uri.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    try {
      final picturesDir = await getPicturesDirectory();
      final picturesRoot = p.normalize(p.absolute(picturesDir.path));
      final file = await resolvePictureFile(trimmed);
      if (file == null) {
        return false;
      }

      final filePath = p.normalize(p.absolute(file.path));
      if (!p.isWithin(picturesRoot, filePath) || !await file.exists()) {
        return false;
      }

      await file.delete();
      _logger.info('Deleted local picture: $trimmed');
      return true;
    } on MissingPluginException {
      return false;
    } catch (e, st) {
      _logger.warning('Failed to delete local picture: $trimmed', e, st);
      return false;
    }
  }
}
