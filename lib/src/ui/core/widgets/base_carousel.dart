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

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../sizes/data_display_sizes.dart';

typedef CarouselSemanticLabelBuilder = String Function(
  String label,
  int index,
  int total,
);

/// A horizontally scrollable carousel that keeps each page mounted
/// and sizes itself to the natural height of the content.
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
    if (_page != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) return;
        _controller.jumpTo(_page * _controller.position.viewportDimension);
      });
    }
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
                child: _CarouselPages(
                  pageWidth: width,
                  crossAxisAlignment: widget.crossAxisAlignment,
                  children: [
                    for (final (index, child) in widget.children.indexed)
                      SizedBox(
                        key: prefix != null
                            ? ValueKey('$prefix-content-$index')
                            : null,
                        width: width,
                        child: child,
                      ),
                  ],
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

class _CarouselPages extends MultiChildRenderObjectWidget {
  final double pageWidth;
  final CrossAxisAlignment crossAxisAlignment;

  const _CarouselPages({
    required this.pageWidth,
    required this.crossAxisAlignment,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCarouselPages(pageWidth, crossAxisAlignment);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCarouselPages renderObject,
  ) {
    renderObject
      ..pageWidth = pageWidth
      ..crossAxisAlignment = crossAxisAlignment;
  }
}

class _CarouselPageParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCarouselPages extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CarouselPageParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CarouselPageParentData>,
        RelayoutWhenSystemFontsChangeMixin {
  _RenderCarouselPages(this._pageWidth, this._crossAxisAlignment);

  double _pageWidth;
  double get pageWidth => _pageWidth;
  set pageWidth(double value) {
    if (_pageWidth == value) return;
    _pageWidth = value;
    markNeedsLayout();
  }

  CrossAxisAlignment _crossAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CarouselPageParentData) {
      child.parentData = _CarouselPageParentData();
    }
  }

  double _computeMaxChildHeight() {
    final measureConstraints = BoxConstraints.tightFor(width: _pageWidth);
    var maxHeight = 0.0;
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      maxHeight = math.max(
        maxHeight,
        child.getDryLayout(measureConstraints).height,
      );
    }
    return maxHeight;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _pageWidth * childCount;

  @override
  double computeMaxIntrinsicWidth(double height) => _pageWidth * childCount;

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    var maxHeight = 0.0;
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      maxHeight = math.max(maxHeight, child.getMaxIntrinsicHeight(_pageWidth));
    }
    return maxHeight;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final maxHeight = _computeMaxChildHeight();
    return constraints.constrain(Size(_pageWidth * childCount, maxHeight));
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.constrain(Size.zero);
      return;
    }

    final targetHeight = _computeMaxChildHeight();
    // Keep maxHeight unbounded so children are never relayout boundaries and
    // async font loads or inner updates can resize the carousel without overflow.
    final childConstraints = _crossAxisAlignment == CrossAxisAlignment.stretch
        ? BoxConstraints(
            minWidth: _pageWidth,
            maxWidth: _pageWidth,
            minHeight: targetHeight,
          )
        : BoxConstraints.tightFor(width: _pageWidth);

    var actualMaxHeight = 0.0;
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      child.layout(childConstraints, parentUsesSize: true);
      actualMaxHeight = math.max(actualMaxHeight, child.size.height);
    }

    var x = 0.0;
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final parentData = child.parentData! as _CarouselPageParentData;
      final dy = switch (_crossAxisAlignment) {
        CrossAxisAlignment.end => actualMaxHeight - child.size.height,
        CrossAxisAlignment.center => (actualMaxHeight - child.size.height) / 2,
        CrossAxisAlignment.start ||
        CrossAxisAlignment.stretch ||
        CrossAxisAlignment.baseline => 0.0,
      };
      parentData.offset = Offset(x, dy);
      x += _pageWidth;
    }

    size = constraints.constrain(Size(_pageWidth * childCount, actualMaxHeight));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
