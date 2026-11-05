import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/dtos/equipment_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'muscle_badge.dart';
import 'muscle_group_badge.dart';

class MusclesData extends StatelessWidget {
  const MusclesData({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _PrimaryData extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final MuscleGroup muscleGroup;
  final Set<Muscle> primaryMuscles;

  const _PrimaryData({
    required this.theme,
    required this.sizes,
    required this.muscleGroup,
    required this.primaryMuscles,
  });

  @override
  Widget build(BuildContext context) {
    // If no muscles at all, return empty (shouldn't happen usually)
    if (primaryMuscles.isEmpty) {
      // Show only muscle group if no specific muscles
      return _MuscleGroupSection(
        sizes: sizes,
        muscleGroup: muscleGroup,
        theme: theme,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _MuscleGroupSection(
            sizes: sizes,
            muscleGroup: muscleGroup,
            theme: theme,
          ),
        ),
        Expanded(
          child: _MusclesSection(
            title: '💪 Primary Muscles',
            sizes: sizes,
            muscles: primaryMuscles,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _MuscleGroupSection extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final MuscleGroup muscleGroup;
  final ThemeData theme;

  const _MuscleGroupSection({
    required this.sizes,
    required this.muscleGroup,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '🏋️‍♂️ Muscle Group',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        MuscleGroupBadge(
          muscleGroup: muscleGroup,
          fontSize: sizes.smallFontSize,
          theme: theme,
        ),
      ],
    );
  }
}

class _MusclesSection extends StatelessWidget {
  final String title;
  final DataDisplaySizesList sizes;
  final Set<Muscle> muscles;
  final ThemeData theme;

  const _MusclesSection({
    required this.title,
    required this.sizes,
    required this.muscles,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dataSpacing = sizes.spacing / 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        Wrap(
          spacing: dataSpacing,
          runSpacing: dataSpacing,
          children: muscles.map((m) {
            return MuscleBadge(
              muscle: m,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SecondaryData extends StatelessWidget {
  final List<EquipmentDto> equipments;
  final Set<Muscle> secondaryMuscles;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const _SecondaryData({
    required this.equipments,
    required this.secondaryMuscles,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (secondaryMuscles.isEmpty && equipments.isEmpty) {
      return const SizedBox.shrink();
    }
    if (secondaryMuscles.isNotEmpty && equipments.isEmpty) {
      return _MusclesSection(
        title: '💪 Secondary Muscles',
        sizes: sizes,
        muscles: secondaryMuscles,
        theme: theme,
      );
    }
    if (secondaryMuscles.isEmpty && equipments.isNotEmpty) {
      return _EquipmentData(theme: theme, sizes: sizes, equipments: equipments);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _EquipmentData(
            theme: theme,
            sizes: sizes,
            equipments: equipments,
          ),
        ),
        Expanded(
          child: _MusclesSection(
            title: '🥈 Secondary Muscles',
            sizes: sizes,
            muscles: secondaryMuscles,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _EquipmentData extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final List<EquipmentDto> equipments;

  const _EquipmentData({
    required this.theme,
    required this.sizes,
    required this.equipments,
  });

  @override
  Widget build(BuildContext context) {
    final dataSpacing = sizes.spacing / 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center, size: sizes.subtitleFontSize),
            Flexible(
              child: Text(
                ' Equipment',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.spacing / 2),
        Wrap(
          spacing: dataSpacing,
          runSpacing: dataSpacing,
          children: equipments.map((equipment) {
            return _EquipmentBadge(
              name: equipment.name,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EquipmentBadge extends StatelessWidget {
  final String name;
  final double fontSize;
  final ThemeData theme;

  const _EquipmentBadge({
    required this.name,
    required this.fontSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: BeveledRectangleBorder(),
      side: BorderSide(color: theme.colorScheme.onSurface, width: 0.5),
      visualDensity: VisualDensity.compact,
      label: Text(name, style: TextStyle(fontSize: fontSize)),
    );
  }
}
