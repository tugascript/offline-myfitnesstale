# My Fitness Tale: Current Project State

Last reviewed on `codex/beta-device-journeys` (base commit `5334650`) on
19 August 2026.

This is the code-grounded source of truth for what exists now. The forward plan
and test priorities are in [project.md](project.md).

## Snapshot

My Fitness Tale is a local-first Flutter fitness tracker for Android and iOS.
It has substantial profile, exercise, workout, history, weight, workout-plan,
and plan-execution functionality backed by SQLite. The known navigation dead
ends have been repaired and onboarding is atomic and retry-safe. It is suitable
for continued development and simulator beta testing. It is not release-ready
because local backup is absent, release identifiers/signing are placeholders,
physical-device checks remain, notification delivery is not implemented, and
subscriptions are intentionally unavailable.

Repository facts at this review:

- 311 Dart source files under `lib`;
- 25 SQLite tables in the current create schema;
- 89 seeded exercises and 25 seeded equipment entries;
- 16 optional seeded workouts and one 16-week seeded workout plan;
- 20 host test files with 86 passing tests;
- five integration-test files with seven passing journeys on both Android and
  iOS simulators;
- no repository CI configuration.

## What is implemented

| Area | Current behavior | Important caveat |
| --- | --- | --- |
| Onboarding and profile | Creates one local profile and persists settings/reminders in the same SQLite transaction as bootstrap data; marks setup complete last | Partial databases from older development builds are rejected with clear-app-data guidance rather than repaired |
| Seed data | Atomically seeds 25 equipment and 89 exercises; optionally seeds 16 workouts and the standard 16-week plan | A completed snapshot is idempotent; destructive reset remains the pre-beta policy for inconsistent legacy data |
| Activity | Provides entry cards for workout history, aggregate exercise progress, weight history, and workout-plan history | Workout and plan history require selecting their parent entity; there is no unified chronological timeline |
| Exercises | Paginated browse/search; muscle-group, difficulty, and favorite filters; create/edit/delete; equipment relationships; favorite state | Equipment filtering is still TODO; media values have no picker/upload workflow |
| Exercise records/progress | Create/edit/delete records; latest/history views; date filtering; estimated-max chart; aggregate progress sorted by exercise with kg/lb summaries | Aggregate progress intentionally reads only the most recent 1,000 records |
| Workouts | Reusable, versioned workouts; basic and advanced editors; alternatives, rep ranges, rest, and difficulty; create/edit/delete | Advanced mutations remain entitlement-gated; free users see an unavailable-in-this-build state rather than purchase actions |
| Live workout | Starts a workout record, logs numeric weight/reps, carries prior values within a set group, handles rest/progress, complete and cancel | Device coverage includes start, process-local resume, cancellation cleanup, completion, and history; OS interruption during an active timer remains a later physical-device case |
| Workout history | Lists/details records; manual completed-record creation; record editing and deletion | Activity opens the workout list because history is versioned per workout |
| Weight | Create/edit/delete records; latest value; date-range list/chart; metric/imperial conversion; tappable chart points | No import/export, backup, or broader analytics |
| Weight goals | Create/edit/delete; active goal and history; phase/status/date display | CRUD and restart persistence now have device coverage; broader analytics remain absent |
| Workout plans | Create/edit/delete schedules; start one active execution; map dates; show missed days/progress; start/resume or manually log scheduled workouts | Date/progress logic remains duplicated across UI and service layers |
| Plan history | Paginated read-only summaries filtered by plan, newest first, with status, local dates, version, and last reached position | Historical child-workout detail is intentionally outside the current scope |
| Settings/reminders | Saves both reminder toggles; dashboard opens a dedicated preferences route with the section expanded | No notification scheduling, delivery, rescheduling, or cancellation exists; the UI explicitly discloses this |
| Entitlements | Local snapshot, TTL/grace guard, three-plan free limit, advanced editor gating, mock server, and debug controls | No native RevenueCat bridge or production verification; purchase and restore actions are not exposed in locked flows |

## Navigation state

`GoRouter` is configured in `lib/src/utilities/app_router.dart`. The root uses an
`IndexedStack` with four working bottom-navigation destinations:

