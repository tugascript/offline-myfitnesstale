import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/sharp_switch_title.dart';
import 'package:permission_handler/permission_handler.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const decision = String.fromEnvironment('IOS_NOTIFICATION_DECISION');

  testWidgets('onboarding reflects the iOS notification decision ($decision)', (
    tester,
  ) async {
    expect(decision, isIn(['allow', 'deny']));
    final granted = decision == 'allow';
    final harness = DeviceTestHarness();
    addTearDown(() => harness.dispose(tester));
    await harness.launchFresh(tester);

    final notificationSwitch = find.widgetWithText(
      SharpSwitchTitle,
      'Allow Notifications',
    );
    await harness.pumpUntilFound(tester, notificationSwitch);
    await tester.ensureVisible(notificationSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<SharpSwitchTitle>(notificationSwitch).value, isFalse);
    // The iOS plugin reports not-determined as denied and an explicit
    // system denial as permanentlyDenied.
    expect(await Permission.notification.status, PermissionStatus.denied);

    await tester.tap(notificationSwitch);
    final pendingSwitch = find.byWidgetPredicate(
      (widget) =>
          widget is SharpSwitchTitle &&
          widget.title == 'Allow Notifications' &&
          !widget.enabled,
    );
    await harness.pumpUntilFound(tester, pendingSwitch);
    await harness.pumpUntilAbsent(
      tester,
      pendingSwitch,
      timeout: const Duration(minutes: 3),
    );

    expect(
      await Permission.notification.status,
      granted ? PermissionStatus.granted : PermissionStatus.permanentlyDenied,
    );
    expect(tester.widget<SharpSwitchTitle>(notificationSwitch).value, granted);
  }, skip: !Platform.isIOS || decision.isEmpty);
}
