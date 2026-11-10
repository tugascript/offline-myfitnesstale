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

enum Routes {
  home('/'),
  createProfile('/setup/create-profile'),
  onboarding('/onboarding'),
  weightGoal('/weight-goal'),
  weightRecords('/weight-records'),
  equipments('/equipments'),
  equipmentCreation('/equipments/create'),
  equipmentDetails('/equipments/:id'),
  equipmentUpdate('/equipments/:id/update'),
  exercises('/exercises'),
  exerciseCreation('/exercises/create'),
  exerciseProgress('/exercises/progress'),
  exerciseDetail('/exercises/:id'),
  exerciseUpdate('/exercises/:id/update'),
  workouts('/workouts'),
  workoutEdit('/workouts/:id/edit'),
  workoutHistory('/workouts/history'),
  createWorkoutRecord('/workouts/:id/history/:version/records/create'),
  workoutHistoryDetail(
    '/workouts/:workoutId/history/:version/records/:workoutRecordId',
  ),
  updateWorkoutRecord(
    '/workouts/:workoutId/history/:version/records/:workoutRecordId/update',
  ),
  activeWorkout('/workouts/:id/active'),
  workoutDetail('/workouts/:id'),
  exerciseRecords('/exercises/:id/records'),
  workoutPlanList('/workout-plans'),
  workoutPlanHistory('/workout-plans/history'),
  workoutPlanEdit('/workout-plans/:id/edit'),
  activeWorkoutPlan('/workout-plans/:id/active'),
  workoutPlanDetail('/workout-plans/:id'),
  reminderPreferences('/settings/reminders'),
  strengthGoals('/strength-goals'),
  foods('/foods'),
  foodCreation('/foods/create'),
  foodUpdate('/foods/:id/edit'),
  foodDetails('/foods/:id'),
  recipes('/recipes'),
  recipeCreation('/recipes/create'),
  recipeUpdate('/recipes/:id/edit'),
  recipeDetails('/recipes/:id'),
  macroGoals('/macro-goals'),
  macroTracker('/macro-tracker'),
  mealPlanList('/meal-plans'),
  mealPlanCreation('/meal-plans/create'),
  mealPlanUpdate('/meal-plans/:id/edit'),
  mealPlanDetails('/meal-plans/:id');

  final String name;

  const Routes(this.name);
}
