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

class ModalSearchEntityName extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final double fontSize;

  const ModalSearchEntityName({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFavorite) {
      return Text(
        name,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            "$name ",
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.favorite, color: Colors.red, size: fontSize * 1.2),
      ],
    );
  }
}
