# Agent Guidance

My Fitness Tale is a local-first Flutter app for Android and iOS. SQLite on the device is the source of truth;
implemented core flows must work without an account or backend. Keep future network features optional and preserve local
data ownership.

## Architectural Layers and Division of Responsibilities

Follow a strict MVVM flow aligned with the Flutter app architecture guide:
`SQLite Model -> DAO -> Repository -> Cubit/ViewModel -> Screen/Widget`.

- **Model (`lib/src/data/models`)**:
    - Defines SQLite table schemas (`tableCreate`, `Columns` enum).
    - Maps database rows to Dart objects (`toMap()`, `fromMap()`).
    - Pure data container implementing `Model` and `Equatable`. Contains no business logic.
    - Uses `Nullable<T?>` wrappers (`lib/src/utils/nullable.dart`) in `copyWith` to differentiate between omitting an
      argument and deliberately setting a field to `null`.
- **DAO (`Dao` / `JoinDao` in `lib/src/data/services/sqlite/`)**:
    - Generic table-level persistence layer communicating with SQLite via `DatabaseHelper`.
    - Handles single-table CRUD queries (`insert`, `update`, `delete`, `selectOne`, `selectMany`, `selectPaginated`,
      `count`).
    - Accepts an optional `Transaction? trx` for atomic execution.
- **Repository (`lib/src/data/repositories/<feature>/`)**:
    - Encapsulates business logic, domain rules, and multi-table coordination.
    - Interacts with one or more `Dao` / `JoinDao` instances and manages transactions for multi-step mutations.
    - Transforms raw database models into domain DTOs under feature `dtos/` (shared media DTOs in
      `repositories/core/dtos/`).
        - DTOs are immutable, stripping metadata and implementing `Equatable` for value equality in the Bloc.
    - Feature inputs live beside the repository under `inputs/`.
    - Returns functional `Result<T, ServiceError<E>>` objects (`lib/src/utils/result.dart`) instead of
      throwing unhandled exceptions or leaking database details.
    - Preference for CRUD where the UPDATE uses the same input as CREATE making a "PUT" system.
- **Cubit / ViewModel (`lib/src/ui/<feature>/view_models/`)**:
    - Feature and application state management (`flutter_bloc`), colocated with each feature under `view_models/`.
    - Shared state helpers (e.g. `ErrorState`) live in `lib/src/ui/core/view_models/states/`.
    - Invokes repositories, unpackages `Result` objects, and emits immutable states under `view_models/states/`.
    - Uses `Nullable<T?>` wrappers (`lib/src/utils/nullable.dart`) in state `copyWith` to differentiate between
      omitting an argument and deliberately setting a field to `null`.
    - Never interacts directly with `sqflite` or raw database models.
    - Has a pagination state inside each type of entity state.
- **Screen & Widget (`lib/src/ui/<feature>/`)**:
    - UI layer under feature folders: `screens/` (`*_screen.dart` / `*Screen`), `widgets/`, and `view_models/`.
    - Shared UI lives in `lib/src/ui/core/` (`widgets/`, `widgets/layout/`, `sizes/`, `themes/`, `screens/`,
      `view_models/`).
    - Consumes Cubit states via `BlocBuilder` / `BlocConsumer` / `context.watch`.
    - Dispatches user intents to Cubit methods.
    - Never calls repositories or DAOs directly.
    - When generating a screen, reuse shared UI in `lib/src/ui/core/widgets/` (including `layout/`) and feature widgets
      under `lib/src/ui/<feature>/widgets/`. Keep the screen a compact composition of those widgets plus Cubit wiring.
    - Resolve layout sizes in the screen with `BreakPoint.fromContext(context)` and the matching class in
      `lib/src/ui/core/sizes` (usually `DataDisplaySizes.getDataDisplaySizes`). Pass that size list, and `ThemeData`
      when needed, into child widgets. Do not hardcode padding, spacing, icon sizes, or font sizes in screens or
      widgets.
