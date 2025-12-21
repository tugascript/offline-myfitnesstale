import 'package:flutter/material.dart';

import '../widgets/layout/responsive_scaffold.dart';

class LoadingView extends StatelessWidget {
  static const name = "loading";

  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      title: "My Fitness Tale",
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Continuing your fitness tale..."),
          ],
        ),
      ),
    );
  }
}
