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

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/ui/weight/widgets/records/weight_records_history.dart';

void main() {
  test('weight history range accepts 365 days and rejects 366 days', () {
    final start = DateTime(2025, 1, 1);
    expect(
      isWeightHistoryRangeDaySelectable(
        start.add(const Duration(days: 365)),
        start,
        null,
      ),
      isTrue,
    );
    expect(
      isWeightHistoryRangeDaySelectable(
        start.add(const Duration(days: 366)),
        start,
        null,
      ),
      isFalse,
    );
  });
}
