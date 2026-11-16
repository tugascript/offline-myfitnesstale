# Native secure-storage verification

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

For Android restore verification, after `seed`/`verify`, use the platform's
backup transport to back up and restore this test installation onto a clean
installation with fresh KeyStore keys. Test cloud backup and device transfer
separately, including legacy Android backup rules on API 30 or below. Do not
simulate restore by merely clearing the cache: that does not validate the rules.
After the actual restore, run:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall --dart-define=BACKUP_STORAGE_PHASE=restore
```

The SQLite row must remain, the cache must be absent, and writing, reading, and
clearing a new cached key must succeed. Inspect the backup payload to confirm
the four excluded preference files are absent. Finally remove only test fixtures:

```sh
flutter test integration_test/backup_storage_journey_test.dart -d <device-id> --no-uninstall --dart-define=BACKUP_STORAGE_PHASE=cleanup
```

The default journey does not prove process-relaunch or OS restore behavior;
those require the separate phases above. A skipped/unavailable transport is
unverified, not a successful restore check.
