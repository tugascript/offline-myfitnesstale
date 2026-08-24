# My Fitness Tale: Delivery Plan

Last updated: 21 August 2026 on `codex/beta-device-journeys` (base commit
`5334650`). See [PROJECT_STATE.md](PROJECT_STATE.md) for the code-grounded
snapshot, architecture, and verification results.

## Product direction

The next target is a reliable local-first beta for one user on Android and
iOS. The main fitness flows exist, visible navigation dead ends have been
removed, and onboarding now commits atomically. The remaining beta work is
local data recovery and release configuration. The complete routed journey
suite now passes on the configured Android and iOS simulators; physical-device
and release-build checks remain later release work.

Cloud fitness-data sync, social features, broad analytics, and production
subscriptions should wait until the local lifecycle is reliable and the main
journeys are covered end to end.

## Decisions already made

### Pre-release database policy

The app has not been published, so schema version 2 is the development
baseline. Existing development databases may be cleared and recreated after a
schema change. A version-1-to-version-2 migration is intentionally not planned
or tested.

Before the first external beta:

- verify a fresh install creates the expected schema and seed data;
- declare that build's schema as the first user-data compatibility baseline;
- require an ordered migration and upgrade fixture for every later schema
  version;
- stop using destructive resets for tester or user databases.

### Navigation dead ends

The navigation-dead-ends slice is complete:

- Activity is a hub for workout history, exercise progress, weight history,
  and plan history;
- Exercise Progress is routed, bounded, unit-aware, alphabetized, and opens the
  implemented exercise-record route;
- workout-plan execution history has a read-only paginated summary screen;
- dashboard Reminders opens persisted preferences and discloses that delivery
  is not scheduled;
- premium-locked flows explain that purchases are unavailable and expose only
  working exit actions.

### Subscription behavior for the beta

Subscriptions are deferred. No visible action should call the missing
RevenueCat/native bridge. Existing entitlement services, Cubits, guards, plan
limits, and debug controls remain in the repository for later development, but
the beta must describe premium purchasing as unavailable.

### Atomic onboarding

The onboarding-atomic-recovery slice is complete:

- equipment, exercises, profile, settings, reminders, optional workouts, and
  the standard plan are created in one SQLite transaction;
- setup is marked completed only as the final database write;
- a failed stage rolls back every row from that attempt and the unchanged form
  can be submitted again;
- a completed snapshot is returned idempotently without changing its IDs,
  settings, or seed counts;
- inconsistent databases from older unpublished builds show clear-app-data
  guidance under the pre-release reset policy.

### Beta device journeys

The beta-device-journeys slice is complete on the current simulator matrix:

- five `integration_test` files cover seven fresh-install, navigation,
  persistence, CRUD, workout, and plan journeys;
- `MyApp` accepts an optional router so each journey uses an isolated router;
- journeys use a dedicated `integration_test.db`; fresh-install scenarios
  delete only that file, restart scenarios reopen it, and teardown removes it
  before restoring production database configuration;
- the deletion API refuses to run while the production `app.db` is selected,
  preventing device tests from erasing an installed user's local history;
- all six dashboard actions, all four bottom destinations, and all four
  Activity cards reach their intended screens;
- narrow-phone, enlarged-text, and narrow workout-column smoke tests pass;
- the full suite passes on Android 15/API 35 and iOS 18.5.

The journeys also fixed defects in root-route deletion/navigation, live-workout
exit navigation, weight-goal cache clearing, settings updates on iOS, narrow
muscle headings, and the empty weight-goal layout. Runtime-downloaded Google
fonts were replaced by bundled assets so device tests and the app do not depend
on font-network availability.

## Update now

Work in this order. Each item should ship with the tests in its acceptance
criteria.

### P1. Add local backup and restore

This is the next product branch: `codex/local-backup-restore`.

The app is local-first and stores irreplaceable history, but has no export or
recovery path.

- Define a versioned export format.
- Export/import profile, settings, exercises, workouts, records, weights,
  goals, plans, and plan execution records.
- Validate imported data before replacing live data and make failure
  recoverable.

Acceptance criteria:

- a round trip preserves representative user data and relationships;
- invalid or incompatible files leave the current database unchanged;
- the export format and compatibility policy are documented.

### P1. Decide whether reminders should deliver notifications

Reminder toggles now honestly represent saved preferences only. If delivery is
required for beta, implement local scheduling, rescheduling, cancellation,
permission recovery, time-zone behavior, and restart persistence. Otherwise,
keep the current wording and defer notification delivery.

### P1. Consolidate plan date/progress logic

Move duplicated workout-plan date mapping and progress calculations into a
tested domain helper shared by dashboard and active-plan views. Break up
`WorkoutPlanService` and `WorkoutPlanRecordService` only where this work makes
the relevant transactions and invariants clearer.

## Test now

### Automated baseline

