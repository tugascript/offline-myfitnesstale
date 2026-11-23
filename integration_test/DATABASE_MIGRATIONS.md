# Native SQLite migration verification

The journey uses the real `sqflite` platform plugin and only
`integration_test.db`. It never opens or deletes production `app.db`.
Synthetic migrations exercise versions 2 and 3 without changing the
production schema version (1) or migration registry.

Run on a dedicated test installation. These commands install a debug test app
under the existing application ID, and the process-recovery runners kill
that app. Keep `--no-uninstall` between phases to retain the database sandbox.
Do not run other database journeys concurrently: they share the same test DB.

## Native plugin journeys

```sh
flutter test integration_test/database_migration_journey_test.dart -d <android-or-ios-device-id> --no-uninstall
```

This covers concurrent cold initialization, close/reopen persistence, adoption
of a pre-ledger v1 database, creation failure/retry, a partially completed
multi-version upgrade, rollback failure/retry, automatic downgrade on reopen,
and reapplying a rolled-back version. Checks include ledger ordering,
`user_version`, exact preservation of a profile, foreign-key enforcement,
`foreign_key_check`, and `integrity_check`. Ordinary failures deliberately
write data before throwing, proving transaction rollback on the native plugin.

## Android process termination and recovery

With Flutter and `adb` on PATH, run:

```sh
bash tool/test_android_database_migrations.sh <android-device-id>
```

Set `ADB` to the platform-tools `adb` executable if needed. The runner first
runs the native journeys above, then tests interruption during initial schema
creation, upgrade, and rollback. Each interruption phase completes SQL writes
inside an open transaction, emits a unique readiness marker, and waits. The
host waits for that marker before calling `adb shell am force-stop`; an
unsuccessful Flutter invocation here is expected. Recovery must pass in a new
process. A timeout, missing readiness marker, failed force-stop, or failed
recovery fails the runner. Logs remain in the printed temporary directory.

Recovery inspects the existing test database *before* `DatabaseHelper` runs:
uncommitted DDL/data and ledger entries must be absent, the previous schema
version must remain, and previously committed profile data must match the
per-run fixture. It then retries through `DatabaseHelper`, checking the final
schema, ledger, profile, and SQLite integrity. A killed process cannot write a
`failed` ledger row; these cases differ from the exception-based journeys.

After a failed/interrupted host run, remove only the test fixtures with:

```sh
flutter test integration_test/database_migration_journey_test.dart -d <android-device-id> --no-uninstall --dart-define=MIGRATION_PHASE=cleanup
```

Record model, Android API, and outcomes when running this suite. Repeat on the
oldest supported Android API and a current API before release. These tests
exercise process death and SQLite journal recovery, not power loss, OS upgrade,
or APK downgrade compatibility.

## iOS simulator process termination and recovery

With Xcode command-line tools and Flutter on PATH, boot a dedicated iOS simulator
and pass its concrete UDID (from `xcrun simctl list devices`):

```sh
xcrun simctl boot <ios-simulator-udid>
xcrun simctl bootstatus <ios-simulator-udid> -b
bash tool/test_ios_database_migrations.sh <ios-simulator-udid>
```

The runner executes the same five native plugin journeys, then interrupts initial
creation, upgrade, and rollback. After each unique readiness marker it resolves
the exact app bundle's PID through the selected simulator's launchd and sends
`SIGKILL`. It verifies that the process exited before starting recovery in a new
process, retaining the sandbox with `--no-uninstall`. Each recovery checks the
pre-migration schema, ledger, version, committed profile fixture, and SQLite
integrity, then retries the interrupted operation. The interrupted Flutter run
must fail; every recovery must pass. Missing markers, ambiguous/missing PIDs,
surviving processes, and recovery failures fail the runner. Logs remain in the
printed temporary directory. The final cleanup phase deletes only
`integration_test.db`.

After a failed run, clean up with:

```sh
flutter test integration_test/database_migration_journey_test.dart -d <ios-simulator-udid> --no-uninstall --dart-define=MIGRATION_PHASE=cleanup
```

Record simulator model, iOS runtime, and outcomes. This runner requires a simulator;
the ordinary native plugin journeys also run on a signed physical iOS test device.
Simulator `SIGKILL` covers abrupt process death and SQLite journal recovery.
Physical-device termination, background suspension, protected-data availability
while locked, jetsam, power loss, iOS upgrades, and app-binary downgrade
compatibility remain separate release checks.
