# My Fitness Tale: Current Project State

Last reviewed against repository commit `e816027` on 13 August 2026.

This is the code-grounded source of truth for what exists now. The forward plan
and test priorities are in [project.md](project.md).

## Snapshot

My Fitness Tale is a local-first Flutter fitness tracker for Android and iOS.
It has substantial profile, exercise, workout, history, weight, and workout-plan
functionality backed by SQLite. It is suitable for continued development and
manual testing, but it is not release-ready because database upgrades are not
implemented, some visible navigation paths are dead ends, automated coverage is
uneven, and the purchase/entitlement path is prototype-only.

Repository facts at this review:

- 307 Dart source files under `lib`;
- 25 SQLite tables in the current create schema;
- 86 seeded exercises and 25 seeded equipment entries;
- 16 optional seeded workouts and one 16-week seeded workout plan;
- 9 automated test files containing 41 passing tests;
- no repository CI configuration.

## What is implemented

| Area | Current behavior | Important caveat |
| --- | --- | --- |
| Onboarding and profile | Creates one local profile; persists height, gender, birthday, units, theme, notification preference, and reminder toggles | Bootstrap spans multiple service calls and is not atomic or covered by tests |
| Seed data | Always seeds equipment and exercises; optionally seeds workouts and the standard plan | Failure recovery and duplicate-safe retry are not defined |
| Exercises | Paginated browse/search; muscle-group, difficulty, and favorite filters; create/edit/delete; equipment relationships; favorite state | Equipment filtering is still TODO; media values have no picker/upload workflow |
| Equipment | Browse/search and create/edit/delete | No favorites and no equipment-based exercise filter |
| Exercise records | Create/edit/delete records; latest/history views; date filtering; estimated-max chart with tappable points | The separate aggregate `ExerciseProgressView` is unreachable and uses broken history routes |
| Workouts | Reusable, versioned workouts; basic standard-set editor; advanced set editor; alternatives, rep ranges, rest, and difficulty; create/edit/delete | Advanced mutations are entitlement-gated; versioning logic and service orchestration remain complex |
| Live workout | Starts a workout record, logs set exercises with numeric weight/reps, carries prior values within a set group, handles rest/progress, complete and cancel | Full screen-level lifecycle is not covered by integration tests |
| Workout history | Lists/details records; manual completed-record creation; record editing and deletion | No unified Activity entry point |
| Weight | Create/edit/delete records; latest value; date-range list/chart; metric/imperial conversion; tappable chart points | No import/export, backup, or broader analytics |
| Weight goals | Create/edit/delete; active goal and history; phase/status/date display | Goal flows have no automated coverage |
| Workout plans | Create/edit/delete versioned multi-week schedules; validate week/day structure; start one active execution; map dates; show missed days and progress; start/resume or manually log scheduled workouts | Plan History button routes to an unregistered path; date/progress logic is duplicated across UI/service layers |
| Settings/reminders | Saves reminder toggles and requests notification permission during onboarding | No notification scheduling, delivery, rescheduling, or cancellation exists; dashboard Reminders action is empty |
| Entitlements | Local SQLite snapshot; TTL/grace guard; three-plan free limit; advanced workout editor gating; Go mock server; Firebase Functions prototype | No native RevenueCat bridge, stable authenticated identity, secure token verification, or production deployment configuration |

## Navigation state

`GoRouter` is configured in `lib/src/utilities/app_router.dart`. The root uses an
`IndexedStack` with four bottom-navigation destinations:

1. Home
2. Plans
3. Activity
4. Profile

Home, Plans, and Profile render real features. Activity renders
`NotFoundView`. Feature-specific routes for equipment, exercises, exercise
records, workouts, workout records, weights, goals, and active plans are reached
from dashboard or detail actions.

Known route/action defects:

- `/workout-plans/:id/history` is linked from plan details but is not registered
  and has no view;
- `ExerciseProgressView` declares `/exercises/progress` but the router never
  registers it;
- that view links to `/exercises/:id/history`, while the implemented record
  route is `/exercises/:id/records`;
- the dashboard Reminders card has an empty callback;
- the workout-plan-limit “Upgrade to Premium” button only closes its modal.

## Architecture

| Layer | Current implementation |
| --- | --- |
| UI | Flutter Material widgets with custom responsive/layout components |
| Navigation | `go_router` with a flat route table and route parameters |
| State | Ten app-scoped `flutter_bloc` Cubits provided by `MyApp` |
| Persistence | `sqflite`, a generic `Repository<T>`, feature services, models, and DTOs |
| Charts | `fl_chart` for weight and exercise records |
| Platforms | Android and iOS project folders only; the app forces portrait at runtime |
| Entitlement development | Dart HTTP client, local cache/guard, Go mock server, debug profile controls |
| Entitlement backend prototype | Firebase Functions/Firestore source under `backend/functions` |

The usual feature flow is:

1. A model defines its SQLite table, mapping, creation, and `copyWith` behavior.
2. `Repository<T>` provides generic CRUD and query helpers.
3. A feature service validates input and coordinates related rows and
   transactions.
4. A Cubit exposes operation state and feature DTOs.
5. Views load route data; widgets render forms, lists, charts, and actions.

