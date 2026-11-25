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

import '../view_models/states/macro_tracking_state.dart';

enum TrackerBodyStates {
  activeGoal,
  initialGoalError,
  waitingForGoal,
  noGoal;

  factory TrackerBodyStates.fromState(MacroTrackingState state) {
    if (state.activeGoal != null) {
      return TrackerBodyStates.activeGoal;
    }
    if (!state.hasLoadedActiveGoal) {
      final goalError = state.activeGoalError ?? state.error;
      if (goalError != null && !state.isLoadingActiveGoal) {
        return TrackerBodyStates.initialGoalError;
      }
      return TrackerBodyStates.waitingForGoal;
    }

    return TrackerBodyStates.noGoal;
  }
}
