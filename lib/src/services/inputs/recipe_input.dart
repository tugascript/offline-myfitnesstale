import 'package:equatable/equatable.dart';
import '../../common/nullable.dart';

class RecipeItemInput extends Equatable {
  final int foodId;
  final int? portionId;
  final int amount;

  const RecipeItemInput({
    required this.foodId,
    this.portionId,
    required this.amount,
  });

  @override
  List<Object?> get props => [foodId, portionId, amount];
}

class RecipeInput {
  final String name;
  final Nullable<String> description;
  final int servingsYield;
  final List<RecipeItemInput> items;
  const RecipeInput(
      {required this.name,
      this.description = const Nullable(null),
      required this.servingsYield,
      required this.items});
}
