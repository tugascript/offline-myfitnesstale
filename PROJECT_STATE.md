# My Fitness Tale: Current Project State

Last reviewed on `codex/navigation-dead-ends` (base commit `b05bf59`) on
14 August 2026.

This is the code-grounded source of truth for what exists now. The forward plan
and test priorities are in [project.md](project.md).

## Snapshot

My Fitness Tale is a local-first Flutter fitness tracker for Android and iOS.
It has substantial profile, exercise, workout, history, weight, workout-plan,
and plan-execution functionality backed by SQLite. The known navigation dead
ends have been repaired. It is suitable for continued development and manual
testing, but is not release-ready because onboarding is not atomic, automated
coverage remains uneven outside the repaired paths, local backup is absent,
and subscriptions are intentionally unavailable.

Repository facts at this review:

- 310 Dart source files under `lib`;
- 25 SQLite tables in the current create schema;
- 86 seeded exercises and 25 seeded equipment entries;
- 16 optional seeded workouts and one 16-week seeded workout plan;
- 16 automated test files with 66 passing tests;
- no repository CI configuration.

## What is implemented

| Area | Current behavior | Important caveat |
| --- | --- | --- |
| Onboarding and profile | Creates one local profile; persists height, gender, birthday, units, theme, notification preference, and reminder toggles | Bootstrap spans multiple service calls and is not atomic or covered by failure/retry tests |
| Seed data | Always seeds equipment and exercises; optionally seeds workouts and the standard plan | Failure recovery and duplicate-safe retry are not defined |
| Activity | Provides entry cards for workout history, aggregate exercise progress, weight history, and workout-plan history | Workout and plan history require selecting their parent entity; there is no unified chronological timeline |
| Exercises | Paginated browse/search; muscle-group, difficulty, and favorite filters; create/edit/delete; equipment relationships; favorite state | Equipment filtering is still TODO; media values have no picker/upload workflow |
| Exercise records/progress | Create/edit/delete records; latest/history views; date filtering; estimated-max chart; aggregate progress sorted by exercise with kg/lb summaries | Aggregate progress intentionally reads only the most recent 1,000 records |
| Workouts | Reusable, versioned workouts; basic and advanced editors; alternatives, rep ranges, rest, and difficulty; create/edit/delete | Advanced mutations remain entitlement-gated; free users see an unavailable-in-this-build state rather than purchase actions |
| Live workout | Starts a workout record, logs numeric weight/reps, carries prior values within a set group, handles rest/progress, complete and cancel | Full screen-level lifecycle is not covered by integration tests |
| Workout history | Lists/details records; manual completed-record creation; record editing and deletion | Activity opens the workout list because history is versioned per workout |
| Weight | Create/edit/delete records; latest value; date-range list/chart; metric/imperial conversion; tappable chart points | No import/export, backup, or broader analytics |
| Weight goals | Create/edit/delete; active goal and history; phase/status/date display | Goal flows have no automated coverage |
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

Visible actions changed in this slice:

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

The usual feature flow is:

1. A model defines its SQLite table, mapping, creation, and `copyWith` behavior.
2. `Repository<T>` provides generic CRUD and query helpers.
3. A feature service validates input and coordinates related rows and
   transactions.
4. A Cubit exposes operation state and feature DTOs.
5. Views load route data; widgets render forms, lists, charts, and actions.

This is a convention rather than a strict dependency boundary. Services are
singletons and Cubits construct them directly, so dependency replacement in
tests is difficult. `WorkoutPlanService` and `WorkoutPlanRecordService` remain
large orchestration services.

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

The following checks were run from the repository root on 14 August 2026:

```text
dart format --output=none --set-exit-if-changed lib test
  327 files formatted with no pending changes

dart analyze
  No issues found

flutter test
  66 tests passed

git diff --check
  No whitespace errors
```

Coverage now includes:

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
- premium-locked flows with no upgrade, subscribe, or restore controls.

Important untested areas:

- onboarding success, rollback, retry, and duplicate seeding;
- complete full-app bottom-navigation/dashboard journeys;
- profile, general exercise/equipment, weight-record, and weight-goal CRUD;
- complete live-workout and active-plan routed interactions;
- import/export because the feature does not exist;
- entitlement HTTP/cache behavior and future store integration;
- Android/iOS device behavior, accessibility, release builds, and backend
  TypeScript build.

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
dart format --output=none --set-exit-if-changed lib test
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

Make onboarding atomic and retry-safe, then run the complete beta journey on
Android and iOS. Add local backup/restore before treating device data as
durable. The ordered implementation and test plan is in [project.md](project.md).
