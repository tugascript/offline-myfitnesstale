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

class DataExport extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;

  const DataExport({super.key, required this.sizes, required this.isLoading});

  void _showPlaceholderExportMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label coming soon!')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('profile-data-export'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.file_download_outlined,
              size: sizes.iconSubtitleFontSize,
            ),
            Text(
              " Data Export",
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.halfSpacing),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('data-export-json'),
                onPressed: isLoading
                    ? null
                    : () => _showPlaceholderExportMessage(
                        context,
                        'Export Data Copy',
                      ),
                icon: Icon(
                  Icons.description_outlined,
                  size: sizes.compactIconSize,
                ),
                label: Text(
                  "Export data",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ),
            ),
            SizedBox(width: sizes.halfSpacing),
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('data-export-snapshot'),
                onPressed: isLoading
                    ? null
                    : () => _showPlaceholderExportMessage(
                        context,
                        'Save Full Backup',
                      ),
                icon: Icon(Icons.archive_outlined, size: sizes.compactIconSize),
                label: Text(
                  "Database snapshot",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
