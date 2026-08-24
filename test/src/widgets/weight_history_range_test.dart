import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/widgets/weight/records/weight_records_history.dart';

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
