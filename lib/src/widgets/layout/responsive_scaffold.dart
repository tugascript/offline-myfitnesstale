import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/app_bar_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import 'app_icon.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? showBackButton;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final AppBarSizesList sizes =
        AppBarSizes.getAppBarSizes(breakPoint.screenSize);

    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[100]
        : Colors.grey[900];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: sizes.height,
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: (showBackButton ?? context.canPop())
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios, // iOS-style back button
                  size: 24,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // Fallback to home if no previous route
                    context.go('/');
                  }
                },
              )
            : null,
        title: Row(
          children: [
            AppIcon(size: sizes.icon),
            SizedBox(width: sizes.title),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: sizes.title,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
