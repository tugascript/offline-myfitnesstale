#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || $1 == booted ]]; then
  echo "Usage: bash tool/test_ios_database_migrations.sh <booted-ios-simulator-udid>" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
device_id=$1
bundle_id=com.example.myfitnesstale
target=integration_test/database_migration_journey_test.dart
fixture="ios-migration-$(date +%s)-$$"
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

# A concrete UDID keeps Flutter and simctl on the same simulator. spawn fails
# before running any tests when the selected simulator is not booted.
xcrun simctl spawn "$device_id" launchctl list >/dev/null
echo "Simulator: $device_id"
echo "Logs: $log_directory"

app_pid() {
  xcrun simctl spawn "$device_id" launchctl list |
    awk -v bundle="$bundle_id" \
      '$1 ~ /^[0-9]+$/ && index($3, "UIKitApplication:" bundle "[") == 1 { print $1 }'
}

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

  # Simulator app PIDs are host PIDs. Resolve only this simulator's exact bundle
  # through its launchd, then SIGKILL while SQL is uncommitted. No Dart teardown
  # or graceful Database.close() can run before SQLite journal recovery.
  process_id=$(app_pid)
  if [[ ! "$process_id" =~ ^[0-9]+$ ]]; then
    echo "Expected exactly one live iOS test app process, got: $process_id" >&2
    exit 1
  fi
  kill -KILL "$process_id"
  for ((attempt = 0; attempt < 30; attempt++)); do
    if ! kill -0 "$process_id" 2>/dev/null; then break; fi
    sleep 1
  done
  if kill -0 "$process_id" 2>/dev/null || [[ -n "$(app_pid)" ]]; then
    echo "The iOS test app survived or relaunched after SIGKILL" >&2
    exit 1
  fi

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
  # Preserve the sandbox on reinstall; recovery inspects the existing database
  # before migrations can change it and checks this invocation's unique fixture.
  run_phase "recover-$operation"
done

run_phase cleanup
echo "Native SQLite journeys and iOS process recovery passed. Logs: $log_directory"
