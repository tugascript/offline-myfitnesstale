import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/entitlement_state_dto.dart';
import 'package:myfitnesstale/src/services/entitlement_guard.dart';

void main() {
  const int now = 1700000000;

  EntitlementStateDto buildSnapshot({
    required EntitlementType entitlement,
    required EntitlementStatus status,
    required int lastVerifiedAt,
    String verificationToken = 'signed-token',
    int? expiresAt,
  }) {
    return EntitlementStateDto(
      id: 1,
      entitlement: entitlement,
      status: status,
      expiresAt: expiresAt,
      lastVerifiedAt: lastVerifiedAt,
      source: EntitlementSource.server,
      verificationToken: verificationToken,
      updatedAt: now,
    );
  }

  test('allows active premium within verification token TTL', () {
    final snapshot = buildSnapshot(
      entitlement: EntitlementType.premium,
      status: EntitlementStatus.active,
      lastVerifiedAt: now - 60,
      expiresAt: now + 120,
    );

    expect(EntitlementGuard.canUsePremium(snapshot, nowUnix: now), isTrue);
  });

  test('blocks active premium when token TTL expires', () {
    final snapshot = buildSnapshot(
      entitlement: EntitlementType.premium,
      status: EntitlementStatus.active,
      lastVerifiedAt: now - (kVerificationTokenTtlSecs + 1),
      expiresAt: now + 120,
    );

    expect(EntitlementGuard.canUsePremium(snapshot, nowUnix: now), isFalse);
  });

  test('allows grace premium within grace window', () {
    final snapshot = buildSnapshot(
      entitlement: EntitlementType.premium,
      status: EntitlementStatus.grace,
      lastVerifiedAt: now - 120,
      expiresAt: now - 60,
    );

    expect(EntitlementGuard.canUsePremium(snapshot, nowUnix: now), isTrue);
  });

  test('blocks when verification token is missing', () {
    final snapshot = buildSnapshot(
      entitlement: EntitlementType.premium,
      status: EntitlementStatus.active,
      lastVerifiedAt: now - 60,
      verificationToken: '',
      expiresAt: now + 120,
    );

    expect(EntitlementGuard.canUsePremium(snapshot, nowUnix: now), isFalse);
  });

  test('blocks free entitlement even with active status', () {
    final snapshot = buildSnapshot(
      entitlement: EntitlementType.free,
      status: EntitlementStatus.active,
      lastVerifiedAt: now - 60,
      expiresAt: now + 120,
    );

    expect(EntitlementGuard.canUsePremium(snapshot, nowUnix: now), isFalse);
  });
}
