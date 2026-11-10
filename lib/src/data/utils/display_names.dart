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

import './enums.dart';

sealed class EnumDisplayNames {
  static String getMuscleGroupDisplayName(MuscleGroup? group) {
    switch (group) {
      case MuscleGroup.full:
        return 'Full Body';
      case MuscleGroup.push:
        return 'Push';
      case MuscleGroup.pull:
        return 'Pull';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
      case null:
        return 'Unknown';
    }
  }

  static String getMuscleDisplayName(Muscle? muscle) {
    switch (muscle) {
      case Muscle.chest:
        return 'Chest';
      case Muscle.upperChest:
        return 'Upper Chest';
      case Muscle.lowerChest:
        return 'Lower Chest';
      case Muscle.innerChest:
        return 'Inner Chest';
      case Muscle.shoulders:
        return 'Shoulders';
      case Muscle.frontDelts:
        return 'Front Delts';
      case Muscle.sideDelts:
        return 'Side Delts';
      case Muscle.rearDelts:
        return 'Rear Delts';
      case Muscle.triceps:
        return 'Triceps';
      case Muscle.neck:
        return 'Neck';
      case Muscle.trapezius:
        return 'Trapezius';
      case Muscle.upperTrapezius:
        return 'Upper Trapezius';
      case Muscle.middleTrapezius:
        return 'Middle Trapezius';
      case Muscle.lowerTrapezius:
        return 'Lower Trapezius';
      case Muscle.rhomboids:
        return 'Rhomboids';
      case Muscle.lats:
        return 'Lats';
      case Muscle.biceps:
        return 'Biceps';
      case Muscle.brachialis:
        return 'Brachialis';
      case Muscle.forearms:
        return 'Forearms';
      case Muscle.quadriceps:
        return 'Quadriceps';
      case Muscle.hamstrings:
        return 'Hamstrings';
      case Muscle.glutes:
        return 'Glutes';
      case Muscle.calves:
        return 'Calves';
      case Muscle.tibialis:
        return 'Tibialis';
      case Muscle.adductors:
        return 'Adductors';
      case Muscle.abdominals:
        return 'Abdominals';
      case Muscle.upperAbs:
        return 'Upper Abs';
      case Muscle.lowerAbs:
        return 'Lower Abs';
      case Muscle.obliques:
        return 'Obliques';
      case Muscle.lowerBack:
        return 'Lower Back';
      case null:
        return 'Unknown';
    }
  }

  static String getDifficultyDisplayName(Difficulty? d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
      case null:
        return 'Unknown';
    }
  }

  static String getSetTypeDisplayName(WorkoutSetType? s) {
    switch (s) {
      case WorkoutSetType.standard:
        return 'Standard';
      case WorkoutSetType.drop:
        return 'Drop';
      case WorkoutSetType.superSet:
        return 'Super';
      case WorkoutSetType.giant:
        return 'Giant';
      case WorkoutSetType.pyramid:
        return 'Pyramid';
      case WorkoutSetType.circuit:
        return 'Circuit';
      case null:
        return 'Unknown';
    }
  }

  static String getGenderDisplayName(Gender? g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case null:
        return 'Unknown';
    }
  }

  static String getWorkoutPhaseDisplayName(WorkoutPhase? p) {
    switch (p) {
      case WorkoutPhase.endurance:
        return 'Endurance';
      case WorkoutPhase.hypertrophy:
        return 'Hypertrophy';
      case WorkoutPhase.maxStrength:
        return 'Max Strength';
      case WorkoutPhase.power:
        return 'Power';
      case null:
        return 'Unknown';
    }
  }

  static String getTimeOfDayDisplayName(WorkoutTimeOfDay? t) {
    switch (t) {
      case WorkoutTimeOfDay.morning:
        return 'Morning';
      case WorkoutTimeOfDay.afternoon:
        return 'Afternoon';
      case WorkoutTimeOfDay.evening:
        return 'Evening';
      case WorkoutTimeOfDay.night:
        return 'Night';
      case WorkoutTimeOfDay.anytime:
      case null:
        return 'Anytime';
    }
  }

  static String getWeightGoalPhaseDisplayName(WeightGoalPhase? g) {
    switch (g) {
      case WeightGoalPhase.cut:
        return 'Cut';
      case WeightGoalPhase.maintain:
        return 'Maintain';
      case WeightGoalPhase.bulk:
        return 'Bulk';
      case null:
        return 'Unknown';
    }
  }

  static String getProgressStatusDisplayName(ProgressStatus? s) {
    switch (s) {
      case ProgressStatus.inProgress:
        return 'In Progress';
      case ProgressStatus.abandoned:
        return 'Abandoned';
      case ProgressStatus.completed:
        return 'Completed';
      case ProgressStatus.skipped:
        return 'Skipped';
      case null:
        return 'Unknown';
    }
  }

  static String getFoodCategoryDisplayName(FoodCategory? c) {
    switch (c) {
      case FoodCategory.meatAndPoultry:
        return 'Meat and Poultry';
      case FoodCategory.fishAndSeafood:
        return 'Fish and Seafood';
      case FoodCategory.dairyAndEggs:
        return 'Dairy and Eggs';
      case FoodCategory.grainsAndCereals:
        return 'Grains and Cereals';
      case FoodCategory.fruits:
        return 'Fruits';
      case FoodCategory.vegetables:
        return 'Vegetables';
      case FoodCategory.legumes:
        return 'Legumes';
      case FoodCategory.nutsAndSeeds:
        return 'Nuts and Seeds';
      case FoodCategory.fatsAndOils:
        return 'Fats and Oils';
      case FoodCategory.supplements:
        return 'Supplements';
      case FoodCategory.beverages:
        return 'Beverages';
      case FoodCategory.snacksAndSweets:
        return 'Snacks and Sweets';
      case FoodCategory.preparedMeals:
        return 'Prepared Meals';
      case FoodCategory.other:
        return 'Other';
      case null:
        return 'Unknown';
    }
  }
}
