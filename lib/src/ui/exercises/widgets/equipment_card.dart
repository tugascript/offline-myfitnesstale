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

import 'package:flutter/material.dart';

import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/layout/list_card.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.margins / 2),
      child: ListCard(
        margin: sizes.margins / 2,
        padding: sizes.padding,
        onTap: onTap,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  equipment.name,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: sizes.fontSize * 1.2,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
