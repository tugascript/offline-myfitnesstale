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
import 'package:go_router/go_router.dart';

import '../../sizes/app_bar_sizes.dart';
import '../../sizes/screen_size.dart';
import './app_icon.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? showBackButton;
  final Widget? floatingActionButton;
  final bool isEntity;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton,
    this.floatingActionButton,
    this.isEntity = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final AppBarSizesList sizes = AppBarSizes.getAppBarSizes(
      breakPoint.screenSize,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: sizes.height,
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: (showBackButton ?? context.canPop())
            ? IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.arrow_back_ios, // iOS-style back button
                  size: sizes.backBtnSize,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            : null,
        title: Row(
          children: [
            AppIcon(size: sizes.icon),
            Flexible(
              child: Text(
                " ${isEntity ? title.toUpperCase() : title}",
                style: TextStyle(
                  fontSize: sizes.title,
                  fontWeight: isEntity ? FontWeight.w400 : FontWeight.w600,
                  fontFamily: isEntity
                      ? theme.textTheme.bodyLarge?.fontFamily
                      : theme.textTheme.titleLarge?.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
