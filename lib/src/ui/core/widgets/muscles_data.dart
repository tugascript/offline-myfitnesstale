import 'package:flutter/material.dart';

import '../../../data/utils/json_data.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../sizes/data_display_sizes.dart';
import 'muscle_group_badge.dart';
import 'muscles_wrap.dart';

class MusclesData extends StatelessWidget {
  final ThemeData? theme;
  final DataDisplaySizesList sizes;
  final Set<MuscleGroup> muscleGroups;
  final Set<Muscle> primaryMuscles;
  final Set<Muscle> secondaryMuscles;
  final List<EquipmentDto> equipments;

  MuscleGroup? get muscleGroup =>
      muscleGroups.isNotEmpty ? muscleGroups.first : null;

  MusclesData({
    super.key,
    this.theme,
    required this.sizes,
    MuscleGroup? muscleGroup,
    Set<MuscleGroup>? muscleGroups,
    this.primaryMuscles = const <Muscle>{},
    this.secondaryMuscles = const <Muscle>{},
    this.equipments = const <EquipmentDto>[],
  }) : muscleGroups =
           muscleGroups ??
           (muscleGroup != null ? {muscleGroup} : const <MuscleGroup>{});

  MusclesData.fromTargetMuscles({
    super.key,
    this.theme,
    required this.sizes,
    MuscleGroup? muscleGroup,
    Set<MuscleGroup>? muscleGroups,
    required TargetMuscles muscles,
    this.equipments = const <EquipmentDto>[],
  }) : muscleGroups =
           muscleGroups ??
           (muscleGroup != null ? {muscleGroup} : const <MuscleGroup>{}),
       primaryMuscles = muscles.primary,
       secondaryMuscles = muscles.secondary;

  TargetMuscles get targetMuscles =>
      TargetMuscles(primary: primaryMuscles, secondary: secondaryMuscles);

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? Theme.of(context);
    final hasPrimary = muscleGroups.isNotEmpty || primaryMuscles.isNotEmpty;
    final hasSecondary = secondaryMuscles.isNotEmpty || equipments.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sizes.svgMaxHeight),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPrimary)
              _DataRow(
                left: muscleGroups.isNotEmpty
                    ? _MuscleGroupSection(
                        sizes: sizes,
                        muscleGroups: muscleGroups,
                        theme: resolvedTheme,
                      )
                    : null,
                right: primaryMuscles.isNotEmpty
                    ? MusclesWrap(
                        theme: resolvedTheme,
                        sizes: sizes,
                        title: '💪 Primary Muscles',
                        muscles: primaryMuscles,
                      )
                    : null,
              ),
            if (hasPrimary && hasSecondary) SizedBox(height: sizes.spacing),
            if (hasSecondary)
              _DataRow(
                left: equipments.isNotEmpty
                    ? _EquipmentData(
                        theme: resolvedTheme,
                        sizes: sizes,
                        equipments: equipments,
                      )
                    : null,
                right: secondaryMuscles.isNotEmpty
                    ? MusclesWrap(
                        theme: resolvedTheme,
                        sizes: sizes,
                        title: '🥈 Secondary Muscles',
                        muscles: secondaryMuscles,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final Widget? left;
  final Widget? right;

  const _DataRow({this.left, this.right});

  @override
  Widget build(BuildContext context) {
    if (left == null && right == null) return const SizedBox.shrink();
    if (left == null) return right!;
    if (right == null) return left!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left!),
        Expanded(child: right!),
      ],
    );
  }
}

class _MuscleGroupSection extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Set<MuscleGroup> muscleGroups;
  final ThemeData theme;

  const _MuscleGroupSection({
    required this.sizes,
    required this.muscleGroups,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (muscleGroups.isEmpty) return const SizedBox.shrink();
    final dataSpacing = sizes.spacing / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          muscleGroups.length > 1
              ? '🏋️‍♂️ Muscle Groups'
              : '🏋️‍♂️ Muscle Group',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        Wrap(
          spacing: dataSpacing,
          runSpacing: dataSpacing,
          children: muscleGroups.map((mg) {
            return MuscleGroupBadge(
              muscleGroup: mg,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
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
      shape: const BeveledRectangleBorder(),
      side: BorderSide(color: theme.colorScheme.onSurface, width: 0.5),
      visualDensity: VisualDensity.compact,
      label: Text(name, style: TextStyle(fontSize: fontSize)),
    );
  }
}