- **Application Root & Wiring (`lib/my_app.dart`)**:
    - Registers app-scoped Cubits using `MultiBlocProvider` and wires the router.

## Navigation and UI Constraints

- **Routing**: `GoRouter` configured in `lib/src/routing/app_router.dart`. Register static routes before dynamic
  parameterized routes (e.g. `/exercises/progress` before `/exercises/:id/records`).
- **Orientation**: Portrait mode is enforced at runtime.
- **Responsiveness**: Ensure screens handle narrow widths and 200% text scaling without layout or pixel overflow errors.

## Data and Persistence Conventions

- **Weights**: Always stored as **integer grams** (`int`) in SQLite. Conversion between metric and imperial is strictly
  for UI display.
- **Timestamps**: Always stored as **integer Unix seconds** (`int`, UTC) via `DateUtilities.getNowUtcUnix()`.
- **Foreign Keys**: Enforced in SQLite (`PRAGMA foreign_keys = ON`). Ensure constraints and cascaded deletions are
  valid.
- **Transactions & Atomicity**: Operations spanning multiple tables or domain changes must run in a SQLite transaction.
  Onboarding is a single transaction that writes setup completion last; preserve its rollback and idempotent retry
  behavior.
- **Versioning**: Workouts and workout plans are versioned; historical records reference the originating template
  version.
- **Database Policy**: Pre-release schema version 1. Development data may be reset under current policy. Migrations and
  upgrade validation are required only after the first external beta (see `PROJECT_STATE.md`).

## Guardrails on Incomplete Features

- **Reminders**: Switches persist preferences only; no background notification scheduling engine exists yet. Do not
  assume notifications fire or add external notification services without being tasked.
- **Meals & Macros**: Food, recipe, meal-plan, meal-plan execution, macro-goal, and daily nutrition tracking flows are
  implemented for offline use. Keep cloud and AI capabilities deferred to Phase 2/3, and describe any remaining roadmap
  work as incomplete.
- **Cloud, Sync & Paid Plans**: All offline features (including advanced workouts and unlimited workout plans) are
  completely
  free and unlocked. Cloud sync and server-backed paid plans are strictly deferred to Phase 2/3. Core flows must remain
  fully offline.
- Do not present roadmap items as working features.

## Coding Practice

- Follow the [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style).
- Use sound null safety; avoid `!` unless the invariant is clear.
- Repository functions, even intermediate, return `Result<T, ServiceError<E>>`, never throw exceptions. Catch failures
  at
  the repository boundary and map them to appropriate errors; do not let exceptions escape. Always prefer the Columns
  mixin in `lib/src/data/models` to write SQL; only use raw SQL when necessary.
- Keep Cubit type names (`*Cubit`) even though they live under `view_models/`; do not invent hybrid names such as
  `CubitViewModel`.
- Keep screens focused on composition and Cubit wiring. Reuse existing widgets and extract cohesive UI components into
  `lib/src/ui/<feature>/widgets/` or `lib/src/ui/core/widgets/`.
- Reuse existing helpers, components, widgets, repositories, and patterns consistently with surrounding code. Otherwise,
  write the simplest implementation that meets the requirements; avoid speculative abstractions.

## Testing and Verification Baseline

Run these standard checks before concluding any coding task:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
dart analyze
flutter test
git diff --check
```

- **Test Database Isolation**: The integration test harness uses `integration_test.db`. Never modify setup or teardown
  to delete or touch production `app.db`.
- Run device journeys with `flutter test integration_test -d <device-id>`.

## Project References and Documentation

- `README.md` — Product overview, architecture orientation, and setup.
- `PROJECT_STATE.md` — Code-grounded capabilities, invariants, known gaps, and test evidence. Update this file whenever
  behavior, schema, or limitations change.
- `project.md` — Roadmap, delivery priorities, and release criteria.
