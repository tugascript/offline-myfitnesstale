import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'entitlement_states';
const Object _noChange = Object();

enum EntitlementStateColumns with Columns {
  id('id'),
  entitlement('entitlement'),
  status('status'),
  expiresAt('expires_at'),
  lastVerifiedAt('last_verified_at'),
  source('source'),
  verificationToken('verification_token'),
  createdAt('created_at'),
  updatedAt('updated_at');

  @override
  final String value;

  const EntitlementStateColumns(this.value);
}

class EntitlementStateModel extends Equatable implements Model {
  @override
  final int? id;
  final EntitlementType entitlement;
  final EntitlementStatus status;
  final int? expiresAt;
  final int lastVerifiedAt;
  final EntitlementSource source;
  final String verificationToken;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const EntitlementStateModel({
    this.id,
    required this.entitlement,
    required this.status,
    this.expiresAt,
    required this.lastVerifiedAt,
    required this.source,
    required this.verificationToken,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${EntitlementStateColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${EntitlementStateColumns.entitlement.value} TEXT NOT NULL,
    ${EntitlementStateColumns.status.value} TEXT NOT NULL,
    ${EntitlementStateColumns.expiresAt.value} INTEGER,
    ${EntitlementStateColumns.lastVerifiedAt.value} INTEGER NOT NULL,
    ${EntitlementStateColumns.source.value} TEXT NOT NULL,
    ${EntitlementStateColumns.verificationToken.value} TEXT NOT NULL,
    ${EntitlementStateColumns.createdAt.value} INTEGER NOT NULL,
    ${EntitlementStateColumns.updatedAt.value} INTEGER NOT NULL
  );
  ''';

  factory EntitlementStateModel.createCachedDefault() {
    final int now = DateUtilities.getNowUtcUnix();
    return EntitlementStateModel(
      entitlement: EntitlementType.free,
      status: EntitlementStatus.unknown,
      expiresAt: null,
      lastVerifiedAt: 0,
      source: EntitlementSource.cache,
      verificationToken: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      EntitlementStateColumns.id.value: id,
      EntitlementStateColumns.entitlement.value: entitlement.value,
      EntitlementStateColumns.status.value: status.value,
      EntitlementStateColumns.expiresAt.value: expiresAt,
      EntitlementStateColumns.lastVerifiedAt.value: lastVerifiedAt,
      EntitlementStateColumns.source.value: source.value,
      EntitlementStateColumns.verificationToken.value: verificationToken,
      EntitlementStateColumns.createdAt.value: createdAt,
      EntitlementStateColumns.updatedAt.value: updatedAt,
    };
  }

  factory EntitlementStateModel.fromMap(Map<String, Object?> map) {
    return EntitlementStateModel(
      id: map[EntitlementStateColumns.id.value] as int?,
      entitlement: EntitlementType.fromValue(
        map[EntitlementStateColumns.entitlement.value]! as String,
      ),
      status: EntitlementStatus.fromValue(
        map[EntitlementStateColumns.status.value]! as String,
      ),
      expiresAt: map[EntitlementStateColumns.expiresAt.value] as int?,
      lastVerifiedAt: map[EntitlementStateColumns.lastVerifiedAt.value] as int,
      source: EntitlementSource.fromValue(
        map[EntitlementStateColumns.source.value]! as String,
      ),
      verificationToken:
          map[EntitlementStateColumns.verificationToken.value] as String,
      createdAt: map[EntitlementStateColumns.createdAt.value] as int,
      updatedAt: map[EntitlementStateColumns.updatedAt.value] as int,
    );
  }

  @override
  EntitlementStateModel copyWith({
    int? id,
    EntitlementType? entitlement,
    EntitlementStatus? status,
    Object? expiresAt = _noChange,
    int? lastVerifiedAt,
    EntitlementSource? source,
    String? verificationToken,
    int? createdAt,
    int? updatedAt,
  }) {
    return EntitlementStateModel(
      id: id ?? this.id,
      entitlement: entitlement ?? this.entitlement,
      status: status ?? this.status,
      expiresAt: expiresAt == _noChange ? this.expiresAt : expiresAt as int?,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      source: source ?? this.source,
      verificationToken: verificationToken ?? this.verificationToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entitlement,
        status,
        expiresAt,
        lastVerifiedAt,
        source,
        verificationToken,
        createdAt,
        updatedAt,
      ];
}
