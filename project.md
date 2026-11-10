# My Fitness Tale: Delivery Plan

Last aligned with [README.md](README.md) on 10 November 2026. For the
code-grounded implementation snapshot, see [PROJECT_STATE.md](PROJECT_STATE.md).

## Product objective

Build a reliable, private, local-first fitness companion. The first deliverable
is the Android and iOS mobile app; watch and cloud components come later.

The intended mobile product covers exercise progress, workouts and plans,
weight goals, meals and macros, and eventually a local-first AI trainer.
Gamification and social networking are outside the first major release.

## Delivery sequence

### Phase 1: complete and consolidate the mobile fitness features

The core exercise, workout, plan, weight, food, recipe, meal-plan, and macro-tracking
flows are implemented offline. The immediate goal is to consolidate shared domain
helpers and verify the complete mobile feature set before freezing the SQLite schema
for backup and release.

#### Completed foundation — Offline meal and macro tracking

The app now includes the local SQLite schema and end-to-end flows for foods, recipes,
versioned meal plans, meal-plan execution, weekly macro goals, and daily nutrition:

- weekly goals support flat targets and calorie-cycling day groups;
- the diary supports timestamped food, recipe, and standalone quick-add snapshots,
  water tracking, planned meals, and day/week/month views;
- nutrition mutations use local transactions and preserve immutable logged snapshots.

Remaining P1 work is verification and consolidation, not initial implementation:

- add device-journey coverage for nutrition and meal-plan execution;
- keep narrow-screen and 200% text-scale coverage current as shared widgets evolve;
- consolidate duplicated date, progress, and nutrition calculations where a tested
  domain helper can replace UI/repository duplication.

#### P1 — Consolidate workout-plan calculations

Move duplicated date mapping and progress calculations into a tested domain
helper shared by the dashboard and active-plan screens. Split the large plan
repositories only where doing so makes transactions and invariants clearer.

#### P1 — Decide reminder scope

The current switches persist preferences but do not deliver notifications.
Either keep that honest wording for the beta or implement scheduling,
rescheduling, cancellation, permissions, time-zone handling, and restart
persistence with device coverage.

### Phase 2: beta-safety, backup, and release hardening

With the full mobile feature set and SQLite data model now implemented, establish data
preservation and release readiness:

#### P2 — Add local backup and restore

Deferred to P2 so the complete mobile schema, now including meals and macros, can be
stabilized before defining the serialization format, avoiding migration churn on
disposable pre-beta schemas.

The app stores irreplaceable history; implement the recovery path before release:

- Define a documented, versioned export format covering profile/settings, equipment,
  exercises, workouts, records, weights, goals, plans, plan-execution history, and
  meals/macros.
- Validate the complete import before replacing live data.
- Make failed imports recoverable and leave the current database unchanged.

Acceptance criteria:

- a round trip preserves representative data and relationships across all feature domains;
- malformed and incompatible files do not modify the live database;
- rollback, foreign-key, and format-version behavior is tested;
- the compatibility policy is documented.

#### P2 — Complete release configuration

- replace placeholder Android/iOS identifiers and configure signing;
- verify release builds on both platforms;
- run the journey matrix on physical Android and iOS devices;
- add accessibility and screen-reader checks;
- document privacy, data retention, and the release process;
- add crash reporting and store assets;
- add CI for formatting, analysis, and host tests.

#### Additional Phase 2 features

1. Design a privacy-preserving local AI trainer with explicit model, hardware,
   safety, and update constraints.
2. Expand analytics only where they support actionable training decisions.

### Phase 3: extend the product ecosystem

These are separate products, not requirements for the first mobile release:

1. an Apple Watch and Wear OS workout companion;
2. an identity and developer-log service;
3. optional encrypted backup and cross-device sync;
4. subscription verification and AI model distribution services.

Cloud fitness-data sync should remain optional so the core experience stays
local-first.

## Decisions already made

### Local-first is the default

Implemented mobile flows must work without a backend or account. All offline
features are completely free and unlocked. Future network features should be
optional and must not silently weaken local ownership.

### Pre-release database policy

The current development schema is version 1 and the app has not been released.
Development databases may be cleared after schema changes. The first external
beta establishes the compatibility baseline; after that, every schema change
must include an ordered migration, upgrade fixtures, data-preservation checks,
and foreign-key validation.

### Onboarding must remain atomic

Profile, settings, reminders, seed data, optional workouts, and the standard
plan are created in one SQLite transaction. Completion is written last, failed
attempts roll back, and retrying must not create duplicates.

### Device-test data must stay isolated

Integration journeys use `integration_test.db`. Test setup may delete only that
database and must restore production configuration during teardown.

## Verification baseline

Run before and after each delivery slice:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
dart analyze
flutter test
git diff --check
```

The latest recorded full verification is from 21 August 2026:

```text
dart analyze
  No issues found

flutter test
  97 tests passed

flutter test integration_test -d emulator-5554
  7 journeys passed in 3m56s (Android 15 / API 35)

flutter test integration_test -d CB4D3190-72FB-4D34-A136-1352A1EB507B
  7 journeys passed in 3m41s (iPhone 16 Pro / iOS 18.5)
```

These are historical results, not a claim that the current working tree has
been reverified. See [PROJECT_STATE.md](PROJECT_STATE.md) for coverage details.

## Physical-device and release smoke matrix

Before release, verify:

1. onboarding with starter workouts both disabled and enabled;
2. all bottom-navigation, dashboard, and Home quick-action destinations;
3. profile, theme, units, and reminder preferences after restart;
4. weight records, chart points, and weight-goal CRUD;
5. equipment, exercises, filters, favorites, and exercise records;
6. workout creation/editing, live completion/cancellation/resume, and history;
7. workout- and meal-plan creation/editing, scheduling, progress, restart, and history;
8. foods, recipes, macro goals, diary logging, water, and day/week/month nutrition views;
9. narrow layouts, large text, screen readers, and interrupted app lifecycles;
10. backup/export followed by a verified restore on a clean installation.

## Definition of done

A change is complete when its behavior, empty states, and failure states are
handled; tests cover the new invariant; platform-specific behavior is checked
where relevant; documentation is updated when capability, risk, or priority
changes; and the standard verification commands pass.
