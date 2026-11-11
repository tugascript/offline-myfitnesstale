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

import './app_scaffold.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? showBackButton;
  final Widget? floatingActionButton;
  final bool isEntity;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton,
    this.floatingActionButton,
    this.isEntity = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showBackButton: showBackButton,
      isEntity: isEntity,
      body: SafeArea(child: SingleChildScrollView(child: body)),
      floatingActionButton: floatingActionButton,
    );
  }
}
