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

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/not_found_list.dart';
import './equipment_card.dart';

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
