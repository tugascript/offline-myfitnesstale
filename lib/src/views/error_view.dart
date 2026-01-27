import 'package:flutter/material.dart';

import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/layout/service_error_description.dart';

class ErrorView extends StatelessWidget {
  final String type;
  final String description;

  const ErrorView({
    super.key,
    required this.type,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: _formatType(type),
      body: ServiceErrorDescription(
        description: description,
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'notFound':
        return 'Not Found';
      case 'invalidInput':
        return 'Invalid Input';
      case 'operationFailure':
        return 'Something Went Wrong';
      default:
        return type;
    }
  }
}
