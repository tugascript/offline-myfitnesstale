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
import '../../../../data/services/storage/local_file_storage_service.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/base_details_header.dart';
import '../../../core/widgets/layout/created_by_icon.dart';
import '../../../core/widgets/layout/favorite_icon_button.dart';
import '../../../core/widgets/picture/app_picture.dart';
import 'equipment_rarity_badge.dart';

class EquipmentHeaderCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final EquipmentDto equipment;
  final int relatedExercisesCount;
  final VoidCallback onFavoriteToggle;
  final ThemeData? theme;
  final LocalFileStorageService? storageService;

  const EquipmentHeaderCard({
    super.key,
    required this.sizes,
    required this.equipment,
    required this.relatedExercisesCount,
    required this.onFavoriteToggle,
    this.theme,
    this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? Theme.of(context);

    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            CreatedByIcon(sizes: sizes, createdBy: equipment.createdBy),
            Expanded(
              child: Wrap(
                spacing: sizes.spacing,
                runSpacing: sizes.spacing / 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EquipmentRarityBadge(
                    rarity: equipment.rarity,
                    spacing: sizes.spacing,
                    fontSize: sizes.smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  Text(
                    '$relatedExercisesCount ${relatedExercisesCount == 1 ? 'exercise' : 'exercises'}',
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      fontWeight: FontWeight.w600,
                      color: resolvedTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FavoriteIconButton(
              sizes: sizes,
              isFavorite: equipment.isFavorite,
              onFavoriteToggle: onFavoriteToggle,
            ),
          ],
        ),
        if (equipment.picture != null &&
            equipment.picture!.uri.trim().isNotEmpty) ...[
          SizedBox(height: sizes.spacing),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sizes.modalMaxWidth),
              child: AppPicture(
                picture: equipment.picture!,
                sizes: sizes,
                theme: resolvedTheme,
                storageService: storageService,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
