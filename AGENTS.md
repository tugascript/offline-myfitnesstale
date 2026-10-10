# Agent Guidance

My Fitness Tale is a local-first Flutter app for Android and iOS. SQLite on the device is the source of truth; implemented core flows must work without an account or backend. Keep future network features optional and preserve local data ownership.

## Architectural Layers and Division of Responsibilities

Follow the strict flow: `SQLite Model -> Repository -> Service -> Cubit -> View/Widget`.

- **Model (`lib/src/models/`)**:
  - Defines SQLite table schemas (`tableCreate`, `Columns` enum).
  - Maps database rows to Dart objects (`toMap()`, `fromMap()`).
  - Pure data container implementing `Model` and `Equatable`. Contains no business logic.
- **Repository (`Repository<T extends Model>` in `lib/src/models/repository.dart`)**:
  - Generic table-level persistence layer communicating with SQLite via `DatabaseHelper`.
  - Handles single-table CRUD queries (`insert`, `update`, `delete`, `selectOne`, `selectMany`, `selectPaginated`, `count`).
  - Accepts an optional `Transaction? trx` for atomic execution.
- **Service (`lib/src/services/`)**:
  - Encapsulates business logic, domain rules, and multi-table coordination.
  - Interacts with one or more `Repository<T>` instances and manages transactions for multi-step mutations.
  - Transforms raw database models into domain DTOs (`lib/src/services/dtos/`).
  - Returns functional `Result<T, ServiceError<E>>` objects (`lib/src/services/common/result.dart`) instead of throwing unhandled exceptions or leaking database details.
- **Cubit (`lib/src/cubits/`)**:
  - Feature and application state management (`flutter_bloc`).
  - Invokes services, unpackages `Result` objects, and emits immutable states (`lib/src/cubits/states/`).
  - Uses `Nullable<T?>` wrappers (`lib/src/common/nullable.dart`) in state `copyWith` to differentiate between omitting an argument and deliberately setting a field to `null`.
  - Never interacts directly with `sqflite` or raw database models.
- **View & Widget (`lib/src/views/`, `lib/src/widgets/`)**:
  - UI layer rendering routed screens and components.
  - Consumes Cubit states via `BlocBuilder` / `BlocConsumer` / `context.watch`.
  - Dispatches user intents to Cubit methods.
  - Never calls services or repositories directly.
- **Application Root & Wiring (`lib/my_app.dart`)**:
  - Registers app-scoped Cubits using `MultiBlocProvider` and wires the router.

## Navigation and UI Constraints

- **Routing**: `GoRouter` configured in `lib/src/utilities/app_router.dart`. Register static routes before dynamic parameterized routes (e.g. `/exercises/progress` before `/exercises/:id/records`).
- **Orientation**: Portrait mode is enforced at runtime.
- **Responsiveness**: Ensure views handle narrow screens and 200% text scaling without layout or pixel overflow errors.

## Data and Persistence Conventions

- **Weights**: Always stored as **integer grams** (`int`) in SQLite. Conversion between metric and imperial is strictly for UI display.
- **Timestamps**: Always stored as **integer Unix seconds** (`int`, UTC) via `DateUtilities.getNowUtcUnix()`.
- **Foreign Keys**: Enforced in SQLite (`PRAGMA foreign_keys = ON`). Ensure constraints and cascaded deletions are valid.
- **Transactions & Atomicity**: Operations spanning multiple tables or domain changes must run in a SQLite transaction. Onboarding is a single transaction that writes setup completion last; preserve its rollback and idempotent retry behavior.
- **Versioning**: Workouts and workout plans are versioned; historical records reference the originating template version.
- **Database Policy**: Pre-release schema version 1. Development data may be reset under current policy. Migrations and upgrade validation are required only after the first external beta (see `PROJECT_STATE.md`).

## Guardrails on Incomplete Features

- **Reminders**: Switches persist preferences only; no background notification scheduling engine exists yet. Do not assume notifications fire or add external notification services without being tasked.
- **Purchases & Entitlements**: Premium states are gated with an "unavailable in this build" explanation. Never wire unfinished purchase SDKs or assume server verification.
- **Meals & Macros**: Active feature work (Phase 1, P1). Models exist in `lib/src/models/`; services and UI are in development.
- **Cloud & AI**: Strictly deferred to Phase 2/3. Core flows must remain fully offline.
- Do not present roadmap items as working features.

## Testing and Verification Baseline

Run these standard checks before concluding any coding task:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
dart analyze
flutter test
git diff --check
```

- **Test Database Isolation**: The integration test harness uses `integration_test.db`. Never modify setup or teardown to delete or touch production `app.db`.
- Run device journeys with `flutter test integration_test -d <device-id>`.

## Project References and Documentation

- `README.md` — Product overview, architecture orientation, and setup.
- `PROJECT_STATE.md` — Code-grounded capabilities, invariants, known gaps, and test evidence. Update this file whenever behavior, schema, or limitations change.
- `project.md` — Roadmap, delivery priorities, and release criteria.
