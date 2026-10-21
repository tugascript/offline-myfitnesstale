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

- 327 Dart source files under `lib/`;
- 42 SQLite tables in the create schema, including strength goals;
- database schema version 1;
- 89 seeded exercises and 25 seeded equipment entries;
- 16 optional starter workouts and one 16-week starter plan;
- 29 host test files and five integration-test files;
- no repository CI configuration;
- no backend implementation in the current working tree.

## Implemented capabilities

### Home active plans

- Workout and meal plan cards share a horizontally swipeable carousel with
  tappable line indicators above Workout and Meal labels and one static “Active plans” heading;
  both empty slides remain available.
- The selector spans the plan-card width, with equal-width Workout and Meal
  buttons and full-width line indicators. Both empty cards offer Browse Plans
  buttons linking to their respective plan libraries.
- Feature Cubits remain independent. Both cards stay mounted and the carousel
  stretches both cards to the taller card's natural height, including at large
  text scales.
- Meal cards use the workout card's spacing, themed highlight, and
  empty-state styling, with links to plan details. Tapping an active meal or
  macro card still opens the tracker; the separate Open Tracker button is removed.

### Home shortcuts

- Quick Actions has four categories: Workout Plans, Weight Goals,
  Exercises, and Nutrition. Their modal bottom sheets expose all
  fourteen entries, including Exercise Progress as the entry to records.
- Menus have a title, close button, destination icons and chevrons. They support
  swipe, outside-tap, and system Back dismissal; selecting a destination closes
  the sheet completely before opening the existing routed page.
- Quick-action sheets have square corners; Foods uses a generic food icon.
- Home category cards use emojis; submenu destinations retain Material icons.
- Back returns directly to Home with its scroll position retained. Category
  cards use at most two columns, falling back to one on narrow screens or with
  large text. Sheets size to content and scroll when necessary.
- Home has no separate History section. Workout History and Workout Plan History
  appear in the Workout Plans quick-action menu, opening the respective libraries
  to select an item and review its history. Exercise Progress and Weight Records
  remain in their corresponding quick-action menus. Reminder preferences remain
  outside these four feature groups.
- Removed the unused History section, former Activity screen, obsolete workout
  and plan widgets, unused error-screen components, and empty settings widget file.
  Activity-only tests were removed; current quick-action navigation and responsive
  coverage remains in the grouped-menu and Home tests.
- Cleanup verification on 21 October 2026: 327 host tests passed and one skipped;
  dependency resolution, repository-wide formatting, and whitespace checks passed.
  Import traversal from `lib/main.dart` found no unreachable Dart files under `lib/`.
  `dart analyze` stalled without diagnostics and was stopped; analysis remains
  unverified for this cleanup.

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
  and exercises using shared `EquipmentInput` and `ExerciseInput` PUT semantics
  (`Nullable<T>` in `copyWith` clears omitted nullable fields and replaces
  equipment links atomically).
- Maintains exercise/equipment relationships.
- Creates, edits, deletes, and filters exercise records using shared
  `ExerciseRecordInput` PUT semantics.
- Shows estimated-max progress and kg/lb summaries.
- Provides aggregate Exercise Progress ordered by exercise name.

Aggregate progress intentionally reads at most the most recent 1,000 exercise
records. Media fields exist, but there is no picker, upload, or storage flow.

### Workouts and history

- Creates, edits, favorites, and deletes reusable, versioned workouts with basic
  and advanced editors using shared `WorkoutInput` PUT semantics (`Nullable<T>`
  in `copyWith` clears omitted nullable fields across `Workout`, `WorkoutSet`,
  `WorkoutSetExercise`, and `WorkoutSetExerciseOption`).
- Supports sets, alternatives, rep ranges, rest, and difficulty.
- Starts live workout records, logs decimal weight and reps, carries prior
  values within a set group, and tracks rest/progress using `WorkoutRecordInput`,
  `WorkoutSetRecordInput`, and `WorkoutSetExerciseRecordInput` PUT semantics.
- Completes, cancels, and resumes active workouts within the covered lifecycle.
- Lists, creates, edits, and deletes completed workout history using shared
  `WorkoutRecordBatchInput` PUT semantics.

