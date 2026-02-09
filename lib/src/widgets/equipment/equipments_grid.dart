import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/dtos/equipment_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/not_found_list.dart';
import 'equipment_card.dart';

class EquipmentsGrid extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final List<EquipmentDto> equipments;
  final ScrollController? scrollController;

  const EquipmentsGrid({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.equipments,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && equipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (equipments.isEmpty) {
      return NotFoundList(sizes: sizes, name: 'equipments');
    }

    return GridView.builder(
      controller: scrollController,
      itemCount: equipments.length + (isLoading ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.25,
      ),
      itemBuilder: (context, index) {
        if (index == equipments.length) {
          return Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final equipment = equipments[index];
        return EquipmentCard(
          equipment: equipment,
          sizes: sizes,
          onTap: () => context.push('/equipments/${equipment.id}'),
        );
      },
    );
  }
}
