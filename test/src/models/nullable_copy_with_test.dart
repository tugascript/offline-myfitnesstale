import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/food_model.dart';
import 'package:myfitnesstale/src/models/weight_goal_model.dart';
import 'package:myfitnesstale/src/models/weight_record_model.dart';
import 'package:myfitnesstale/src/services/dtos/strength_goal_dto.dart';
import 'package:myfitnesstale/src/services/dtos/weight_goal_dto.dart';
import 'package:myfitnesstale/src/services/dtos/weight_record_dto.dart';

void main() {
  group('nullable copyWith fields', () {
    test('Micronutrients can preserve, clear, and replace nullable values', () {
      const micronutrients = Micronutrients(potassiumMg: 250, zincMg: 3);

      expect(micronutrients.copyWith().potassiumMg, 250);
      expect(
        micronutrients.copyWith(potassiumMg: const Nullable(null)).potassiumMg,
        isNull,
      );
      expect(micronutrients.copyWith(zincMg: const Nullable(5)).zincMg, 5);
    });

    test('Food can preserve, clear, and replace nullable text fields', () {
      final food = Food.create(
        name: 'Oats',
        category: FoodCategory.grainsAndCereals,
        brand: 'Mill',
        servingSizeBaseGrams: 100,
        caloriesBase: 380,
        proteinBase: 13,
        carbsBase: 68,
        fatBase: 7,
      );

      expect(food.copyWith().brand, 'Mill');
      expect(food.copyWith(brand: const Nullable(null)).brand, isNull);
      expect(food.copyWith(brand: const Nullable('Farm')).brand, 'Farm');
      expect(food.copyWith(id: const Nullable(12)).id, 12);
      expect(food.copyWith(id: const Nullable(null)).id, isNull);
    });

    test('StrengthGoalDto can clear its completion date', () {
      final completedAt = DateTime(2026, 10, 12);
      final goal = StrengthGoalDto(
        id: 1,
        name: 'Bench press',
        targetReps: 5,
        targetWeight: 80000,
        targetMaxStrength: 90000,
        exerciseId: 2,
        status: ProgressStatus.completed,
        startDate: DateTime(2026, 10, 1),
        completedAt: completedAt,
      );

      expect(goal.copyWith().completedAt, completedAt);
      expect(
        goal.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
      expect(
        goal
            .copyWith(completedAt: Nullable(DateTime(2026, 10, 11)))
            .completedAt,
        DateTime(2026, 10, 11),
      );
    });

    test('WeightRecord and WeightRecordDto can clear nullable fields', () {
      final record = WeightRecord.create(
        weight: 80000,
        recordDate: 1700000000,
        fatPercentage: 1800,
        pictureUri: 'file:///photo.jpg',
        weightGoalId: 3,
      );

      expect(record.copyWith().fatPercentage, 1800);
      expect(record.copyWith().pictureUri, 'file:///photo.jpg');
      expect(record.copyWith().weightGoalId, 3);
      expect(
        record.copyWith(fatPercentage: const Nullable(null)).fatPercentage,
        isNull,
      );
      expect(
        record.copyWith(pictureUri: const Nullable(null)).pictureUri,
        isNull,
      );
      expect(
        record.copyWith(weightGoalId: const Nullable(null)).weightGoalId,
        isNull,
      );

      final dto = WeightRecordDto.fromModel(
        record.copyWith(id: const Nullable(1)),
      );
      expect(dto.copyWith().fatPercentage, 1800);
      expect(
        dto.copyWith(fatPercentage: const Nullable(null)).fatPercentage,
        isNull,
      );
      expect(dto.copyWith(pictureUri: const Nullable(null)).pictureUri, isNull);
    });

    test('WeightGoal and WeightGoalDto can clear nullable fields', () {
      final goal = WeightGoal.create(
        targetWeight: 75000,
        targetFatPercentage: 1500,
        startDate: 1700000000,
        phase: WeightGoalPhase.cut,
        status: ProgressStatus.completed,
        completedAt: 1700086400,
      );

      expect(goal.copyWith().targetFatPercentage, 1500);
      expect(goal.copyWith().completedAt, 1700086400);
      expect(
        goal
            .copyWith(targetFatPercentage: const Nullable(null))
            .targetFatPercentage,
        isNull,
      );
      expect(
        goal.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final dto = WeightGoalDto.fromModel(goal.copyWith(id: const Nullable(1)));
      expect(dto.copyWith().targetFatPercentage, 1500);
      expect(
        dto
            .copyWith(targetFatPercentage: const Nullable(null))
            .targetFatPercentage,
        isNull,
      );
      expect(
        dto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
    });
  });
}
