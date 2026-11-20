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
import '../../themes/colors.dart';
import 'app_icon_button.dart';

class EditIconButton extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final void Function() onEdit;
  final bool small;

  const EditIconButton({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.onEdit,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppIconButton(
      icon: Icons.edit_outlined,
      sizes: sizes,
      small: small,
      isLoading: isLoading,
      color: ThemedColors.themedGrey.fromBrightness(theme.brightness),
      onPressed: onEdit,
      tooltip: 'Edit',
    );
  }
}
