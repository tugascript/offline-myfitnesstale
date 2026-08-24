import 'package:equatable/equatable.dart';

import '../../models/entitlement_state_model.dart';
import '../../models/enums.dart';
import 'dto.dart';

const Object _noChange = Object();

class EntitlementStateDto extends Equatable
    implements Dto<EntitlementStateModel> {
  @override
  final int id;
  final EntitlementType entitlement;
  final EntitlementStatus status;
  final int? expiresAt;
  final int lastVerifiedAt;
  final EntitlementSource source;
  final String verificationToken;
  final int updatedAt;

  const EntitlementStateDto({
    required this.id,
    required this.entitlement,
    required this.status,
    this.expiresAt,
    required this.lastVerifiedAt,
    required this.source,
    required this.verificationToken,
    required this.updatedAt,
  });

  factory EntitlementStateDto.fromModel(EntitlementStateModel model) {
    return EntitlementStateDto(
      id: model.id!,
      entitlement: model.entitlement,
      status: model.status,
      expiresAt: model.expiresAt,
      lastVerifiedAt: model.lastVerifiedAt,
      source: model.source,
      verificationToken: model.verificationToken,
      updatedAt: model.updatedAt,
    );
  }

  @override
  EntitlementStateDto copyWith({
    int? id,
    EntitlementType? entitlement,
    EntitlementStatus? status,
    Object? expiresAt = _noChange,
    int? lastVerifiedAt,
    EntitlementSource? source,
    String? verificationToken,
    int? updatedAt,
  }) {
    return EntitlementStateDto(
      id: id ?? this.id,
      entitlement: entitlement ?? this.entitlement,
      status: status ?? this.status,
      expiresAt: expiresAt == _noChange ? this.expiresAt : expiresAt as int?,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      source: source ?? this.source,
      verificationToken: verificationToken ?? this.verificationToken,
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
        updatedAt,
      ];
}
