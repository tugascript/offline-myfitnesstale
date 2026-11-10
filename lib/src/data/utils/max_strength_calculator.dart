// Copyright (C) 2026 afonsobarracha
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

sealed class MaxStrengthCalculator {
  static int _epley(int reps, int weight) {
    return (weight * (1 + (reps / 30))).round();
  }

  static int _brycki(int reps, int weight) {
    return (weight * (36.0 / (37.0 - reps))).round();
  }

  static int calculateMaxStrength(int reps, int weight) {
    if (reps == 0 || weight == 0 || reps > 10) {
      return 0;
    }

    if (reps == 1) {
      return weight;
    }
    if (reps <= 3) {
      return _brycki(reps, weight);
    }

    return _epley(reps, weight);
  }
}
