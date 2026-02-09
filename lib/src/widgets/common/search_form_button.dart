import 'package:flutter/material.dart';

class SearchFormButton extends StatelessWidget {
  final ThemeData theme;
  final double loadingSize;
  final bool isLoading;
  final VoidCallback onPressed;

  const SearchFormButton({
    super.key,
    required this.theme,
    required this.loadingSize,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isLoading
          ? SizedBox(
              width: loadingSize,
              height: loadingSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
          : Icon(
              Icons.search,
              size: loadingSize,
              color: theme.primaryColor,
            ),
      onPressed: isLoading ? null : onPressed,
    );
  }
}
