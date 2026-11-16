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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

final class SecureStorageService {
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger('SecureStorage');

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  factory SecureStorageService.create() => SecureStorageService();

  Future<void> write({required String key, required String value}) async {
    _logger.info('write: $key');
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    _logger.info('read: $key');
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    _logger.info('delete: $key');
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    _logger.info('deleteAll');
    await _storage.deleteAll();
  }
}
