import 'package:flutter/material.dart';

import '../widgets/layout/not_found.dart';
import '../widgets/layout/responsive_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      title: "Not Found",
      showBackButton: true,
      body: NotFound(),
    );
  }
}
