import 'package:flutter/material.dart';

import '../../models/common.dart';
import '../../models/enums.dart';
import '../../services/dtos/equipment_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'muscles_data.dart';
import 'muscles_diagram.dart';

class MusclesCarousel extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final MuscleGroup muscleGroup;
  final TargetMuscles muscles;
  final List<EquipmentDto> equipments;
  final ThemeData? theme;
  final Color primaryColor;
  final Color secondaryColor;
  final bool pixelated;
  final List<String> pageLabels;

  const MusclesCarousel({
    super.key,
    required this.sizes,
    required this.muscleGroup,
    required this.muscles,
    this.equipments = const <EquipmentDto>[],
    this.theme,
    this.primaryColor = MusclesDiagram.defaultPrimaryColor,
    this.secondaryColor = MusclesDiagram.defaultSecondaryColor,
    this.pixelated = false,
    this.pageLabels = const ['Diagram', 'Data'],
  });

  factory MusclesCarousel.fromMuscles({
    Key? key,
    required DataDisplaySizesList sizes,
    required MuscleGroup muscleGroup,
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
  State<MusclesCarousel> createState() => _MusclesCarouselState();
}

class _MusclesCarouselState extends State<MusclesCarousel> {
  final _controller = ScrollController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme ?? Theme.of(context);
    final colors = resolvedTheme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth == 0 &&
                    notification.metrics.axis == Axis.horizontal) {
                  final page = (notification.metrics.pixels / width)
                      .round()
                      .clamp(0, widget.pageLabels.length - 1);
                  if (page != _page) setState(() => _page = page);
                }
                return false;
              },
              child: SingleChildScrollView(
                key: const ValueKey('muscles-carousel-scroll'),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width,
                        child: MusclesDiagram(
                          muscles: widget.muscles,
                          sizes: widget.sizes,
                          theme: resolvedTheme,
                          primaryColor: widget.primaryColor,
                          secondaryColor: widget.secondaryColor,
                          pixelated: widget.pixelated,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MusclesData(
                          theme: resolvedTheme,
                          sizes: widget.sizes,
                          muscleGroup: widget.muscleGroup,
                          primaryMuscles: widget.muscles.primary,
                          secondaryMuscles: widget.muscles.secondary,
                          equipments: widget.equipments,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            Row(
              children: [
                for (final (index, label) in widget.pageLabels.indexed)
                  Expanded(
                    child: Semantics(
                      selected: _page == index,
                      label:
                          '$label, ${index + 1} of ${widget.pageLabels.length}',
                      child: TextButton(
                        key: ValueKey('muscles-carousel-page-$index'),
                        onPressed: () => _controller.animateTo(
                          index * width,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: widget.sizes.spacing / 2,
                          ),
                          foregroundColor: _page == index
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              key: ValueKey('muscles-carousel-line-$index'),
                              height: widget.sizes.spacing / 4,
                              color: _page == index
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
