# My Fitness Tale: Delivery Plan

Last updated: 13 August 2026. This plan is based on repository commit
`e816027`. See [PROJECT_STATE.md](PROJECT_STATE.md) for the code-grounded
snapshot, architecture, and verification results.

## Product direction

The clearest next target is a reliable local-first beta for one user on Android
and iOS. The core fitness flows already exist; the project now needs data
safety, removal of dead ends, end-to-end verification, and an explicit decision
about whether subscriptions belong in the first beta.

Cloud fitness-data sync, social features, and broad analytics should wait until
the local data lifecycle is safe and the main user journeys are covered by
tests.

## Update now

Work in this order. Each item should ship with the tests listed in its
acceptance criteria.

### P0. Protect existing data with a real database migration

The database declares schema version 2, but `DatabaseHelper._onUpgrade` is a
no-op. A user upgrading a version-1 database does not receive the current
schema, including the entitlement table.

- Reconstruct and document the version-1 to version-2 schema delta.
- Implement the migration as an ordered, transactional step.
- Keep future migrations additive and version-specific rather than rerunning
  the complete create script.
- Add a version-1 fixture containing representative profile, exercise,
  workout, history, weight, and plan data.

Acceptance criteria:

- opening the version-1 fixture upgrades it to version 2 without data loss;
- all expected tables, columns, indexes, and foreign keys exist afterward;
- `PRAGMA foreign_key_check` returns no violations;
- running the current app against a fresh database still creates the same
  schema;
- a failed migration rolls back cleanly.

### P0. Remove user-facing navigation dead ends

Several visible actions currently lead nowhere or to `NotFoundView`.

- Replace the Activity tab placeholder with a small history hub, or temporarily
  remove the tab until that hub exists.
- Either implement workout-plan history or hide its button. The current
  `/workout-plans/:id/history` destination is not registered.
- Point exercise-progress navigation at the existing
  `/exercises/:id/records` route. The standalone `ExerciseProgressView` is not
  registered and currently pushes a nonexistent `/exercises/:id/history`
  route.
- Make the dashboard Reminders action open the relevant profile settings, or
  remove it; its callback is currently empty.
- Make the workout-plan upgrade action perform a real action or label the
  entitlement feature as unavailable in this build.

Acceptance criteria:

- every visible navigation/action control either performs its labelled action
  or is intentionally disabled with an explanation;
- route-level widget tests cover every registered route and all dynamic ID
  parsing failures;
- an integration test taps through each bottom-navigation item and dashboard
  quick action without reaching an unexpected Not Found screen.

### P0. Decide the entitlement scope

The entitlement code is a development prototype, not a production purchase
path. Purchase and restore call an unimplemented native method channel, the
default identity is anonymous, and the Firebase Functions prototype does not
enforce authentication or App Check in code. Its “verification token” is an
unsigned base64 placeholder, while the mobile guard checks only that it is
non-empty and recent.

Choose one path before expanding premium behavior:

1. **Defer subscriptions for the beta.** Put premium UI behind a build flag,
   remove non-working purchase calls, and define which advanced features remain
   available during the beta.
2. **Finish subscriptions.** Integrate the RevenueCat SDK/native bridge, use a
   stable authenticated user identity, deploy a protected sync service, define
   signed/verified entitlement evidence, configure release environments, and
   add store sandbox tests for purchase, restore, expiry, billing issue, and
   offline grace.

Whichever path is chosen, keep mutation checks in the Cubit/service boundary so
UI-only gating cannot grant premium writes.

Acceptance criteria:

- no production-visible button calls a missing platform plugin;
- free plan limits and advanced-workout mutations behave consistently after an
  app restart and while offline;
- entitlement cache, refresh, expiry, grace, purchase, and restore behavior are
  covered at service/Cubit level;
- no locally editable, unsigned value is treated as production purchase proof.

### P0. Make onboarding atomic and recoverable

