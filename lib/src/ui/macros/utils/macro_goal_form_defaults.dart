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

final class MacroGoalFormDefaults {
  final String? name;
  final int? targetCalories;
  final int? targetProtein;
  final int? targetCarbs;
  final int? targetFat;
  final int? targetWaterIntakeMl;
  final String? recommendedNote;

  const MacroGoalFormDefaults({
    this.name,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.targetWaterIntakeMl,
    this.recommendedNote,
  });

  static const MacroGoalFormDefaults recommended2000Kcal =
      MacroGoalFormDefaults(
        name: 'Daily Target',
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 215,
        targetFat: 60,
        targetWaterIntakeMl: 2500,
        recommendedNote: 'Recommended default: 2000 kcal / day. Adjust macros to match your target.',
      );
}
