import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

typedef CarouselSemanticLabelBuilder = String Function(
  String label,
  int index,
  int total,
);

/// A horizontally scrollable carousel that keeps each page mounted
/// and sizes itself to the natural intrinsic height of the content.
class BaseCarousel extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData? theme;
  final List<Widget> children;
  final List<String> labels;
  final String? title;
  final Widget? header;
  final String? keyPrefix;
  final int initialPage;
  final CrossAxisAlignment crossAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final CarouselSemanticLabelBuilder? semanticLabelBuilder;
  final ValueChanged<int>? onPageChanged;
  final Duration animationDuration;
  final Curve animationCurve;

  const BaseCarousel({
    super.key,
    required this.sizes,
    this.theme,
    required this.children,
    required this.labels,
    this.title,
    this.header,
    this.keyPrefix,
    this.initialPage = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.semanticLabelBuilder,
    this.onPageChanged,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOut,
  }) : assert(
         children.length == labels.length,
         'children and labels must have the same length',
       );

  @override
  State<BaseCarousel> createState() => _BaseCarouselState();
}

class _BaseCarouselState extends State<BaseCarousel> {
  late final ScrollController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildSemanticLabel(String label, int index, int total) {
    if (widget.semanticLabelBuilder != null) {
      return widget.semanticLabelBuilder!(label, index, total);
    }
    return '$label, ${index + 1} of $total';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme ?? Theme.of(context);
    final colors = resolvedTheme.colorScheme;
    final prefix = widget.keyPrefix;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.columnCrossAxisAlignment,
          children: [
            if (widget.header != null) ...[
              widget.header!,
              SizedBox(height: widget.sizes.spacing),
            ] else if (widget.title != null) ...[
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: widget.sizes.spacing),
            ],
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth == 0 &&
                    notification.metrics.axis == Axis.horizontal) {
                  final page = (notification.metrics.pixels / width)
                      .round()
                      .clamp(0, widget.children.length - 1);
                  if (page != _page) {
                    setState(() => _page = page);
                    widget.onPageChanged?.call(page);
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                key: prefix != null ? ValueKey('$prefix-scroll') : null,
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: widget.crossAxisAlignment,
                    children: [
                      for (final child in widget.children)
                        SizedBox(width: width, child: child),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.sizes.spacing / 2),
            Row(
              children: [
                for (final (index, label) in widget.labels.indexed)
                  Expanded(
                    child: Semantics(
                      selected: _page == index,
                      label: _buildSemanticLabel(
                        label,
                        index,
                        widget.children.length,
                      ),
                      child: TextButton(
                        key: prefix != null
                            ? ValueKey('$prefix-page-$index')
                            : null,
                        onPressed: () => _controller.animateTo(
                          index * width,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
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
                              key: prefix != null
                                  ? ValueKey('$prefix-line-$index')
                                  : null,
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
