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

import '../sizes/data_display_sizes.dart';
import '../widgets/layout/app_scaffold.dart';

class EntityErrorScreen extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String entityName;
  final String? errorDescription;

  const EntityErrorScreen({
    super.key,
    required this.sizes,
    required this.entityName,
    this.errorDescription,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Unknown $entityName",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: sizes.subtitleFontSize * 2,
              color: Colors.grey,
            ),
            SizedBox(height: sizes.spacing),
            Text(
              errorDescription ?? '$entityName not found',
              style: TextStyle(fontSize: sizes.subtitleFontSize),
            ),
            SizedBox(height: sizes.spacing),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(
                'Go Back',
                style: TextStyle(fontSize: sizes.subtitleFontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
