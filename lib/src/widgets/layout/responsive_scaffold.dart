import 'package:flutter/material.dart';

import 'app_scaffold.dart';

// TODO: allow to pass custom back action
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
