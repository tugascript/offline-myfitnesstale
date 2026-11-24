// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

final class StateData {
  final bool hasActiveGoal;
  final bool hasError;
  final bool hasLoadedActiveGoal;
  final bool isLoadingActiveGoal;

  const StateData({
    required this.hasActiveGoal,
    required this.hasError,
    required this.hasLoadedActiveGoal,
    required this.isLoadingActiveGoal,
  });
}

enum TrackerBodyStates {
  activeGoal,
  initialGoalError,
  waitingForGoal,
  noGoal;

  factory TrackerBodyStates.fromState(StateData state) {
    final hasInitialGoalError =
        !state.hasActiveGoal && !state.hasLoadedActiveGoal && state.hasError;
    final isWaitingForGoal =
        !state.hasLoadedActiveGoal && state.isLoadingActiveGoal;

    if (state.hasActiveGoal) {
      return TrackerBodyStates.activeGoal;
    }
    if (isWaitingForGoal) {
      return TrackerBodyStates.waitingForGoal;
    }
    if (hasInitialGoalError) {
      return TrackerBodyStates.initialGoalError;
    }

    return TrackerBodyStates.noGoal;
  }
}