This is a convention rather than a strict dependency boundary. Services are
singletons and Cubits construct them directly, so dependency replacement in
tests is difficult. `WorkoutPlanService` is over 2,200 lines and
`WorkoutPlanRecordService` is over 1,300 lines; both combine queries,
validation, mapping, and lifecycle orchestration.

### Data conventions

- Database IDs are integer primary keys.
- Date/times are generally stored as Unix seconds and exposed as `DateTime` in
  DTOs.
- Weight is stored as integer grams and converted to kg/lb in the UI.
- Workouts and workout plans are versioned. History/execution rows retain the
  version from which they were created.
- `ProgressStatus` includes `in_progress`, `completed`, `skipped`, and
  `abandoned`.
- SQLite foreign-key enforcement is enabled in `onConfigure`.
- Several models use `value ?? oldValue` in `copyWith`, so nullable values may
  not be intentionally clearable unless that model uses an explicit sentinel.

## Workout-plan and history invariants

Reusable plan templates live in:

- `workout_plans`
- `workout_plan_weeks`
- `workout_plan_days`
- `workout_plan_workouts`

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

Existing tests cover the record linkage, status propagation, relative-day
mapping, replacement of the active plan, completed-workout lifecycle, skipped
workouts, and multi-workout completion boundaries. They do not tap through the
complete routed UI flow.

## Entitlement state

The mobile code caches an entitlement row and permits premium behavior only
when `EntitlementGuard` sees premium status, a non-empty verification token,
and a sufficiently recent server verification. It falls back to a 24-hour
offline grace window. Free users are limited to three user-created workout
plans, and complex workout mutations recheck access outside the UI.

Development can use `tools/entitlement_mock_server.go` plus Dart defines. The
debug Profile screen can set and reset mock states.

This is not a production subscription implementation:

- `MethodChannelRevenueCatGateway` invokes `myfitnesstale/revenuecat`, but no
  Android/iOS handler or RevenueCat dependency exists;
- the default identity provider returns no auth token or user ID and falls back
  to `anonymous-local`;
- the Functions project has source and a `package.json`, but no Firebase project
  configuration or lockfile in the repository;
- sync endpoints do not enforce authentication or App Check in their code;
- the generated verification token is an unsigned base64 string, and the
  mobile app verifies only presence and freshness.

Treat both the Go server and Firebase Functions code as prototypes until the
subscription decision in `project.md` is completed.

## Database risk

The current schema version is 2 and new databases create all 25 tables.
`DatabaseHelper._onUpgrade`, however, returns without changing the database.
This means a version-1 installation can report version 2 while still having an
old schema. Fresh-database tests cannot detect that failure.

No schema version should be increased again until versioned migration steps and
upgrade fixtures are in place. Migration tests should preserve representative
user data and check both schema shape and foreign-key integrity.

## Automated verification at this review

The following checks were run from the repository root on 13 August 2026:

```text
dart format --output=none --set-exit-if-changed lib test
  Formatted 317 files (0 changed)

dart analyze
  No issues found

flutter test
  41 tests passed
```

Current coverage is concentrated in:

- entitlement guard TTL/grace decisions;
- workout-set batch upsert, deletion, validation, aggregate updates, and
  rollback;
- workout-plan structure creation/versioning/validation/rollback;
- workout-plan record/status lifecycle and plan progress boundaries;
- workout-plan week editor behavior;
- selected active-plan and numeric workout-record widgets.

Important untested areas:

- database upgrades;
- onboarding/profile/settings/reminders;
- exercise, equipment, weight-record, and weight-goal services and routed UI;
- router and bottom-navigation journeys;
- complete live-workout and active-plan screen interactions;
- entitlement HTTP/cache/Cubit behavior and platform purchase/restore;
- Android/iOS device behavior, accessibility, release builds, and the backend
  TypeScript build.

`test/widget_test.dart` only asserts that `MyApp` is a widget; it does not pump
the application or verify startup/navigation.

## Other release blockers and limitations

- There is no fitness-data cloud sync, account system, import/export, or local
  backup/restore.
- Reminder preferences do not produce notifications.
- Media fields exist in models, but exercise media is still a placeholder and
  there is no picker/upload/storage workflow.
- Android and iOS still use `com.example.myfitnesstale`; Android release builds
  use debug signing.
- There is no automated CI, crash reporting, privacy policy, or documented
  release process.
- Several comments and older roadmap claims describe intent rather than tested
  behavior. Use this file and executable tests as the baseline.

## Local development

Baseline checks:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
dart analyze
flutter test
git diff --check
```

Optional entitlement mock:

```sh
go run tools/entitlement_mock_server.go
flutter run \
  --dart-define=ENTITLEMENT_API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=ENTITLEMENT_DEBUG_APP_USER_ID=dev-user
```

Use `http://10.0.2.2:8080` from an Android emulator. A USB-connected Android
device can use `127.0.0.1` after `adb reverse tcp:8080 tcp:8080`. Without the
base URL, entitlement refresh degrades to the cached free/expired state.

## Next decision

Start with the database migration and navigation dead ends, then make the
subscription-scope decision. Those choices unlock trustworthy device testing;
the ordered implementation and test plan is in [project.md](project.md).
