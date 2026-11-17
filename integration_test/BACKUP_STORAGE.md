# Native secure-storage verification

## Cache and database relaunch

The journey uses `integration_test.db`, an Android test key prefix in the
default plugin preference files, and a separate iOS Keychain account. It never
deletes production `app.db` or the application's cached AES key. Run on a
dedicated test installation; Android restore checks require replacing that
installation's data. Always pass `--no-uninstall`: Flutter otherwise uninstalls
the test app after each run, removing its SQLite data and secure storage before
the next phase. Rebuilding/reinstalling with data preserved is expected.

Run the normal write/read/clear and database-reopen journey:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall
```

For persistence across separate process launches, run these in order:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall --dart-define=BACKUP_STORAGE_PHASE=seed
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall --dart-define=BACKUP_STORAGE_PHASE=verify
```

`seed` writes a known test key and an ordinary SQLite configuration row.
`verify` checks both without replacing them. These phases deliberately preserve
their fixtures between invocations.

## Android backup and device transfer

Use a dedicated Android test device with only synthetic app data. Use API 31 or
later for the cloud and device-transfer rules and repeat the backup check on API
30 or earlier for the legacy rules. Generate a fresh fixture ID for each
transport and keep it for all phases of that run.

```sh
fixture_id="$(uuidgen)"
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall \
  --dart-define=BACKUP_STORAGE_PHASE=seed --dart-define=BACKUP_STORAGE_FIXTURE="$fixture_id"
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall \
  --dart-define=BACKUP_STORAGE_PHASE=verify --dart-define=BACKUP_STORAGE_FIXTURE="$fixture_id"
```

Use `adb -s <device-id>` and confirm the active transport with
`shell bmgr list transports`. Use a Google backup test account and the GMS
backup transport for a hosted cloud restore. Android's local transport can
exercise the cloud-backup rules on an emulator. Follow the Android Developers
procedure for single-device transfer testing, or use two dedicated devices.
[Android backup and transfer test procedures](https://developer.android.com/identity/data/testingbackup).

Open the installed test app once after Flutter exits. Android Backup Manager
skips force-stopped apps. If the debug bundle exceeds the transport quota,
remove the extracted Flutter assets from the dedicated test installation
before retrying backup. The restore test builds a fresh APK with those assets.

```sh
adb -s <device-id> shell run-as com.example.myfitnesstale rm -rf app_flutter/flutter_assets
```

Confirm `bmgr backupnow com.example.myfitnesstale` reports package success.
Save the installed APK, uninstall the fixture app to remove its KeyStore keys,
and reinstall the same APK to trigger OS restore. Wait for restore to finish
before launching the app. Then run:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall \
  --dart-define=BACKUP_STORAGE_PHASE=restore --dart-define=BACKUP_STORAGE_FIXTURE="$fixture_id"
```

The test requires the matching SQLite fixture, checks that the four excluded
preference files are absent before opening secure storage, and verifies that a
different cached key can be written, read, and cleared. Record the OS/API, the
transport, and the seed, backup, and restore results. Clean up the test fixtures:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall --dart-define=BACKUP_STORAGE_PHASE=cleanup
```

## iOS notification authorization

Run each decision on a fresh simulator or test installation with an
undetermined notification permission. The journey opens onboarding, taps
**Allow Notifications**, and waits up to three minutes for the system alert
response. Choose **Allow** for the first run and **Don’t Allow** for the second.

```sh
flutter test integration_test/ios_notification_permission_journey_test.dart -d <device-id> \
  --no-uninstall --dart-define=IOS_NOTIFICATION_DECISION=allow
flutter test integration_test/ios_notification_permission_journey_test.dart -d <fresh-device-id> \
  --no-uninstall --dart-define=IOS_NOTIFICATION_DECISION=deny
```

The test checks both the resulting OS authorization status and the onboarding
switch. Use the separate `seed`, `verify`, and `cleanup` phases above for iOS
Keychain behavior across process launches.
