import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import 'active_meal_plan_widget.dart';
import 'active_plan_widget.dart';

/// Keeps both feature widgets mounted and uses their natural maximum height.
/// Unlike a fixed-height PageView, this also fits asynchronously loaded content
/// and larger text without clipping or an inner vertical scroll area.
class ActivePlansCarousel extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActivePlansCarousel({
    super.key,
    required this.sizes,
    required this.theme,
  });

  @override
  State<ActivePlansCarousel> createState() => _ActivePlansCarouselState();
}

class _ActivePlansCarouselState extends State<ActivePlansCarousel> {
  final _controller = ScrollController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active plans',
              style: TextStyle(
                fontSize: widget.sizes.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.sizes.spacing),
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth == 0 &&
                    notification.metrics.axis == Axis.horizontal) {
                  final page = (notification.metrics.pixels / width)
                      .round()
                      .clamp(0, 1);
                  if (page != _page) setState(() => _page = page);
                }
                return false;
              },
              child: SingleChildScrollView(
                key: const ValueKey('active-plans-scroll'),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: width,
                        child: ActivePlanWidget(
                          sizes: widget.sizes,
                          showTitle: false,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: ActiveMealPlanWidget(
                          theme: widget.theme,
                          sizes: widget.sizes,
                          showTitle: false,
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
                for (final (index, label) in ['Workout', 'Meal'].indexed)
                  Expanded(
                    child: Semantics(
                      selected: _page == index,
                      label: '$label plan, ${index + 1} of 2',
                      child: TextButton(
                        key: ValueKey('active-plans-page-$index'),
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
                              key: ValueKey('active-plans-line-$index'),
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
