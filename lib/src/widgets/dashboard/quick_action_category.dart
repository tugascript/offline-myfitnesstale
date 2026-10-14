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
