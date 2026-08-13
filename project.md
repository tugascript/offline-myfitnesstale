# My Fitness Tale: Delivery Plan

Last updated: 14 August 2026 on `codex/onboarding-atomic-recovery` (base commit
`8d1c1a7`). See [PROJECT_STATE.md](PROJECT_STATE.md) for the code-grounded
snapshot, architecture, and verification results.

## Product direction

The next target is a reliable local-first beta for one user on Android and
iOS. The main fitness flows exist, visible navigation dead ends have been
removed, and onboarding now commits atomically. The remaining beta work is
device-level journey testing, local data recovery, and release configuration.

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

## Update now

Work in this order. Each item should ship with the tests in its acceptance
criteria.

### P0. Verify complete beta journeys on devices

The repository now has focused route and widget coverage, but the full
application lifecycle still needs device-level verification.

- Add an integration test that completes onboarding and visits every bottom
  navigation destination.
- Tap all dashboard quick actions and all four Activity cards.
- Exercise create/edit/history, workout live/manual history, weight, goals,
  and plan start/progress/history from their real routed screens.
- Run the smoke matrix on at least one Android emulator/device and one iOS
  simulator/device.

Acceptance criteria:

- no labelled control reaches an unexpected Not Found screen;
- app restart preserves profile, units, reminders, history, and active-plan
  state;
- narrow-screen and text-scaling smoke tests have no layout exceptions;
- Android and iOS results are recorded with any platform differences.

### P1. Add local backup and restore

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
dart format --output=none --set-exit-if-changed lib test
dart analyze
flutter test
git diff --check
```

Onboarding-atomic-recovery verification on 14 August 2026:

```text
dart analyze
  No issues found

flutter test
  83 tests passed
```

The slice adds coverage for core-only and optional-workout onboarding,
foreign-key-valid seed structure, rollback and retry after all eight stages,
duplicate-free idempotency, legacy partial-data guidance, Cubit loading/error
coordination, unchanged-form retry, and successful navigation after commit.
The previous Activity, routing, history, reminders, and premium-unavailable
coverage remains green.

Add these suites next:

- complete routed workout-plan tests for Start/Resume, Complete, Cancel, and
  manual Log;
- profile, exercise/equipment, weight-record, and weight-goal CRUD tests;
- full-app bottom-navigation and dashboard integration tests;
- import/export round-trip and invalid-input tests when backup work begins;
- accessibility smoke tests for text scaling, semantics, and narrow screens;
- entitlement HTTP/cache/Cubit tests before subscription work resumes.

Database upgrade fixtures begin only after the first external beta baseline is
declared.

### Manual smoke matrix

Run on at least one Android device/emulator and one iOS simulator/device:

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

- complete the P0 items above;
- establish the first non-destructive database migration baseline;
- add CI for formatting, analysis, Flutter tests, and the backend TypeScript
  build only if the backend remains in scope;
- replace `com.example.myfitnesstale`, configure real Android/iOS signing, and
  verify release builds;
- add crash reporting, a privacy/data-retention statement, store assets, and an
  accessibility review;
- provide local export/import, or explicitly limit the beta to disposable data.

## Definition of done for each change

A change is complete when behavior is implemented, failure and empty states
are handled, automated tests cover the new invariant, Android/iOS smoke results
are recorded where platform behavior differs, `PROJECT_STATE.md` is updated if
the capability or risk changed, and all baseline checks pass.
