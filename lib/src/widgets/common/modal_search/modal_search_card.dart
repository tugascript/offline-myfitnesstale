import 'package:flutter/material.dart';

import '../../layout/list_card.dart';
import 'modal_search_entity_name.dart';

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
            Icon(
              Icons.add,
              size: fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
