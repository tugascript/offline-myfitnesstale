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

import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/enums.dart';

class EquipmentRarityBadge extends StatelessWidget {
  final EquipmentRarity? rarity;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;

  const EquipmentRarityBadge({
    super.key,
    required this.rarity,
    required this.spacing,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(rarity);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
      decoration: BoxDecoration(
        color: rarityColor.withValues(alpha: 0.2),
        border: Border.all(color: rarityColor, width: 1),
      ),
      child: Text(
        EnumDisplayNames.getEquipmentRarityDisplayName(rarity),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: rarityColor,
        ),
      ),
    );
  }

  Color _rarityColor(EquipmentRarity? r) {
    switch (r) {
      case EquipmentRarity.veryCommon:
        return Colors.grey;
      case EquipmentRarity.common:
        return Colors.green;
      case EquipmentRarity.uncommon:
        return Colors.blue;
      case EquipmentRarity.rare:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.amber;
      case null:
        return Colors.grey;
    }
  }
}
