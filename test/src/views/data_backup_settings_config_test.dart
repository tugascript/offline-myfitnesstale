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

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/time_of_day_value.dart';
import 'package:myfitnesstale/src/data/utils/weekday_time_of_day_value.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/layout/sharp_switch.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/backup_passkey_modal.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/backup_settings_config.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/data_export.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/reminders_settings_config.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/settings_config.dart';

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit() : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Tester',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ),
        system: const SystemDto(
          id: 1,
          units: Units.metric,
          theme: ThemeType.system,
          initialSetup: SetUpStatus.completed,
          notificationsOn: false,
        ),
        remindersConfig: RemindersConfigDto(
          id: 1,
          workoutsOn: false,
          workoutsReminderTime: const TimeOfDayValue(hour: 8, minute: 0),
          weightRecordsOn: false,
          weightRecordsReminderTime: WeekdayTimeOfDayValue.defaultReminder,
          macroTrackingOn: false,
          macroTrackingReminderTime: const TimeOfDayValue(hour: 8, minute: 0),
        ),
        isLoading: false,
        isInitiated: true,
      ),
    );
  }
}

void main() {
  Widget buildSubject(
    _TestProfileCubit cubit, {
    ScreenSize screenSize = ScreenSize.md,
  }) {
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
    return BlocProvider<ProfileCubit>.value(
      value: cubit,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return SettingsConfig(
                    profileId: state.profile!.id,
                    sizes: sizes,
                    system: state.system!,
                    remindersConfig: state.remindersConfig!,
                    isLoading: state.isLoading,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders BackupSettingsConfig and DataExport as separate sections after Reminders',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final cubit = _TestProfileCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('profile-backup-settings')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('profile-data-export')), findsOneWidget);
      expect(find.text(' Backups'), findsOneWidget);
      expect(find.text('(Coming Soon)'), findsOneWidget);
      expect(find.text(' Data Export'), findsOneWidget);

      expect(find.text('Backups'), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
      expect(find.text('Schedule'), findsNothing);
      expect(find.text('Encrypted'), findsNothing);
      expect(find.byKey(const ValueKey('backup-backups-on')), findsOneWidget);
      expect(find.byKey(const ValueKey('backup-schedule')), findsOneWidget);
      expect(find.byKey(const ValueKey('backup-provider')), findsOneWidget);
      expect(find.byKey(const ValueKey('backup-encrypted')), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Google Drive'), findsOneWidget);

      final backupsSwitchRect = tester.getRect(
        find.byKey(const ValueKey('backup-backups-on')),
      );
      final scheduleRect = tester.getRect(
        find.byKey(const ValueKey('backup-schedule')),
      );
      expect(scheduleRect.left, greaterThan(backupsSwitchRect.right));
      expect(
        (scheduleRect.center.dy - backupsSwitchRect.center.dy).abs(),
        lessThan(10),
      );

      final providerRect = tester.getRect(
        find.byKey(const ValueKey('backup-provider')),
      );
      final encryptedSwitchRect = tester.getRect(
        find.byKey(const ValueKey('backup-encrypted')),
      );
      expect(encryptedSwitchRect.left, greaterThan(providerRect.right));
      expect(
        (encryptedSwitchRect.center.dy - providerRect.center.dy).abs(),
        lessThan(10),
      );

      expect(find.byKey(const ValueKey('data-export-json')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('data-export-snapshot')),
        findsOneWidget,
      );
      expect(find.text('Export data'), findsOneWidget);
      expect(find.text('Database snapshot'), findsOneWidget);

      final remindersTop = tester
          .getTopLeft(find.byType(RemindersSettingsConfig))
          .dy;
      final backupTop = tester.getTopLeft(find.byType(BackupSettingsConfig)).dy;
      final exportTop = tester.getTopLeft(find.byType(DataExport)).dy;
      expect(backupTop, greaterThan(remindersTop));
      expect(exportTop, greaterThan(backupTop));

      final jsonRect = tester.getRect(
        find.byKey(const ValueKey('data-export-json')),
      );
      final snapshotRect = tester.getRect(
        find.byKey(const ValueKey('data-export-snapshot')),
      );
      expect(jsonRect.top, equals(snapshotRect.top));
      expect(snapshotRect.left, greaterThan(jsonRect.left));
    },
  );

  testWidgets(
    'defaults provider to iCloud on iOS and Google Drive on Android',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final cubit = _TestProfileCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      expect(find.text('iCloud'), findsOneWidget);
    },
  );

  testWidgets(
    'disables schedule, provider, and encrypted when backups are off while export buttons remain clickable',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final cubit = _TestProfileCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('backup-schedule')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Weekly'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('backup-provider')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Local File'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('backup-encrypted')));
      await tester.pumpAndSettle();
      expect(find.byType(BackupPasskeyModal), findsNothing);

      await tester.ensureVisible(
        find.byKey(const ValueKey('data-export-json')),
      );
      await tester.tap(find.byKey(const ValueKey('data-export-json')));
      await tester.pumpAndSettle();
      expect(find.text('Export Data Copy coming soon!'), findsOneWidget);
    },
  );

  testWidgets(
    'keeps backup controls disabled when tapped until backups are implemented',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final cubit = _TestProfileCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pumpAndSettle();

      final backupsSwitch = tester.widget<SharpSwitch>(
        find.byKey(const ValueKey('backup-backups-on')),
      );
      expect(backupsSwitch.enabled, isFalse);
      expect(backupsSwitch.value, isFalse);

      await tester.tap(find.byKey(const ValueKey('backup-backups-on')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<SharpSwitch>(
              find.byKey(const ValueKey('backup-backups-on')),
            )
            .value,
        isFalse,
      );

      await tester.tap(
        find.byKey(const ValueKey('backup-schedule')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Weekly'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('backup-provider')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Local File'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('backup-encrypted')));
      await tester.pumpAndSettle();
      expect(find.byType(BackupPasskeyModal), findsNothing);
    },
  );

  testWidgets(
    'BackupPasskeyModal validates input and returns submitted passkey',
    (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => BackupPasskeyModal(
                      theme: Theme.of(context),
                      sizes: sizes,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open modal and cancel -> returns null
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(BackupPasskeyModal), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(find.byType(BackupPasskeyModal), findsNothing);
      expect(result, isNull);

      // Re-open modal and test validation + saving valid passkey
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(BackupPasskeyModal), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('backup-passkey-input')),
        'short',
      );
      await tester.enterText(
        find.byKey(const ValueKey('backup-passkey-confirm-input')),
        'mismatch',
      );
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(
        find.text('Passkey must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passkeys do not match'), findsOneWidget);
      expect(find.byType(BackupPasskeyModal), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('backup-passkey-input')),
        'my-secure-passkey',
      );
      await tester.enterText(
        find.byKey(const ValueKey('backup-passkey-confirm-input')),
        'my-secure-passkey',
      );
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.byType(BackupPasskeyModal), findsNothing);
      expect(result, equals('my-secure-passkey'));
    },
  );

  testWidgets('renders without overflow on narrow xs screen', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final cubit = _TestProfileCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, screenSize: ScreenSize.xs));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(BackupSettingsConfig), findsOneWidget);
    expect(find.byType(DataExport), findsOneWidget);
  });
}
