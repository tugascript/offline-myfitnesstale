import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/enums.dart';

const String _kDebugSetPath = '/debug/set';
const String _kDebugResetPath = '/debug/reset';

class EntitlementDebugService {
  Future<void> setMockEntitlement({
    required EntitlementType entitlement,
    required EntitlementStatus status,
    int? expiresAt,
    String? verificationToken,
    String? appUserId,
  }) async {
    _ensureDebugMode();
    final String baseUrl = _getBaseUrl();

    final HttpClient client = HttpClient();
    try {
      final Uri uri = Uri.parse('$baseUrl$_kDebugSetPath');
      final HttpClientRequest request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({
        'appUserId': appUserId ?? _resolveAppUserId(),
        'entitlement': entitlement.value,
        'status': status.value,
        'expiresAt': expiresAt,
        'verificationToken': verificationToken ?? '',
      }));

      final HttpClientResponse response = await request.close();
      final String payload = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Mock set failed: ${response.statusCode} $payload');
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> resetMockEntitlement({String? appUserId}) async {
    _ensureDebugMode();
    final String baseUrl = _getBaseUrl();

    final HttpClient client = HttpClient();
    try {
      final Uri uri = Uri.parse('$baseUrl$_kDebugResetPath');
      final HttpClientRequest request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({
        if (appUserId != null) 'appUserId': appUserId,
      }));

      final HttpClientResponse response = await request.close();
      final String payload = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Mock reset failed: ${response.statusCode} $payload');
      }
    } finally {
      client.close(force: true);
    }
  }

  String _getBaseUrl() {
    final String baseUrl = const String.fromEnvironment(
      'ENTITLEMENT_API_BASE_URL',
      defaultValue: '',
    );

    if (baseUrl.isEmpty) {
      throw Exception('ENTITLEMENT_API_BASE_URL is missing');
    }

    return baseUrl;
  }

  String _resolveAppUserId() {
    final String debugAppUserId = const String.fromEnvironment(
      'ENTITLEMENT_DEBUG_APP_USER_ID',
      defaultValue: '',
    );
    return debugAppUserId.isNotEmpty ? debugAppUserId : 'anonymous-local';
  }

  void _ensureDebugMode() {
    if (!kDebugMode) {
      throw Exception(
          'Entitlement debug endpoints are only available in debug mode');
    }
  }
}