Advanced mutations remain entitlement-gated. Free users receive an
unavailable-in-this-build explanation instead of purchase controls.

### Weight and goals

- Creates, edits, deletes, and filters weight records using shared `WeightRecordInput` PUT semantics (`Nullable<T>` in `copyWith` clears omitted nullable fields).
- Displays the latest value, a date-range chart, and selectable chart points.
- Converts displayed values between metric and imperial units.
- Creates, edits, completes, and deletes weight goals using shared `WeightGoalInput` PUT semantics, abandoning prior in-progress goals when creating or reopening an active goal, and displays goal history.
- Can associate weight records with a goal; deleting a goal keeps its weight
  records and clears their association.

There is no import/export, local backup, or broader weight analytics.

### Workout plans and plan history

- The Current Plan navigation tab displays the ongoing execution's progress
  and schedule without creating a record. It loads once on first opening and
  refreshes on return from Browse Plans or Retry. Tab switches retain cached
  state without reloading; shared Cubit updates keep progress current.
- Starting a plan reloads its matching template and progress in the Cubit,
  so switching plans also updates cached screens without a tab-triggered fetch.
- Initial loading and refresh use the existing Skeletonizer plan content,
  with placeholder data before a plan is available and disabled pointer input.
- Browse Plans appears only in the successful empty state. Active, loading,
  and failed lookup states have no plan-library shortcut; Workout Plans is
  available through Home's Workout Plans menu.
- Creates, edits, favorites, and versions multi-week schedules using shared
  `WorkoutPlanInput`, `WorkoutPlanWeekInput`, and `WorkoutPlanWorkoutInput` PUT
  semantics (`Nullable<T>` in `copyWith` clears omitted nullable fields across
  plan, week, day, and workout models and DTOs).
- Allows one active plan execution and abandons the previous active execution
  when another begins or an older execution is reopened, including through
  record PUT updates and scheduled-workout status changes. The activation and
  abandonment commit in the same transaction; failed updates preserve both
  executions and their week/day/workout history.
- Expands ranged week templates into dated week instances.
- Shows missed days and progress.
- Starts/resumes live scheduled workouts or records them manually using shared
  `WorkoutPlanRecordInput`, `WorkoutPlanDayRecordInput`, and
  `WorkoutPlanWorkoutRecordInput` PUT semantics.
- Provides paginated, newest-first plan history filtered by plan and status.

Date and progress calculations are still duplicated across UI and service
layers. Historical plan summaries do not expose child-workout detail.

### Strength goals

- Creates, updates, completes, and deletes strength goals per exercise.
- Tracks in-progress active goal per exercise separately from historical goals.
- Completing a goal sets status to completed and sets completion timestamp.
- Stores weights in grams and calculates target progress.
- Starting a new strength goal abandons prior in-progress goals for that exercise.

### Foods, recipes, and meal plans

- Foods & portions: Full CRUD for user-authored foods and portions in a single transaction; filters by name, category, and favorite; prevents mutation/deletion of machine-authored foods (`CreatedBy.system`).
- Recipes & items: Aggregates recipe items (pointing to foods and portions); calculates serving totals for calories, protein, carbs, fat, and micronutrients inside the transaction; prevents mutation/deletion of system-authored recipes.
- Meal plans: Multi-week meal schedule aggregates (weeks, days, meals, items) created and versioned with transactions and denormalized total updates; supports favorites and system authoring protection.
- Meal-plan records: Tracks execution of meal plans with week and day records; enforces single active meal-plan invariant; allows starting and advancing/completing days.

The 13 October 2026 refactor applies the food-service conventions across the
PR's new nutrition and strength-goal flows. Create and update share complete
inputs in `services/inputs/`; omitted nullable input fields clear their stored
values. DTOs omit persistence timestamps, while execution dates and originating
template versions remain domain data. Entity states contain their own pagination
objects, including query filters, limits, offsets, and totals. Services use the
existing repository API; the generic repository is unchanged.

Recipe replacement rolls back on invalid ingredient references. Meal-plan
replacement creates a new schedule version and retains previous weeks, days,
and meals for execution records. Meal-week fiber totals now round-trip through
SQLite, and the existing strength-goal table is registered in the create schema.
Schema version remains 1 under the pre-beta reset policy.

