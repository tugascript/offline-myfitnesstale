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

import '../../../../utils/nullable.dart';
import '../../../utils/enums.dart';

class StrengthGoalInput {
  final int exerciseId;
  final String name;
  final int targetReps;
  final int targetWeight;
  final int targetMaxStrength;
  final DateTime startDate;
  final ProgressStatus status;
  final Nullable<DateTime> completedAt;
  const StrengthGoalInput({
    required this.exerciseId,
    required this.name,
    required this.targetReps,
    required this.targetWeight,
    required this.targetMaxStrength,
    required this.startDate,
    this.status = ProgressStatus.inProgress,
    this.completedAt = const Nullable(null),
  });
}
