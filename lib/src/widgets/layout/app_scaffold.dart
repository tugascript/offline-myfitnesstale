import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/app_bar_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import 'app_icon.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? showBackButton;
  final Widget? floatingActionButton;
  final bool isEntity;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton,
    this.floatingActionButton,
    this.isEntity = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final AppBarSizesList sizes =
        AppBarSizes.getAppBarSizes(breakPoint.screenSize);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: sizes.height,
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: (showBackButton ?? context.canPop())
            ? IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.arrow_back_ios, // iOS-style back button
                  size: sizes.backBtnSize,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            : null,
        title: Row(
          children: [
            AppIcon(size: sizes.icon),
            Flexible(
              child: Text(
                " ${isEntity ? title.toUpperCase() : title}",
                style: TextStyle(
                  fontSize: sizes.title,
                  fontWeight: isEntity ? FontWeight.w400 : FontWeight.w600,
                  fontFamily: isEntity
                      ? theme.textTheme.bodyLarge?.fontFamily
                      : theme.textTheme.titleLarge?.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
