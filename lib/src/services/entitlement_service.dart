import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../models/db.dart';
import '../models/entitlement_state_model.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/entitlement_state_dto.dart';

const String kEntitlementSyncPath = '/entitlements/sync';

abstract interface class EntitlementIdentityProvider {
  Future<String?> getAuthToken();

  Future<String?> getAppUserId();
}

class LocalEntitlementIdentityProvider implements EntitlementIdentityProvider {
  @override
  Future<String?> getAuthToken() async {
    return null;
  }

  @override
  Future<String?> getAppUserId() async {
    return null;
  }
}

abstract interface class RevenueCatGateway {
  Future<Result<String?, ServiceError<OperationErrorTypes>>> purchasePremium();

  Future<Result<String?, ServiceError<OperationErrorTypes>>> restorePurchases();
}

class MethodChannelRevenueCatGateway implements RevenueCatGateway {
  static const MethodChannel _channel =
      MethodChannel('myfitnesstale/revenuecat');

  @override
  Future<Result<String?, ServiceError<OperationErrorTypes>>>
      purchasePremium() async {
    try {
      final dynamic response = await _channel.invokeMethod('purchasePremium');
      if (response is Map) {
        return ok(response['appUserId'] as String?);
      }
      return ok(null);
    } on MissingPluginException {
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'RevenueCat native bridge not installed',
      ));
    } catch (e) {
      return err(ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to purchase premium: $e',
      ));
    }
  }

  @override
  Future<Result<String?, ServiceError<OperationErrorTypes>>>
      restorePurchases() async {
    try {
      final dynamic response = await _channel.invokeMethod('restorePurchases');
      if (response is Map) {
        return ok(response['appUserId'] as String?);
      }
      return ok(null);
    } on MissingPluginException {
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'RevenueCat native bridge not installed',
      ));
    } catch (e) {
      return err(ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to restore purchases: $e',
      ));
    }
  }
}

class EntitlementService {
  EntitlementService._({
    EntitlementIdentityProvider? identityProvider,
    RevenueCatGateway? revenueCatGateway,
  })  : _identityProvider =
            identityProvider ?? LocalEntitlementIdentityProvider(),
        _revenueCatGateway =
            revenueCatGateway ?? MethodChannelRevenueCatGateway();

  static final EntitlementService _instance = EntitlementService._();

  factory EntitlementService() => _instance;

  final Logger _logger = Logger('Entitlement Service');

  final Repository<EntitlementStateModel> _repository =
      Repository<EntitlementStateModel>(
    databaseHelper: DatabaseHelper(),
    tableName: EntitlementStateModel.table,
    fromMap: EntitlementStateModel.fromMap,
  );

  final EntitlementIdentityProvider _identityProvider;
  final RevenueCatGateway _revenueCatGateway;

  Future<Result<EntitlementStateDto, ServiceError<SingleErrorTypes>>>
      getEntitlementSnapshot() async {
    try {
      final EntitlementStateModel? existing = await _repository.selectLatest();
      if (existing != null) {
        return ok(EntitlementStateDto.fromModel(existing));
      }

      final EntitlementStateModel seeded =
          EntitlementStateModel.createCachedDefault();
      final int id = await _repository.insert(seeded);
      return ok(EntitlementStateDto.fromModel(seeded.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to get entitlement snapshot', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to load entitlement snapshot',
      ));
    }
  }