Onboarding currently performs equipment, exercise, profile, settings,
reminder, optional workout, and plan creation across several service calls. A
midway failure can leave partially seeded data and no explicit resume or retry
strategy.

- Move bootstrap orchestration behind one transactional or explicitly
  idempotent service operation.
- Define recovery for a failure before and after profile creation.
- Make repeated onboarding attempts safe.
- Keep the optional seed behavior: 25 equipment entries, 86 exercises, and,
  when selected, 16 workouts plus one 16-week plan.

Acceptance criteria:

- injected failures at each bootstrap stage do not leave an unusable profile;
- retrying produces no duplicates and completes the missing work;
- tests cover onboarding with and without the optional workouts.

## Complete the beta experience

After P0 is stable:

1. Build Activity as a unified entry point for workout history, exercise
   records, and weight history. Reuse the existing feature views rather than
   duplicating queries.
2. Clarify reminders. The app currently saves preferences and requests initial
   permission but schedules no notifications. Either implement local
   scheduling/rescheduling/cancellation or rename the controls so they do not
   promise delivery.
3. Consolidate workout-plan date mapping and progress calculations into a
   tested domain helper shared by the dashboard and active-plan views.
4. Add local export/import and a documented backup/restore format before any
   cloud sync work.
5. Finish exercise/equipment discovery gaps, especially equipment filtering,
   only after the main journeys above are reliable.
6. Break up the largest orchestration services (`WorkoutPlanService` and
   `WorkoutPlanRecordService`) as touched, keeping transactions and invariants
   close to the operations they protect.

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

Add these suites next:

- database creation and version-1 to version-2 migration tests;
- router/navigation tests for Activity, plan history, reminders, exercise
  records, invalid IDs, and unknown paths;
- onboarding success, failure, rollback/retry, and duplicate-seed tests;
- entitlement service/Cubit tests with fake HTTP, fake identity, and fake
  RevenueCat gateways;
- route-level workout-plan tests that exercise Start/Resume, Complete, Cancel,
  and manual Log from the active-plan screen;
- profile, exercise/equipment, weight-record, and weight-goal CRUD tests;
- accessibility smoke tests for text scaling, semantics, and narrow screens.

### Manual smoke matrix

Run on at least one Android device/emulator and one iOS simulator/device:

1. Fresh install: onboard with seed workouts off, then repeat after clearing
   app data with seed workouts on.
2. Profile/settings: edit profile, switch units and theme, restart, and verify
   persistence.
3. Weight: create, edit, delete, filter, inspect chart points, and manage a goal.
4. Exercises/equipment: search/filter, favorite, create, edit, delete, and log
   exercise records.
5. Workouts: create/edit a basic workout; start, log decimal weight and reps,
   complete, cancel, resume, and edit manual history.
6. Plans: create/edit a schedule, start it, launch and manually log scheduled
   workouts, verify missed days, and confirm day/week/plan progress boundaries.
7. Entitlements: verify the selected beta policy; if enabled, test free,
   premium, expired, billing-issue, grace, offline, purchase, and restore states.
8. Upgrade: install a build with a version-1 database, upgrade in place, and
   repeat the core read/write flows without clearing data.

### Release readiness after the beta flows pass

- Add CI for formatting, analysis, Flutter tests, and the backend TypeScript
  build if the backend remains in scope.
- Replace `com.example.myfitnesstale`, configure real Android/iOS signing, and
  verify release builds.
- Add crash reporting, a privacy policy/data-retention statement, store assets,
  accessibility review, and a small external beta.
- Treat import/export recovery as a launch requirement for irreplaceable local
  history.

## Definition of done for each change

A change is complete when behavior is implemented, failure and empty states are
handled, automated tests cover the new invariant, the Android/iOS smoke path is
recorded where platform behavior differs, `PROJECT_STATE.md` is updated if the
capability or risk changed, and all baseline checks pass.