Food and recipe details and list items, meal-plan schedules and list items,
macro-goal content, and tracker day/week/month and planned-meal sections live
in their entity widget folders. Views compose these widgets and dispatch Cubit
actions. Regression tests cover complete updates, nullable clearing, rollback,
originating meal-plan versions, pagination/filter preservation, and populated
entity widgets at 320px with 200% text scaling.

The PR's nutrition and strength-goal screens resolve `DataDisplaySizesList`
from their view breakpoints and pass it to child widgets. Padding, spacing,
icons, and typography use those size tokens. Editors reuse `AppTextFormField`;
field groups and dashboard actions reflow according to available width and
text scaling. Strength-goal content scrolls as a whole, and the meal-log dialog
uses naturally sized tab content instead of a fixed-height viewport.

`pr_responsive_widgets_test.dart` covers 150 populated screen/widget scenarios
at 320px, 600px, and 1200px with 100% and 200% text. Dialog checks also cover
long food selections, both food/recipe tabs, and reaching the confirm action
above a keyboard inset.

### Macro tracking and daily nutrition

- Macro goals: Creates, updates, activates, and deletes macro targets (calories, protein, carbs, fat, water); enforces single active goal invariant with automatic deactivation of prior goals.
- Macro-goal forms default to a checked "Calculate calories from macros" checkbox. Calories are initially calculated from the form's macros, remain read-only, and update live using `Converters.macrosToCalories` (protein/carbs 4 kcal per gram, fat 9). Unchecking restores manual editing. The checkbox state is local to the form; existing goals are recalculated in the form and persisted only on Update.
- Macro-goal calculation verification on 15 October 2026: 318 host tests passed, one skipped, including default/live calculation, create/update submission, manual override, invalid input, and existing responsive coverage. Dependency resolution, changed-file formatting, and `git diff --check` passed; analysis has no errors/warnings and one unrelated informational lint. The repository-wide format check still flags 340 other files.
- Daily nutrition logs: Get-or-create per numeric local date (`YYYYMMDD`); each food or recipe submission retains its own timestamp and immutable nutrition snapshot, including submissions at identical times; recalculates meal and daily totals. Meal categories remain metadata for meal plans rather than diary grouping.
- Daily diary: A square-edged 24-hour timeline groups all entries by local hour, orders entries by time, and offers an add action per hour. Logging prefills the selected date/hour, allows time adjustment, and requires no meal-category selection. Calories/macros, water controls, and scheduled plan meals remain above the timeline. Week/month views and date navigation remain available.
- Existing diary entries retain their stored timestamps; older entries previously merged by category share the original meal timestamp because individual item times were never stored. No schema change or data reset is required.
- Quick Add: The logging modal includes a third tab for a one-time name and total protein/carbs/fat, with calories calculated by default or entered manually. Standalone snapshots are saved atomically to the selected date/time without adding foods or recipes to the library. They appear in the hourly timeline, contribute to daily totals, and can be deleted like other entries. Drafts survive tab changes; invalid totals are rejected and failed saves leave the form available for retry. Uses existing schema version 1.
- Quick Add verification on 15 October 2026: full host suite passed (324 tests, one skipped), including persistence/Cubit refresh, library isolation, validation, transaction rollback, deletion, manual calorie totals, selected times, draft retention, failed-save retry, successful dismissal, and 320px/200% text with keyboard coverage. Dependency resolution, changed-file formatting, and `git diff --check` passed. Analysis reports one unrelated informational lint and no errors/warnings. The repository-wide format check flags 339 other files; no device journey was run.
- Water intake: Updates daily water consumption with quick adjust controls.
- Logging modal tabs (Food, Recipe, Quick Add) each occupy one third of the content width, with centered labels that wrap at large text scales. The selected underline spans the full tab width with square ends.
- The Day/Week/Month selector has square corners and indicates selection through its themed fill without a tick icon.
- Validation on 15 October 2026: full host suite passed (315 tests, one skipped), including new persistence and timeline interaction coverage for same-hour/identical-time entries, midnight, historical dates, food/recipe logging, time adjustment, deletion, totals, and 320px/200% text. Dependency resolution and `git diff --check` passed. Analysis reported only 30 existing informational lints; changed nutrition files have no analysis issues and pass formatting. The repository-wide format check still flags 357 other files under the current SDK; those files were left unchanged. No device nutrition journey was run.
- UI: Day, Week, and Month tracker views; meal logging modal with portion calculator; the active plan's meals appear on their scheduled dates and can be logged into the diary; responsive layouts supporting 320px narrow screens and 200% font scaling.

