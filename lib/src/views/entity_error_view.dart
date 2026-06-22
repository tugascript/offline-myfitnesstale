import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utilities/sizes/data_display_sizes.dart';
import '../widgets/layout/app_scaffold.dart';

class EntityErrorView extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String entityName;
  final String? errorDescription;

  const EntityErrorView({
    super.key,
    required this.sizes,
    required this.entityName,
    this.errorDescription,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Unknown $entityName",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: sizes.subtitleFontSize * 2,
              color: Colors.grey,
            ),
            SizedBox(height: sizes.spacing),
            Text(
              errorDescription ?? '$entityName not found',
              style: TextStyle(fontSize: sizes.subtitleFontSize),
            ),
            SizedBox(height: sizes.spacing),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(
                'Go Back',
                style: TextStyle(fontSize: sizes.subtitleFontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
