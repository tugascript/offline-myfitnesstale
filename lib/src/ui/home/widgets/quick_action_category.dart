// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';

@immutable
class QuickActionDestination {
  final String id;
  final String label;
  final IconData icon;
  final String route;

  const QuickActionDestination(this.id, this.label, this.icon, this.route);
}

@immutable
class QuickActionCategory {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<QuickActionDestination> destinations;

  const QuickActionCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.destinations,
  });
}
