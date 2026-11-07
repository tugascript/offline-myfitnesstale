import 'package:flutter/material.dart';

import '../../models/common.dart';
import '../../models/enums.dart';
import '../../services/dtos/equipment_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'base_carousel.dart';
import 'muscles_data.dart';
import 'muscles_diagram.dart';

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