1. Home
2. Plans
3. Activity
4. Profile

The repaired public routes are:

- `/exercises/progress`;
- `/exercises/:id/records`;
- `/workout-plans/:id/history`;
- `/settings/reminders`.

`/exercises/progress` is registered before the dynamic exercise-ID route, so
`progress` cannot be parsed as an entity ID. Plan-history IDs use the same
integer validation behavior as other entity routes. Unknown locations and
invalid IDs still render `NotFoundView`.

Visible repaired actions remain:

- Exercise Progress cards open `/exercises/:id/records`;
- plan details use the registered plan-history route;
- dashboard Reminders opens Reminder Preferences;
- the plan-limit modal has a Close action and an unavailable explanation;
- the locked advanced-workout editor has only Back to Workouts.

## Architecture

| Layer | Current implementation |
| --- | --- |
| UI | Flutter Material widgets with custom responsive/layout components |
| Navigation | `go_router` with a flat route table, route constants, and parameter validation |
| State | Ten app-scoped `flutter_bloc` Cubits provided by `MyApp` |
| Persistence | `sqflite`, a generic `Repository<T>`, feature services, models, and DTOs |
| Charts | `fl_chart` for weight and exercise records |
| Platforms | Android and iOS project folders only; the app forces portrait at runtime |
| Entitlement development | Dart HTTP client, local cache/guard, Go mock server, and debug profile controls |
| Entitlement backend prototype | Firebase Functions/Firestore source under `backend/functions` |

`MyApp` accepts an optional router configuration so integration tests can
launch isolated app instances. The production fallback remains
`AppRouter.router`. Google Fonts runtime fetching is disabled and the used
Roboto Mono and Major Mono Display fonts are bundled under `assets/fonts`, so
startup and rendering do not depend on font-network access.

The usual feature flow is:

1. A model defines its SQLite table, mapping, creation, and `copyWith` behavior.
2. `Repository<T>` provides generic CRUD and query helpers.
3. A feature service validates input and coordinates related rows and
   transactions.
4. A Cubit exposes operation state and feature DTOs.
5. Views load route data; widgets render forms, lists, charts, and actions.

This is a convention rather than a strict dependency boundary. Most services
are singletons and Cubits construct them directly, so dependency replacement
in tests is often difficult. `ProfileCubit` now accepts an optional
`OnboardingService` for deterministic orchestration tests.
`WorkoutPlanService` and `WorkoutPlanRecordService` remain large orchestration
services.

### Data conventions

- Database IDs are integer primary keys.
- Date/times are generally stored as Unix seconds and exposed as `DateTime` in
  DTOs; plan-history summaries render local times.
- Weight is stored as integer grams and converted to kg/lb in the UI.
- Workouts and workout plans are versioned. History/execution rows retain the
  version from which they were created.
- `ProgressStatus` includes `in_progress`, `completed`, `skipped`, and
  `abandoned`.
- SQLite foreign-key enforcement is enabled in `onConfigure`.
- Several models use `value ?? oldValue` in `copyWith`, so nullable values may
  not be intentionally clearable unless that model uses an explicit sentinel.

## Onboarding invariants

`OnboardingService` owns one SQLite transaction with these ordered stages:

1. equipment;
2. exercises and equipment links;
3. profile;
4. system settings;
5. reminder preferences;
6. optional workouts;
7. optional standard plan;
8. `System.initialSetup = completed`.

The bulk seed and profile operations accept an optional shared transaction but
retain their standalone transaction behavior for existing callers. A failed
service `Result` or injected stage failure throws inside the outer transaction,
so SQLite rolls back the complete attempt. `ProfileCubit` exposes only loading
and error state until commit succeeds, then publishes the committed profile,
system, and reminders together.

A complete snapshot is idempotent: later onboarding calls return its existing
DTOs without changing settings or reseeding. Any partial profile or seed data
from older unpublished builds is treated as inconsistent and requires clearing
app data. The onboarding form remains populated after a failure and displays a
persistent explanation that the attempt saved no data.

## Device-journey harness and results

