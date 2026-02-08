import 'package:flutter/material.dart';

import '../../services/dtos/equipment_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/list_card.dart';

class EquipmentCard extends StatelessWidget {
  final EquipmentDto equipment;
  final VoidCallback onTap;
  final DataDisplaySizesList sizes;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.onTap,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        Text(
          equipment.name,
          style: TextStyle(
            fontSize: sizes.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
