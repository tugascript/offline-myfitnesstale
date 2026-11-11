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

import '../../sizes/data_display_sizes.dart';
import '../layout/app_elevated_button.dart';
import '../mutation_button.dart';

class SaveButtons extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const SaveButtons({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MutationButton(
            onPressed: onCancel,
            theme: theme,
            isLoading: isLoading,
            sizes: sizes,
            label: 'CANCEL',
            icon: Icons.cancel,
            color: theme.colorScheme.error,
          ),
        ),
        SizedBox(width: sizes.spacing / 2),
        Expanded(
          child: AppElevatedButton(
            onPressed: onSave,
            theme: theme,
            isLoading: isLoading,
            sizes: sizes,
            label: 'SAVE',
            icon: Icons.save,
          ),
        ),
      ],
    );
  }
}
