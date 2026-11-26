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

import '../../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/exercise_details.dart';
import '../../../core/sizes/data_display_sizes.dart';

class CardioExerciseDetailsSection extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final CardioExerciseDetails details;
  final List<EquipmentDto> equipments;

  const CardioExerciseDetailsSection({
    super.key,
    required this.theme,
    required this.sizes,
    required this.details,
    this.equipments = const <EquipmentDto>[],
  });

  @override
  Widget build(BuildContext context) {
    final double chipSpacing = sizes.quarterSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.directions_run, size: sizes.subtitleFontSize),
            SizedBox(width: sizes.quarterSpacing),
            Flexible(
              child: Text(
                'Cardio Details',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.halfSpacing),
        Wrap(
          spacing: chipSpacing,
          runSpacing: chipSpacing,
          children: [
            _CardioDetailChip(
              label:
                  'Mode: ${EnumDisplayNames.getCardioBaseModeDisplayName(details.defaultMode)}',
              fontSize: sizes.smallFontSize,
              theme: theme,
              backgroundColor: theme.colorScheme.secondary.withValues(
                alpha: 0.2,
              ),
            ),
            _CardioDetailChip(
              label:
                  'Unit Type: ${EnumDisplayNames.getCardioUnitTypeDisplayName(details.unitType)}',
              fontSize: sizes.smallFontSize,
              theme: theme,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            _CardioDetailChip(
              label: 'Unit: ${details.unit}',
              fontSize: sizes.smallFontSize,
              theme: theme,
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface,
                width: 0.5,
              ),
            ),
          ],
        ),
        if (equipments.isNotEmpty) ...[
          SizedBox(height: sizes.spacing),
          Row(
            children: [
              Icon(Icons.fitness_center, size: sizes.subtitleFontSize),
              SizedBox(width: sizes.quarterSpacing),
              Flexible(
                child: Text(
                  'Equipment',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.halfSpacing),
          Wrap(
            spacing: chipSpacing,
            runSpacing: chipSpacing,
            children: equipments
                .map(
                  (equipment) => _CardioDetailChip(
                    label: equipment.name,
                    fontSize: sizes.smallFontSize,
                    theme: theme,
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _CardioDetailChip extends StatelessWidget {
  final String label;
  final double fontSize;
  final ThemeData theme;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const _CardioDetailChip({
    required this.label,
    required this.fontSize,
    required this.theme,
    this.backgroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: const BeveledRectangleBorder(),
      side: borderSide ?? BorderSide.none,
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
      label: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }
}
