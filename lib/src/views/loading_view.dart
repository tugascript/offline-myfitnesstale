import 'package:flutter/material.dart';

import '../widgets/layout/app_scaffold.dart';

class LoadingView extends StatelessWidget {
  final String? title;
  final String? message;

  static const name = "loading";

  const LoadingView({
    super.key,
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title ?? "My Fitness Tale",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(message ?? "Continuing your fitness tale..."),
          ],
        ),
      ),
    );
  }
}
