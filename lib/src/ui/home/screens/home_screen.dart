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

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../widgets/active/active_plans_carousel.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/welcome_section.dart';

class HomeScreen extends StatelessWidget {
  static const name = "home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);

    return ResponsiveScaffold(
      title: "My Fitness Tale",
      showBackButton: false,
      body: Container(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            WelcomeSection(sizes: sizes),
            SizedBox(height: sizes.spacing),

            // Active workout and meal plans
            ActivePlansCarousel(theme: theme, sizes: sizes),
            SizedBox(height: sizes.spacing),

            // Quick Actions
            QuickActionsWidget(theme: theme, sizes: sizes),
          ],
        ),
      ),
    );
  }
}
