# My Fitness Tale: Current Project State

Last reviewed against the repository on 17 July 2026.

This document describes what the code currently does. It replaces the older
phase-percentage roadmap in `project.md`, whose completion claims were not a
reliable representation of the running application.

## Product summary

My Fitness Tale is a local-first Flutter fitness tracker. The implemented app
supports:

- local profile creation, preferences, units, reminders, and theming;
- exercise and equipment browsing, creation, editing, and exercise records;
- reusable workouts composed of sets and exercises;
- live workout tracking with set, repetition, weight, and rest data;
- manual workout-history entry and history editing;
- weight records and weight goals;
- versioned, multi-week workout-plan creation and editing;
- one current workout-plan execution, scheduled workout launch, progress, and
  manual backfilling of missed plan workouts;
- a local entitlement model used to gate premium editor behavior.

The app does not currently have user accounts, cloud synchronization, a remote
API, or production backup/restore. `backend/functions` is not part of the
implemented mobile data path.

## Technology and entry points

| Area | Current implementation |
| --- | --- |
| UI | Flutter Material widgets |
| Navigation | `go_router` routes in `lib/src/utilities/app_router.dart` |
| State | `flutter_bloc` Cubits provided globally by `lib/my_app.dart` |
| Persistence | `sqflite`, models in `lib/src/models`, generic repositories plus feature services |
| Database | `app.db`, schema version 2, initialized by `lib/main.dart` |
| Tests | Flutter tests with `sqflite_common_ffi` for service/database coverage |

The main navigation has Home, Plans, Activity, and Profile tabs. Activity is
still a placeholder (`NotFoundView`); feature-specific routes such as Workouts,
Exercises, Weight, and Equipment are reached from dashboard/profile actions.

## Architecture as it exists

The dominant flow is:

1. A model defines a SQLite table, serialization, and `copyWith` behavior.
2. `Repository<T>` performs generic CRUD against that table.
3. A feature service validates inputs and coordinates related tables and
   transactions.
4. A Cubit converts service results into UI state.
5. Views own route-level loading; widgets own forms and presentation.

This is a convention, not a strict boundary. Some services are large and
perform orchestration, and some widgets invoke more than one Cubit to complete
a cross-feature operation. Services and `DatabaseHelper` are singletons, while
Cubits are app-scoped in `MyApp`.

### Data conventions

- Database IDs are integer primary keys.
- Times are stored as Unix seconds and exposed as `DateTime` in DTOs.
- Exercise weight is stored in grams; UI conversion depends on profile units.
- Workouts and workout plans use versions. Execution/history records retain the
  version they were created from.
- `ProgressStatus` is shared by live records and includes `in_progress`,
  `completed`, `skipped`, and `abandoned`.
- SQLite foreign-key enforcement is enabled when the database is configured.

## Workout plans and records

The plan tables describe reusable schedule templates:

- `workout_plans`
- `workout_plan_weeks`
- `workout_plan_days`
- `workout_plan_workouts`

The corresponding `*_records` tables describe one execution of a plan. Only
one `workout_plan_record` may remain `in_progress`; starting another plan marks
the previous execution abandoned.

The active-plan screen expands ranged week templates into concrete week
instances. Past unrecorded days are marked missed. An eligible scheduled workout
offers:

- **Start/Resume**: opens live tracking and links the actual `workout_records`
  row to the scheduled plan-workout record;
- **Log**: opens the manual history editor with plan/week/day/position context,
  then links the saved history row and completes that scheduled workout.

This association is important: `workout_plan_workout_records.workout_record_id`
must reference a workout *history record*, never a reusable workout template.
Completion propagates only after every scheduled workout for the day, week, and
plan is completed or skipped. Cancelling a live workout removes its plan link
and deletes the unfinished workout history row.

The dashboard loads the latest current plan, shows its completed/total workout
count, and routes plan workout actions through the active-plan screen so the
week/day/position context is not lost.

## Current limitations and risks

- The Activity bottom-navigation tab is not implemented.
- Database schema version 2 has no `onUpgrade` migration logic. Future schema
  changes must add explicit, tested migrations before increasing the version.
- Automated coverage is strongest around workout/workout-plan persistence and
  limited for full navigation and visual interaction flows.
- There is no import/export, backup, cloud sync, or multi-device conflict model.
- Several screens still contain placeholders or TODOs, especially media,
  analytics, and advanced filtering.
- The repository contains a long legacy `project.md` roadmap. Treat it as
  historical planning, not proof that a feature works.

## AI-generated patterns to review carefully

Much of the repository was produced with GPT-4/Cursor. The code is readable,
but these recurring patterns can hide correctness bugs:

- a foreign-key-looking field populated with a related template ID instead of
  the record ID required by the schema;
- `copyWith` methods using `value ?? oldValue`, which cannot intentionally clear
  nullable fields unless a wrapper or explicit clear flag is used;
- `Equatable` props that compare only list lengths, so nested data changes may
  require a loading/progress state change to trigger a rebuild;
- status and timestamps updated independently, allowing a completed timestamp
  to coexist with `in_progress`;
- multi-step operations split across service calls rather than one transaction;
- comments and roadmap percentages that describe intended behavior rather than
  verified behavior;
- duplicated UI calculations for current week/day and progress.

When modifying a record flow, trace the identifier and status through model,
service, Cubit, route parameters, UI action, database row, and reload behavior.

## Verification

Run these from the repository root:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
dart analyze
flutter test
git diff --check
```

Workout-plan lifecycle coverage is in
`test/src/cubits/workout_plan_cubits_test.dart`. It verifies current-day mapping,
record linkage, status propagation, replacement of the active plan, completed
workout lifecycle, skipped workouts, and multi-workout completion boundaries.

## Recommended next work

1. Add route-level integration tests that tap through Start, Complete, Cancel,
   and the full manual Log form from the active-plan screen.
2. Implement and test database migrations before the next schema change.
3. Replace the Activity placeholder with a unified workout/weight history view.
4. Consolidate current-week/day calculation and plan progress into one domain
   helper used by the dashboard and active-plan UI.
5. Decide on local export/backup before adding remote synchronization.
