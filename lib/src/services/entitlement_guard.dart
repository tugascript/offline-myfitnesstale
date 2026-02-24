import '../models/enums.dart';
import '../models/utilities.dart';
import 'dtos/entitlement_state_dto.dart';

const int kVerificationTokenTtlSecs = 6 * 60 * 60;
const int kEntitlementGraceWindowSecs = 24 * 60 * 60;

sealed class EntitlementGuard {
  static bool canUsePremium(EntitlementStateDto? snapshot, {int? nowUnix}) {
    if (snapshot == null) {
      return false;
    }

    if (snapshot.entitlement != EntitlementType.premium) {
      return false;
    }

    if (snapshot.verificationToken.isEmpty) {
      return false;
    }

    final int now = nowUnix ?? DateUtilities.getNowUtcUnix();
    final int age = now - snapshot.lastVerifiedAt;

    switch (snapshot.status) {
      case EntitlementStatus.active:
        if (snapshot.expiresAt != null && now >= snapshot.expiresAt!) {
          return false;
        }
        return age <= kVerificationTokenTtlSecs;
      case EntitlementStatus.grace:
        return age <= kEntitlementGraceWindowSecs;
      case EntitlementStatus.expired:
      case EntitlementStatus.billingIssue:
      case EntitlementStatus.unknown:
        return false;
    }
  }
}