## Navigation

`GoRouter` is configured in `lib/src/utilities/app_router.dart`. An
`IndexedStack` preserves four primary destinations:

1. Home;
2. Plans;
3. Tracker (daily nutrition, with day/week/month scopes);
4. Profile.

Meal plans remain accessible from Home quick actions and the meal card.

History is accessible through Home quick actions: Workout History and Workout Plan
History under Workout Plans, Exercise Progress under Exercises, and Weight Records
under Weight Goals.
Other notable routes include:

- `/exercises/progress`;
- `/exercises/:id/records`;
- `/exercises/:id/strength-goals`;
- `/workout-plans/:id/history`;
- `/foods`;
- `/recipes`;
- `/meal-plans`;
- `/macros/tracker`;
- `/macros/goals`;
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

The latest full verification run on 13 October 2026:

After upgrading to Flutter 3.47.7 / Dart 3.13.5, Android builds use AGP 9.1.1
and compile SDK 37 with minor API level 0. A scoped Gradle override supplies
the missing minor level in `permission_handler_android` 14.1.0 so it resolves
the installed `android-37.0` platform. Google Fonts 9 styles are applied to
individual Flutter text styles to preserve the existing Material themes.

```text
dart format --output=none --set-exit-if-changed lib test integration_test
  The new Dart formatter reports pending changes in 377 of 435 files

dart analyze
  No errors or warnings; 30 informational lints remain after the SDK upgrade

flutter test
  276 tests passed, one skipped

flutter build apk --debug
  Debug APK built successfully

flutter run -d emulator-5554 --no-resident
  Installed and launched successfully on the Android emulator

git diff --check
  No whitespace errors
```

Grouped navigation and Current Plan verification on 14 October 2026:

- `flutter pub get` completed successfully.
- Full host suite: 310 tests passed, one skipped, including current-plan
  loading, empty/error/retry, library return, cached-tab revisits, completed
  execution filtering, and narrow layouts at 200% text scaling.
- Grouped-menu tests cover all twelve destinations, four dismissal methods,
  direct Back navigation with preserved Home scroll position, one/two-column
  layouts, and scrolling on a short screen while keeping Close accessible.
- `dart analyze` completed with no errors or warnings; the existing 30
  informational lints remain.
- Scoped formatting checks pass. The repository-wide check still reports
  pending formatter changes in 361 of 444 files; unrelated files were not
  reformatted.
- Both shell journeys pass on Android emulator `emulator-5554`, including
  checking that opening Current Plan creates no execution records.
- The plan journey also passes through Current Plan after restart, completes
  live and manual scheduled workouts, returns to the empty state after plan
  completion, and restores completed history after another restart.
- All seven Android journeys are verified: six passed in the full integration
  run; the weight lifecycle passed on a targeted rerun after correcting stale
  assertions to match the existing latest-weight display's unit spacing.
- `git diff --check` reports no whitespace errors.

The cached-tab refresh fix also passes all 310 host tests (one skipped),
including switching between plan executions with matching cached template data.
The subsequent Android plan-journey rerun built successfully but stalled during
native app startup before Flutter connected; it was stopped. The Android journey
results above remain evidence from the earlier run.

## Known gaps and release blockers

- No fitness-data import/export, backup/restore, cloud sync, or account system.
- Meal, macro, food, recipe, and meal-plan tracking and execution flows are fully implemented offline. No local AI trainer.
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

The immediate priority is completing the core mobile fitness features (starting with
meal and macro tracking) and consolidating plan date/progress calculations. Local backup
and restore is deferred to P2 so that the full SQLite data schema is finalized before
freezing the export format. Reminder delivery, physical-device testing, and release
configuration follow, ahead of advanced AI and ecosystem components. See [project.md](project.md)
for the ordered plan.
