# My Fitness Tale: Current Project State

Reviewed on 15 September 2026 from branch `ab/fix-all-todos` at commit
`82bf79c`, including the current working tree. This file records what the code
does now. See [README.md](README.md) for the product overview and
[project.md](project.md) for planned work.

## At a glance

My Fitness Tale is a local-first Flutter fitness tracker for Android and iOS.
The implemented app covers onboarding, profiles, equipment, exercises,
exercise progress, workouts, workout history, weight tracking, weight goals,
multi-week plans, and plan execution. Data is stored in SQLite and the core
flows do not require a backend or account.

The app is suitable for continued development and simulator testing, but not
for release or irreplaceable user data. Backup/restore is absent, platform
identifiers and signing are unfinished, physical-device checks remain, reminder
preferences do not schedule notifications, and purchases are unavailable.

Repository facts at this review:

- 310 Dart source files under `lib/`;
- 25 SQLite tables in the create schema;
- database schema version 1;
- 89 seeded exercises and 25 seeded equipment entries;
- 16 optional starter workouts and one 16-week starter plan;
- 27 host test files and five integration-test files;
- no repository CI configuration;
- no backend implementation in the current working tree.

## Implemented capabilities

### Onboarding and settings

- Creates a single local profile, system settings, reminder preferences, and
  seed data in one transaction.
- Optionally installs starter workouts and a standard 16-week plan.
- Marks setup complete only after every other write succeeds.
- Preserves the form after failure and supports a clean retry.
- Saves profile, theme, units, and both reminder switches.

Reminder switches represent saved preferences only. Notification scheduling,
delivery, cancellation, permission recovery, and time-zone behavior do not
exist.

### Equipment, exercises, and progress

- Browses, searches, filters, favorites, creates, edits, and deletes equipment
  and exercises.
- Maintains exercise/equipment relationships.
- Creates, edits, deletes, and filters exercise records.
- Shows estimated-max progress and kg/lb summaries.
- Provides aggregate Exercise Progress ordered by exercise name.

Aggregate progress intentionally reads at most the most recent 1,000 exercise
records. Media fields exist, but there is no picker, upload, or storage flow.

### Workouts and history

- Creates reusable, versioned workouts with basic and advanced editors.
- Supports sets, alternatives, rep ranges, rest, and difficulty.
- Starts live workout records, logs decimal weight and reps, carries prior
  values within a set group, and tracks rest/progress.
- Completes, cancels, and resumes active workouts within the covered lifecycle.
- Lists, creates, edits, and deletes completed workout history.

Advanced mutations remain entitlement-gated. Free users receive an
unavailable-in-this-build explanation instead of purchase controls.

### Weight and goals

- Creates, edits, deletes, and filters weight records.
- Displays the latest value, a date-range chart, and selectable chart points.
- Converts displayed values between metric and imperial units.
- Creates, edits, completes, and deletes weight goals and displays goal history.
- Can associate weight records with a goal; deleting a goal keeps its weight
  records and clears their association.

There is no import/export, local backup, or broader weight analytics.

### Workout plans and plan history

- Creates and versions multi-week schedules.
- Allows one active plan execution and abandons the previous active execution
  when another begins.
- Expands ranged week templates into dated week instances.
- Shows missed days and progress.
- Starts/resumes live scheduled workouts or records them manually.
- Provides paginated, newest-first plan history filtered by plan and status.

Date and progress calculations are still duplicated across UI and service
layers. Historical plan summaries do not expose child-workout detail.

## Navigation

`GoRouter` is configured in `lib/src/utilities/app_router.dart`. An
`IndexedStack` preserves four primary destinations:

1. Home;
2. Plans;
3. Activity;
4. Profile.

Activity links to workout history, aggregate exercise progress, weight history,
and workout-plan history. Other notable routes include:

- `/exercises/progress`;
- `/exercises/:id/records`;
- `/workout-plans/:id/history`;
- `/settings/reminders`.

The static progress route is registered before the dynamic exercise-ID route.
Invalid IDs and unknown locations render `NotFoundView`.

## Architecture

The main dependency flow is:

```text
SQLite model -> Repository<T>/feature service -> Cubit -> view/widget
```

- Flutter Material widgets provide the UI, including responsive components.
- `go_router` provides a flat route table and parameter validation.
- App-scoped `flutter_bloc` Cubits provide state.
- `sqflite`, models, a generic repository, feature services, and DTOs provide
  persistence and domain operations.
- `fl_chart` renders weight and exercise charts.
- Android and iOS are the only configured platforms; portrait is forced at
  runtime.
- Entitlement development code includes a Dart HTTP client, local cache/guard,
  Go mock server, and debug controls. There is no production backend here.

