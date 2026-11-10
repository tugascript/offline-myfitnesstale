import 'package:flutter/material.dart';

import '../widgets/layout/not_found.dart';
import '../widgets/layout/responsive_scaffold.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      title: "Not Found",
      showBackButton: true,
      body: NotFound(),
    );
  }
}
