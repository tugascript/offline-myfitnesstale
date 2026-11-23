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

import '../../../core/sizes/data_display_sizes.dart';
import '../../utils/tacker_scope.dart';

class MacroTrackerScopeSelection extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final TrackerScope scope;
  final ValueChanged<TrackerScope> onScopeChanged;
  final VoidCallback onGoToToday;
  final PageController? pageController;

  const MacroTrackerScopeSelection({
    super.key,
    required this.sizes,
    required this.theme,
    required this.scope,
    required this.onScopeChanged,
    required this.onGoToToday,
    this.pageController,
  });

  String _labelForScope(TrackerScope item) => switch (item) {
    TrackerScope.day => 'Day',
    TrackerScope.week => 'Week',
    TrackerScope.month => 'Month',
  };

  double _currentPage() {
    final controller = pageController;
    if (controller != null &&
        controller.hasClients &&
        controller.position.hasContentDimensions) {
      final page = controller.page;
      if (page != null) {
        return page.clamp(0.0, (TrackerScope.values.length - 1).toDouble());
      }
    }
    return scope.index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    const scopes = TrackerScope.values;

    Widget buildStripContent(double page) {
      final maxIndex = scopes.length - 1;
      final alignmentX = maxIndex > 0 ? -1.0 + 2.0 * (page / maxIndex) : 0.0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < scopes.length; i++)
                Expanded(
                  child: Semantics(
                    label: _labelForScope(scopes[i]),
                    selected: scopes[i] == scope,
                    button: true,
                    child: InkWell(
                      onTap: () => onScopeChanged(scopes[i]),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: sizes.quarterSpacing,
                          bottom: sizes.halfSpacing,
                        ),
                        child: Text(
                          _labelForScope(scopes[i]),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            fontWeight: (page - i).abs() < 0.5
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: Color.lerp(
                              colors.onSurfaceVariant,
                              colors.primary,
                              (1.0 - (page - i).abs()).clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: sizes.quarterSpacing,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: colors.outlineVariant),
                Align(
                  key: const ValueKey('macro-tracker-scope-indicator-align'),
                  alignment: Alignment(alignmentX, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / scopes.length,
                    heightFactor: 1,
                    child: Container(
                      key: const ValueKey('macro-tracker-scope-indicator'),
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final animatedStrip = pageController != null
        ? AnimatedBuilder(
            animation: pageController!,
            builder: (context, _) => buildStripContent(_currentPage()),
          )
        : buildStripContent(scope.index.toDouble());

    final strip = GestureDetector(
      key: const ValueKey('macro-tracker-scope-selector'),
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity;
        if (velocity == null) return;
        final currentIndex = scopes.indexOf(scope);
        if (velocity < -100 && currentIndex < scopes.length - 1) {
          onScopeChanged(scopes[currentIndex + 1]);
        } else if (velocity > 100 && currentIndex > 0) {
          onScopeChanged(scopes[currentIndex - 1]);
        }
      },
      child: animatedStrip,
    );

    final todayButton = TextButton(
      key: const ValueKey('macro-tracker-today-btn'),
      onPressed: onGoToToday,
      child: Text('Today', style: TextStyle(fontSize: sizes.fontSize)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final minInlineWidth = MediaQuery.textScalerOf(context)
            .scale(sizes.fontSize * 18);
        if (constraints.maxWidth >= minInlineWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: strip),
              SizedBox(width: sizes.halfSpacing),
              todayButton,
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            strip,
            SizedBox(height: sizes.quarterSpacing),
            Align(alignment: Alignment.centerRight, child: todayButton),
          ],
        );
      },
    );
  }
}