`integration_test/support/device_test_harness.dart` launches a fresh
`GoRouter`, deletes the development database for fresh-install scenarios, and
can close/reopen the database with a new widget tree while preserving data.
The delete operation is test-only; the existing non-destructive reset remains
available. Stable widget keys were added only where repeated labels or
icon-only controls made text interaction ambiguous.

The five device files contain seven journeys that cover:

- onboarding with optional workouts disabled and enabled;
- Home, Plans, Activity, and Profile plus all six dashboard actions and four
  Activity cards;
- profile editing and units, theme, and reminder persistence after restart;
- weight-record and weight-goal create/edit/delete/restart behavior;
- equipment, exercise, and exercise-record create/edit/delete/restart behavior;
- workout creation/editing, active-workout resume and cancellation, live
  completion, manual history, and restart persistence;
- plan creation/editing, schedule structure, start/progress, in-progress
  active-plan restart, scheduled live and manual workout completion, completed
  history, and restart persistence.

Responsive host tests cover a 320-by-568 logical viewport, 200% text scaling,
and the 180.2-pixel workout column that exposed an iPhone overflow.

Device results on 19 August 2026:

| Platform | Target | Result | Notes |
| --- | --- | --- | --- |
| Android | `Medium_Phone_API_35`, Android 15/API 35, arm64 | 7/7 passed in 3m56s | One emulator guest/ADB freeze occurred before a test handshake; a cold boot recovered it and the final full run passed |
| iOS | iPhone 16 Pro simulator, iOS 18.5 | 7/7 passed in 3m41s | Longer Cupertino transitions exposed route-settling and settings-subtree bugs that are now fixed |

The plan journey was then strengthened with an in-progress restart assertion
and passed again in 32 seconds on Android and 24 seconds on iOS.

Normal production-entry debug builds were also terminated and relaunched on
both simulators. Android onboarded interactively and cold-launched back to
Home. Because standard `simctl` cannot tap/type, iOS received that verified
onboarding database as a test snapshot before a terminate/relaunch; it also
returned to persisted Home. Interactive iOS integration journeys independently
verified its profile/settings and fitness-data persistence.

Reproducible defects fixed during these journeys:

- deleting equipment or an exercise from a root-routed detail screen now
  navigates to its list instead of popping an empty navigator;
- live completion and cancellation safely return to workout details even when
  the active-workout route is the root;
- deleting a weight goal clears the cached active goal;
- the empty weight-goal history has bounded layout on phone screens;
- profile settings stay mounted while an update is being persisted, retaining
  the expanded Settings section on iOS;
- muscle headings flex within narrow workout columns;
- device tests wait for Cupertino routes to become fully interactive.

## Workout-plan and history invariants

Reusable plan templates live in:

- `workout_plans`;
- `workout_plan_weeks`;
- `workout_plan_days`;
- `workout_plan_workouts`.

Plan execution uses the corresponding `*_records` tables. Only one plan record
is intended to remain `in_progress`; starting another abandons the previous
one.

The active-plan screen expands ranged week templates into concrete week
instances. An eligible scheduled workout can start/resume live tracking or open
the manual history form. In both cases,
`workout_plan_workout_records.workout_record_id` must refer to an actual workout
history row, not a reusable workout template. Day, week, and plan completion
propagate only after all required child workouts are completed or skipped.
Cancelling a live workout removes the plan association and deletes its
unfinished workout-history row.

`WorkoutPlanRecordCubit.getWorkoutPlanRecords` now exposes the service query to
the UI. Offset zero replaces the current history; later offsets append. Its
pagination value retains the plan/status filters and includes them in equality.

## Entitlement state

The mobile code caches an entitlement row and permits premium behavior only
when `EntitlementGuard` sees premium status, a non-empty verification token,
and a sufficiently recent server verification. It falls back to a 24-hour
offline grace window. Free users are limited to three user-created workout
plans, and complex workout mutations recheck access outside the UI.

This is not a production subscription implementation:

- `MethodChannelRevenueCatGateway` has no Android/iOS handler or RevenueCat
  dependency;
- the default identity falls back to `anonymous-local`;
- the Functions prototype does not enforce authentication or App Check in its
  code;
- the generated verification token is unsigned and mobile verification checks
  only presence and freshness.