This is a convention rather than a strict dependency boundary. Most services
are singletons and Cubits construct them directly, which can make replacement
in tests difficult. `ProfileCubit` accepts an optional `OnboardingService` for
orchestration tests. `WorkoutPlanService` and `WorkoutPlanRecordService` remain
large orchestration services.

`MyApp` accepts an optional router so integration tests can launch isolated app
instances. Production uses `AppRouter.router`. Used fonts are bundled under
`assets/fonts/`, so startup does not depend on font downloads.

### Data conventions

- IDs are integer primary keys.
- Dates are generally Unix seconds and become `DateTime` values in DTOs.
- Weight is stored as integer grams and converted for display.
- Workouts and plans are versioned; history keeps its originating version.
- SQLite foreign keys are enabled in `onConfigure`.
- `ProgressStatus` includes in-progress, completed, skipped, and abandoned.
- Some `copyWith` methods use `value ?? oldValue`; nullable fields cannot be
  deliberately cleared unless the model provides explicit handling.

### Onboarding invariants

`OnboardingService` performs these stages in one SQLite transaction:

1. equipment;
2. exercises and equipment links;
3. profile;
4. system settings;
5. reminder preferences;
6. optional workouts;
7. optional standard plan;
8. setup completion.

A failed result or injected failure rolls back the attempt. Completed
onboarding is idempotent and returns the existing snapshot. Partial data from
older unpublished builds is treated as inconsistent and requires clearing app
data under the pre-release reset policy.

### Workout-plan execution invariants

Reusable templates live in the `workout_plan*` tables; executions use the
corresponding `*_records` tables. A scheduled workout record must reference a
real workout-history row, not a reusable template. Day, week, and plan
completion propagate only after required child workouts are completed or
skipped. Cancelling a live scheduled workout removes the plan association and
its unfinished workout-history row.

### Entitlement limitations

Premium access currently depends on a local entitlement snapshot, verification
token presence, freshness, and a 24-hour offline grace window. Free users are
limited to three user-created plans, and advanced workout mutations recheck
access outside the UI.

This is not production subscription infrastructure. There is no native
RevenueCat handler or dependency, authenticated verification backend, or
working purchase experience. Purchase/restore APIs remain for later work, but
visible locked flows do not call them.

## Test harness and recorded results

The device harness selects `integration_test.db` before creating app Cubits or
services. Fresh-install scenarios delete only that file; restart scenarios
close and reopen it. Teardown removes fixture data and restores the production
database configuration. The deletion API throws if production `app.db` is
selected.

Five integration files contain seven journeys covering:

- onboarding with starter workouts disabled and enabled;
- all primary navigation, dashboard, and Activity destinations;
- profile, units, theme, and reminder persistence;
- weight records and goals;
- equipment, exercises, and exercise records;
- workout creation/editing, live completion/cancellation/resume, and history;
- plan creation/editing/start/progress/restart and completed history.

Host tests also cover narrow phone layouts, 200% text scaling, onboarding
rollback/idempotency, route precedence, entitlement guards, workout mutation
rollback, plan lifecycle and pagination, reminder disclosure, and database
isolation.

The latest recorded full run is historical evidence from 19–21 August 2026:

```text
dart format --output=none --set-exit-if-changed lib test integration_test
  339 files formatted with no pending changes

dart analyze
  No issues found

flutter test
  97 tests passed

Android 15 / API 35 emulator
  7/7 device journeys passed in 3m56s

iPhone 16 Pro / iOS 18.5 simulator
  7/7 device journeys passed in 3m41s

git diff --check
  No whitespace errors
```

These results have not been refreshed for the current working tree.

## Known gaps and release blockers

- No fitness-data import/export, backup/restore, cloud sync, or account system.
- No meal/macro tracking or local AI trainer.
- No Apple Watch or Wear OS app.
- Reminder preferences do not deliver notifications.
- Purchases and production subscription verification are unavailable.
- No physical-device, release-build, signing, or full accessibility evidence.
- Android and iOS identifiers/signing are still development placeholders.
- No CI, crash reporting, privacy/data-retention statement, store assets, or
  documented release process.
- No media selection/storage workflow for exercises.
- No unified chronological activity timeline.
- No historical child-workout detail in plan history.
- OS termination during an active timer remains an unverified lifecycle case.

## Database policy

The current create schema is version 1. Because no public release or external
beta compatibility baseline exists, development databases are disposable and
may be recreated after schema changes.

The first external beta must establish the non-destructive compatibility
baseline. Every later schema increment must include ordered migrations,
representative upgrade fixtures, preservation checks, and foreign-key
validation.

## Next work

The immediate priority is a versioned, validated, transactional local backup
and restore flow. Reminder delivery and plan date/progress consolidation follow,
then physical-device and release preparation. Meals/macros and the AI trainer
belong to later mobile phases; watch and cloud components come after the mobile
foundation is reliable. See [project.md](project.md) for the ordered plan.
