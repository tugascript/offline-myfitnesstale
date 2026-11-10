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

class ExpandingSection extends StatelessWidget {
  final IconData? icon;
  final String title;
  final double titleFountSize;
  final FontWeight titleFontWeight;
  final String? subtitle;
  final double? subtitleFontSize;
  final double padding;
  final bool initiallyExpanded;
  final bool dense;
  final List<Widget> children;

  const ExpandingSection({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    required this.titleFountSize,
    this.subtitleFontSize,
    required this.padding,
    this.initiallyExpanded = false,
    this.dense = false,
    this.titleFontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      dense: dense,
      leading: Icon(icon, size: titleFountSize * 1.2),
      maintainState: true,
      initiallyExpanded: initiallyExpanded,
      title: Text(
        title,
        style: TextStyle(fontSize: titleFountSize, fontWeight: titleFontWeight),
      ),
      subtitle: subtitle != null && subtitleFontSize != null
          ? Text(subtitle!, style: TextStyle(fontSize: subtitleFontSize))
          : null,
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: Column(children: children),
        ),
      ],
    );
  }
}
