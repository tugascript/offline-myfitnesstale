# My Fitness Tale

My Fitness Tale is a local-first Flutter fitness tracker for profiles, exercises,
workouts, workout history, weight tracking, and multi-week workout plans. Data is
stored on-device in SQLite and UI state is managed with Cubits.

The code-grounded project status, architecture, known gaps, and development
workflow are documented in [PROJECT_STATE.md](PROJECT_STATE.md).

## Development

```sh
flutter pub get
flutter run
dart analyze
flutter test
```

The project currently targets Flutter with Dart `^3.5.4`. No cloud account or
backend is required for the mobile app's implemented flows.
