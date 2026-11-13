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

import '../../../data/utils/enums.dart';

@immutable
final class ProgressStatusPresentation {
  final String label;
  final IconData icon;
  final Color color;

  const ProgressStatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  factory ProgressStatusPresentation.fromStatus(ProgressStatus status) {
    return switch (status) {
      ProgressStatus.inProgress => const ProgressStatusPresentation(
        label: 'In Progress',
        icon: Icons.play_circle_outline,
        color: Colors.blue,
      ),
      ProgressStatus.completed => const ProgressStatusPresentation(
        label: 'Completed',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      ProgressStatus.skipped => const ProgressStatusPresentation(
        label: 'Skipped',
        icon: Icons.skip_next_outlined,
        color: Colors.orange,
      ),
      ProgressStatus.abandoned => const ProgressStatusPresentation(
        label: 'Abandoned',
        icon: Icons.cancel_outlined,
        color: Colors.red,
      ),
    };
  }
}