Purchase and restore calls remain available behind the service/Cubit API for
future work, but current locked user flows do not call them and explicitly say
premium is unavailable in this build.

## Database policy

The current create schema is version 2. Because the app has never been
published, development databases are disposable and may be cleared after
schema changes. The no-op version-1-to-version-2 upgrade path is not a current
user-data risk and no migration is planned for it.

The first external beta establishes the non-destructive compatibility
baseline. After that point, every schema increment must include ordered
migrations, representative upgrade fixtures, data-preservation checks, and
foreign-key validation.

## Automated verification at this review

The following checks were run from the repository root on 19 August 2026:

```text
dart format --output=none --set-exit-if-changed lib test integration_test
  338 files formatted with no pending changes

dart analyze
  No issues found

flutter test
  86 tests passed

flutter test integration_test -d emulator-5554
  7 journeys passed in 3m56s

flutter test integration_test \
  -d CB4D3190-72FB-4D34-A136-1352A1EB507B
  7 journeys passed in 3m41s

git diff --check
  No whitespace errors
```

Coverage now includes:

- onboarding with and without optional workouts;
- all eight onboarding failure points, complete rollback, retry without
  duplicates, completed-snapshot idempotency, foreign-key validation, and
  legacy partial-data reset guidance;
- onboarding Cubit loading/error coordination, stale-error clearing,
  unchanged-form retry, optional-workout choices, and post-commit navigation;
- entitlement guard TTL/grace decisions;
- workout-set batch mutation and rollback;
- workout-plan structure/versioning and execution lifecycle;
- Activity cards and destinations;
- router precedence, new routes, invalid plan-history IDs, and unknown paths;
- Exercise Progress bounded layout, sorting, kg/lb output, coherent personal
  best, record navigation, and aggregate reload after returning from details;
- plan-history replacement/append pagination, retained filters, newest-first
  order, cross-plan cache isolation, loading/empty/error states, visible
  background request failures, and all progress statuses;
- reminder disclosure, expanded toggles, persistence calls, and dashboard
  navigation;
- premium-locked flows with no upgrade, subscribe, or restore controls;
- complete bottom-navigation, dashboard, and Activity routed journeys;
- profile/settings/reminders, weight/goal, equipment/exercise/record,
  workout/live/manual-history, and plan/execution/history device journeys;
- narrow viewport, 200% text scaling, and narrow workout-column layout.

Important untested areas:

- import/export because the feature does not exist;
- entitlement HTTP/cache behavior and future store integration;
- physical Android/iOS hardware, release builds/signing, screen-reader
  semantics, and backend TypeScript build;
- notification delivery, scheduled timezone changes, and permission recovery;
- OS termination while an active workout timer or plan workout is in progress.

## Other release blockers and limitations

- There is no fitness-data cloud sync, account system, import/export, or local
  backup/restore.
- Reminder preferences do not produce notifications.
- Exercise Progress intentionally aggregates at most 1,000 recent records.
- Plan history does not expose historical child-workout detail.
- Media fields exist in models, but exercise media has no picker/upload/storage
  workflow.
- Android and iOS still use `com.example.myfitnesstale`; Android release builds
  use debug signing.
- There is no automated CI, crash reporting, privacy policy, or documented
  release process.

## Local development

Baseline checks:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
dart analyze
flutter test
git diff --check
```

Development databases may be cleared while the app remains unpublished. Do not
carry this policy past the first external beta.

Optional entitlement mock:

```sh
go run tools/entitlement_mock_server.go
flutter run \
  --dart-define=ENTITLEMENT_API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=ENTITLEMENT_DEBUG_APP_USER_ID=dev-user
```

Use `http://10.0.2.2:8080` from an Android emulator. A USB-connected Android
device can use `127.0.0.1` after `adb reverse tcp:8080 tcp:8080`.

## Next work

Create `codex/local-backup-restore` from clean `master` and implement a
versioned, validated, transactional export/import path before treating device
data as durable. Reminder delivery and plan date/progress consolidation remain
subsequent P1 decisions. Physical-device, identifier/signing, and release-build
verification remain release checks. The ordered plan is in
[project.md](project.md).
