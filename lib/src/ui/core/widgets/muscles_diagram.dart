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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../sizes/data_display_sizes.dart';

class MusclesDiagram extends StatelessWidget {
  static const String assetPath = 'assets/svgs/muscles.svg';
  static const String frontBackAssetPath = 'assets/svgs/muscles-front-back.svg';
  static const Color defaultPrimaryColor = Color(0xFFC14B23);
  static const Color defaultSecondaryColor = Color(0xFFEDB8A9);

  final TargetMuscles muscles;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Color primaryColor;
  final Color secondaryColor;
  final bool pixelated;

  const MusclesDiagram({
    super.key,
    required this.muscles,
    required this.sizes,
    required this.theme,
    this.primaryColor = defaultPrimaryColor,
    this.secondaryColor = defaultSecondaryColor,
    this.pixelated = false,
  });

  @override
  Widget build(BuildContext context) {
    final loader = MusclesSvgLoader(
      muscles: muscles,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      assetName: pixelated ? assetPath : frontBackAssetPath,
      assetBundle: DefaultAssetBundle.of(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: sizes.svgMaxHeight),
          child: AspectRatio(
            aspectRatio: 200 / 170,
            child: SvgPicture(
              loader,
              key: ValueKey(loader),
              fit: BoxFit.contain,
              semanticsLabel: 'Target muscles diagram',
            ),
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: sizes.spacing,
          runSpacing: sizes.spacing / 4,
          children: [
            _LegendItem(
              color: primaryColor,
              label: 'Primary',
              sizes: sizes,
              theme: theme,
            ),
            _LegendItem(
              color: secondaryColor,
              label: 'Secondary',
              sizes: sizes,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = sizes.smallFontSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        SizedBox(width: sizes.spacing / 3),
        Text(label, style: TextStyle(fontSize: sizes.smallFontSize)),
      ],
    );
  }
}

class MusclesSvgLoader extends SvgAssetLoader {
  static const Map<Muscle, Set<String>> muscleToSvgRegionIds = {
    Muscle.chest: {'chest'},
    Muscle.upperChest: {'chest'},
    Muscle.lowerChest: {'chest'},
    Muscle.innerChest: {'chest'},
    Muscle.shoulders: {'front_delts', 'rear_delts'},
    Muscle.frontDelts: {'front_delts'},
    Muscle.sideDelts: {'front_delts'},
    Muscle.rearDelts: {'rear_delts'},
    Muscle.triceps: {'triceps'},
    Muscle.neck: {'neck'},
    Muscle.trapezius: {'trapezius'},
    Muscle.upperTrapezius: {'trapezius'},
    Muscle.middleTrapezius: {'trapezius'},
    Muscle.lowerTrapezius: {'trapezius'},
    Muscle.rhomboids: {'trapezius'},
    Muscle.lats: {'lats'},
    Muscle.biceps: {'biceps'},
    Muscle.brachialis: {'biceps'},
    Muscle.forearms: {'forearms'},
    Muscle.quadriceps: {'quadriceps'},
    Muscle.hamstrings: {'hamstrings'},
    Muscle.glutes: {'glutes'},
    Muscle.calves: {'calves'},
    Muscle.tibialis: {'tibialis'},
    Muscle.adductors: {'adductors'},
    Muscle.abdominals: {'upper_abs', 'lower_abs'},
    Muscle.upperAbs: {'upper_abs'},
    Muscle.lowerAbs: {'lower_abs'},
    Muscle.obliques: {'obliques'},
    Muscle.lowerBack: {'lower_back'},
  };

  final TargetMuscles muscles;
  final Color primaryColor;
  final Color secondaryColor;

  const MusclesSvgLoader({
    required this.muscles,
    this.primaryColor = MusclesDiagram.defaultPrimaryColor,
    this.secondaryColor = MusclesDiagram.defaultSecondaryColor,
    String assetName = MusclesDiagram.assetPath,
    super.assetBundle,
    super.packageName,
  }) : super(assetName);

  static Set<String> resolveRegionIds(Set<Muscle> muscleSet) {
    final regionIds = <String>{};
    for (final muscle in muscleSet) {
      final mapped = muscleToSvgRegionIds[muscle];
      if (mapped != null) {
        regionIds.addAll(mapped);
      }
    }
    return regionIds;
  }

  static String colorToHex(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  static String paintSvg(
    String rawSvg, {
    required TargetMuscles muscles,
    Color primaryColor = MusclesDiagram.defaultPrimaryColor,
    Color secondaryColor = MusclesDiagram.defaultSecondaryColor,
  }) {
    final primaryRegions = resolveRegionIds(muscles.primary);
    final secondaryRegions = resolveRegionIds(muscles.secondary)
        .difference(primaryRegions);

    final primaryHex = colorToHex(primaryColor);
    final secondaryHex = colorToHex(secondaryColor);

    var painted = rawSvg;
    for (final id in primaryRegions) {
      painted = painted.replaceAllMapped(
        RegExp('id="$id" fill="#[0-9a-fA-F]{6}"'),
        (_) => 'id="$id" fill="$primaryHex"',
      );
    }
    for (final id in secondaryRegions) {
      painted = painted.replaceAllMapped(
        RegExp('id="$id" fill="#[0-9a-fA-F]{6}"'),
        (_) => 'id="$id" fill="$secondaryHex"',
      );
    }
    return painted;
  }

  @override
  String provideSvg(ByteData? message) {
    final rawSvg = super.provideSvg(message);
    return paintSvg(
      rawSvg,
      muscles: muscles,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final SvgTheme svgTheme = getTheme(context);
    return SvgCacheKey(
      theme: svgTheme,
      colorMapper: colorMapper,
      keyData: this,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MusclesSvgLoader &&
        super == other &&
        other.muscles == muscles &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, muscles, primaryColor, secondaryColor);
}