  Future<Result<EntitlementStateDto, ServiceError<OperationErrorTypes>>>
      refreshEntitlement({
    required bool force,
    String? appUserId,
  }) async {
    final snapshotResult = await getEntitlementSnapshot();
    if (snapshotResult.isErr()) {
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to read local entitlement snapshot',
      ));
    }

    final EntitlementStateDto localSnapshot = snapshotResult.value;
    final int now = DateUtilities.getNowUtcUnix();

    if (!force && (now - localSnapshot.lastVerifiedAt) < 60) {
      return ok(localSnapshot);
    }

    try {
      final EntitlementStateDto synced = await _fetchAndPersistFromServer(
        appUserId: appUserId,
        localSnapshot: localSnapshot,
      );
      return ok(synced);
    } catch (e) {
      _logger.warning('Server refresh failed. Falling back to grace cache.', e);
      final EntitlementStateDto degraded = await _degradeToGrace(localSnapshot);
      return ok(degraded);
    }
  }

  Future<Result<EntitlementStateDto, ServiceError<OperationErrorTypes>>>
      purchasePremium() async {
    final purchaseResult = await _revenueCatGateway.purchasePremium();
    if (purchaseResult.isErr()) {
      return err(purchaseResult.error);
    }

    return refreshEntitlement(
      force: true,
      appUserId: purchaseResult.value,
    );
  }

  Future<Result<EntitlementStateDto, ServiceError<OperationErrorTypes>>>
      restorePurchases() async {
    final restoreResult = await _revenueCatGateway.restorePurchases();
    if (restoreResult.isErr()) {
      return err(restoreResult.error);
    }

    return refreshEntitlement(
      force: true,
      appUserId: restoreResult.value,
    );
  }

  Future<EntitlementStateDto> _fetchAndPersistFromServer({
    required EntitlementStateDto localSnapshot,
    String? appUserId,
  }) async {
    final String baseUrl = const String.fromEnvironment(
        'ENTITLEMENT_API_BASE_URL',
        defaultValue: '');
    if (baseUrl.isEmpty) {
      throw Exception('ENTITLEMENT_API_BASE_URL is missing');
    }

    final String debugAppUserId = const String.fromEnvironment(
      'ENTITLEMENT_DEBUG_APP_USER_ID',
      defaultValue: '',
    );

    final String resolvedAppUserId = appUserId ??
        await _identityProvider.getAppUserId() ??
        (debugAppUserId.isNotEmpty ? debugAppUserId : 'anonymous-local');
    final String? authToken = await _identityProvider.getAuthToken();

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final Uri uri = Uri.parse('$baseUrl$kEntitlementSyncPath');
      final HttpClientRequest request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (authToken != null && authToken.isNotEmpty) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
      }

      request.write(jsonEncode({
        'appUserId': resolvedAppUserId,
        'platform': Platform.operatingSystem,
      }));

      final HttpClientResponse response = await request.close();
      final String payload = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'Entitlement sync failed: ${response.statusCode} $payload');
      }

      final dynamic decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Entitlement response is invalid');
      }

      final int now = DateUtilities.getNowUtcUnix();
      final EntitlementStateModel model = EntitlementStateModel(
        id: localSnapshot.id,
        entitlement: EntitlementType.fromValue(
          decoded['entitlement'] as String? ?? EntitlementType.free.value,
        ),
        status: EntitlementStatus.fromValue(
          decoded['status'] as String? ?? EntitlementStatus.unknown.value,
        ),
        expiresAt: decoded['expiresAt'] as int?,
        lastVerifiedAt: decoded['lastVerifiedAt'] as int? ?? now,
        source: EntitlementSource.fromValue(
          decoded['source'] as String? ?? EntitlementSource.server.value,
        ),
        verificationToken: decoded['verificationToken'] as String? ?? '',
        createdAt: localSnapshot.updatedAt,
        updatedAt: now,
      );

      final EntitlementStateModel persisted = await _upsertSnapshot(model);
      return EntitlementStateDto.fromModel(persisted);
    } finally {
      client.close(force: true);
    }
  }

  Future<EntitlementStateDto> _degradeToGrace(
    EntitlementStateDto localSnapshot,
  ) async {
    final int now = DateUtilities.getNowUtcUnix();
    final int age = now - localSnapshot.lastVerifiedAt;

    final bool canUseGrace =
        localSnapshot.entitlement == EntitlementType.premium &&
            localSnapshot.verificationToken.isNotEmpty &&
            age <= 24 * 60 * 60;

    final EntitlementStateModel model = EntitlementStateModel(
      id: localSnapshot.id,
      entitlement: canUseGrace ? EntitlementType.premium : EntitlementType.free,
      status: canUseGrace ? EntitlementStatus.grace : EntitlementStatus.expired,
      expiresAt: localSnapshot.expiresAt,
      lastVerifiedAt: localSnapshot.lastVerifiedAt,
      source: EntitlementSource.cache,
      verificationToken: canUseGrace ? localSnapshot.verificationToken : '',
      createdAt: localSnapshot.updatedAt,
      updatedAt: now,
    );

    final EntitlementStateModel persisted = await _upsertSnapshot(model);
    return EntitlementStateDto.fromModel(persisted);
  }

  Future<EntitlementStateModel> _upsertSnapshot(
    EntitlementStateModel model,
  ) async {
    if (model.id == null) {
      final int id = await _repository.insert(model);
      return model.copyWith(id: id);
    }

    await _repository.update(model);
    return model;
  }
}
