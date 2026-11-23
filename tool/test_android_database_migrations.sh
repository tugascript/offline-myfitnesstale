#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 ]]; then
  echo "Usage: bash tool/test_android_database_migrations.sh <android-device-id>" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
device_id=$1
adb_bin=${ADB:-adb}
package_id=com.example.myfitnesstale
target=integration_test/database_migration_journey_test.dart
fixture="migration-$(date +%s)-$$"
log_directory=$(mktemp -d)
run_pid=

stop_runner() {
  if [[ -n "$run_pid" ]]; then
    kill "$run_pid" 2>/dev/null || true
    wait "$run_pid" 2>/dev/null || true
  fi
}
trap stop_runner EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

"$adb_bin" -s "$device_id" get-state
echo "Android API: $("$adb_bin" -s "$device_id" shell getprop ro.build.version.sdk)"
echo "Logs: $log_directory"

run_phase() {
  flutter test "$target" -d "$device_id" --no-uninstall \
    --dart-define="MIGRATION_PHASE=$1" \
    --dart-define="MIGRATION_FIXTURE=$fixture"
}

run_phase all

for operation in create upgrade rollback; do
  phase="interrupt-$operation"
  log_file="$log_directory/$phase.log"
  flutter test "$target" -d "$device_id" --no-uninstall \
    --dart-define="MIGRATION_PHASE=$phase" \
    --dart-define="MIGRATION_FIXTURE=$fixture" >"$log_file" 2>&1 &
  run_pid=$!
  ready=false
  # Include build/install time, but fail rather than hang if SQL never reaches
  # the interruption point. Each run has a unique fixture and a fresh log.
  for ((attempt = 0; attempt < 600; attempt++)); do
    if grep -Fq "MIGRATION_INTERRUPT_READY:$phase:$fixture" "$log_file"; then
      ready=true
      break
    fi
    if ! kill -0 "$run_pid" 2>/dev/null; then break; fi
    sleep 1
  done
  if [[ "$ready" != true ]]; then
    cat "$log_file"
    echo "Did not reach the live $operation transaction" >&2
    exit 1
  fi

  # Kill the Android process while SQL changes are uncommitted. A thrown Dart
  # exception or Database.close() would exercise a different, graceful path.
  "$adb_bin" -s "$device_id" shell pidof "$package_id"
  "$adb_bin" -s "$device_id" shell am force-stop "$package_id"
  if "$adb_bin" -s "$device_id" shell pidof "$package_id"; then
    echo "The Android test process survived force-stop" >&2
    exit 1
  fi
  # Flutter normally reports the lost connection and exits unsuccessfully.
  for ((attempt = 0; attempt < 30; attempt++)); do
    if ! kill -0 "$run_pid" 2>/dev/null; then break; fi
    sleep 1
  done
  if kill -0 "$run_pid" 2>/dev/null; then
    stop_runner
  else
    if wait "$run_pid"; then
      echo "The interrupted test unexpectedly completed successfully" >&2
      exit 1
    fi
  fi
  run_pid=
  # This is a new process with the existing app data. It first inspects the
  # interrupted DB without running migrations, then verifies a successful retry.
  run_phase "recover-$operation"
done

run_phase cleanup
echo "Native SQLite journeys and Android process recovery passed. Logs: $log_directory"
