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

import '../../../data/utils/json_data.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../sizes/data_display_sizes.dart';
import './base_carousel.dart';
import './muscles_data.dart';
import './muscles_diagram.dart';

class MusclesCarousel extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Set<MuscleGroup> muscleGroups;
  final TargetMuscles muscles;
  final List<EquipmentDto> equipments;
  final ThemeData? theme;
  final Color primaryColor;
  final Color secondaryColor;
  final bool pixelated;
  final List<String> pageLabels;

  MuscleGroup? get muscleGroup =>
      muscleGroups.isNotEmpty ? muscleGroups.first : null;

  MusclesCarousel({
    super.key,
    required this.sizes,
    MuscleGroup? muscleGroup,
    Set<MuscleGroup>? muscleGroups,
    required this.muscles,
    this.equipments = const <EquipmentDto>[],
    this.theme,
    this.primaryColor = MusclesDiagram.defaultPrimaryColor,
    this.secondaryColor = MusclesDiagram.defaultSecondaryColor,
    this.pixelated = false,
    this.pageLabels = const ['Diagram', 'Data'],
  }) : muscleGroups =
           muscleGroups ??
           (muscleGroup != null ? {muscleGroup} : const <MuscleGroup>{});

  factory MusclesCarousel.fromMuscles({
    Key? key,
    required DataDisplaySizesList sizes,
    MuscleGroup? muscleGroup,
    Set<MuscleGroup>? muscleGroups,
    Set<Muscle> primaryMuscles = const <Muscle>{},
    Set<Muscle> secondaryMuscles = const <Muscle>{},
    List<EquipmentDto> equipments = const <EquipmentDto>[],
    ThemeData? theme,
    Color primaryColor = MusclesDiagram.defaultPrimaryColor,
    Color secondaryColor = MusclesDiagram.defaultSecondaryColor,
    bool pixelated = false,
    List<String> pageLabels = const ['Diagram', 'Data'],
  }) {
    return MusclesCarousel(
      key: key,
      sizes: sizes,
      muscleGroup: muscleGroup,
      muscleGroups: muscleGroups,
      muscles: TargetMuscles(
        primary: primaryMuscles,
        secondary: secondaryMuscles,
      ),
      equipments: equipments,
      theme: theme,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      pixelated: pixelated,
      pageLabels: pageLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? Theme.of(context);

    return BaseCarousel(
      sizes: sizes,
      theme: resolvedTheme,
      keyPrefix: 'muscles-carousel',
      labels: pageLabels,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MusclesDiagram(
          muscles: muscles,
          sizes: sizes,
          theme: resolvedTheme,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          pixelated: pixelated,
        ),
        MusclesData(
          theme: resolvedTheme,
          sizes: sizes,
          muscleGroups: muscleGroups,
          primaryMuscles: muscles.primary,
          secondaryMuscles: muscles.secondary,
          equipments: equipments,
        ),
      ],
    );
  }
}
