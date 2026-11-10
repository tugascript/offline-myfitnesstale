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

import '../../../../utils/nullable.dart';
import '../../../utils/enums.dart';

class WeightGoalInput {
  final int targetWeight;
  final Nullable<int> targetFatPercentage;
  final DateTime startDate;
  final WeightGoalPhase phase;
  final ProgressStatus status;
  final Nullable<DateTime> completedAt;

  const WeightGoalInput({
    required this.targetWeight,
    this.targetFatPercentage = const Nullable<int>(null),
    required this.startDate,
    required this.phase,
    this.status = ProgressStatus.inProgress,
    this.completedAt = const Nullable<DateTime>(null),
  });
}