Run before and after every slice:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
dart analyze
flutter test
git diff --check
```

Beta-device-journeys verification, last refreshed on 21 August 2026:

```text
dart format --output=none --set-exit-if-changed lib test integration_test
  339 files formatted with no pending changes

dart analyze
  No issues found

flutter test
  97 tests passed

flutter test integration_test -d emulator-5554
  7 journeys passed in 3m56s
  Medium_Phone_API_35, Android 15 / API 35

flutter test integration_test \
  -d CB4D3190-72FB-4D34-A136-1352A1EB507B
  7 journeys passed in 3m41s
  iPhone 16 Pro, iOS 18.5
```

The seven device journeys cover onboarding with optional workouts disabled and
enabled; bottom navigation; dashboard and Activity actions; profile, units,
theme, and reminder persistence; weight records and goals; equipment,
exercises, and exercise records; workout creation/editing, live
completion/cancellation/resume, and manual history; and plan
creation/editing/start/progress, in-progress active-plan restart, scheduled
live/manual workouts, and history. The harness recreates the router and
database connection for restart checks.

The host suite also creates a sentinel production `app.db`, selects and deletes
the integration database, and verifies the sentinel file and row are unchanged.
It separately verifies that integration deletion throws while production is
selected.

After the full-suite runs, the strengthened active-plan restart journey was
rerun on both targets and passed in 32 seconds on Android and 24 seconds on
iOS.

A separately installed production-entry debug build was also terminated and
cold-launched on both simulators. Android completed onboarding interactively;
iOS used the same verified onboarding database as a test snapshot because
`simctl` has no tap/type command. Both cold launches skipped onboarding and
loaded the persisted Home state. The interactive iOS integration journeys
independently verified profile/settings, records, workouts, and plans.

Platform findings:

- iOS Cupertino transitions required the harness to wait until incoming routes
  were fully interactive;
- slower iOS settings writes exposed that `ProfileView` replaced its complete
  subtree while saving, collapsing Settings; loaded content now stays mounted;
- iPhone width exposed a 1.1-pixel muscle-heading overflow, now covered by a
  narrow-column regression test;
- Android's emulator guest froze once during verification and was cold-booted;
  this was an ADB/emulator failure before any test handshake, not an app failure;
- a normal multi-ABI Android debug build encountered HTTP 403 while fetching
  unused engine artifacts; the arm64 production-entry build for the configured
  emulator succeeded. Release builds and all production ABIs remain separate
  release work.

Add these suites next:

- import/export round-trip, malformed-file, incompatible-version, rollback,
  relationship, and foreign-key tests in the backup branch;
- broader accessibility semantics and screen-reader checks before release;
- entitlement HTTP/cache/Cubit tests before subscription work resumes;
- release-build and physical-device checks after identifiers/signing are real.

Database upgrade fixtures begin only after the first external beta baseline is
declared.

### Later physical/release smoke matrix

The emulator/simulator matrix above satisfies the current device-level P0.
Repeat these checks on physical Android and iOS hardware before release:

1. Fresh install: onboard with seed workouts off, clear app data, then onboard
   with seed workouts on.
2. Bottom navigation: visit Home, Plans, Activity, and Profile; open all four
   Activity destinations and return safely.
3. Dashboard: open every quick action; verify Reminders opens saved preferences
   and shows the no-delivery disclosure.
4. Profile/settings: edit profile, switch units and theme, change both reminder
   toggles, restart, and verify persistence.
5. Weight: create, edit, delete, filter, inspect chart points, and manage a goal.
6. Exercises/equipment: search/filter, favorite, create, edit, delete, log
   exercise records, and verify Exercise Progress in both kg and lb.
7. Workouts: create/edit a basic workout; start, log decimal weight and reps,
   complete, cancel, resume, and edit manual history.
8. Plans: create/edit a schedule, start it, launch and manually log scheduled
   workouts, verify missed days and progress boundaries, and inspect completed,
   abandoned, and in-progress history summaries.
9. Premium-unavailable states: reach the free plan limit and open an advanced
   workout as a free user; verify there is no purchase/restore action and every
   exit works.

## Release readiness

Before the first external beta:

- keep the passing Android/iOS simulator journeys in the pre-merge baseline;
- establish the first non-destructive database migration baseline;
- add CI for formatting, analysis, Flutter tests, and the backend TypeScript
  build only if the backend remains in scope;
- replace `com.example.myfitnesstale`, configure real Android/iOS signing, and
  verify release builds;
- add crash reporting, a privacy/data-retention statement, store assets, and an
  accessibility review;
- complete local export/import on `codex/local-backup-restore`, or explicitly
  limit the beta to disposable data.

## Definition of done for each change

A change is complete when behavior is implemented, failure and empty states
are handled, automated tests cover the new invariant, Android/iOS smoke results
are recorded where platform behavior differs, `PROJECT_STATE.md` is updated if
the capability or risk changed, and all baseline checks pass.
