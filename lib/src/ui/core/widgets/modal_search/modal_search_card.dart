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

import 'package:flutter/material.dart';

import '../layout/list_card.dart';
import './modal_search_entity_name.dart';

class ModalSearchCard extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final double margins;
  final double padding;
  final double fontSize;
  final VoidCallback onTap;

  const ModalSearchCard({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.margins,
    required this.padding,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: margins,
      padding: padding,
      onTap: onTap,
      children: [
        Row(
          children: [
            Expanded(
              child: ModalSearchEntityName(
                name: name,
                isFavorite: isFavorite,
                fontSize: fontSize,
              ),
            ),
            Icon(Icons.add, size: fontSize * 1.2, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}
