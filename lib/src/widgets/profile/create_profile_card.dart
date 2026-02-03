import 'package:flutter/material.dart';

import '../../utilities/sizes/home_sizes.dart';
import '../../utilities/sizes/screen_size.dart';

class CreateProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateProfileCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final HomeSizesList sizes = HomeSizes.getHomeSizes(breakPoint.screenSize);
    return Card(
      elevation: 1,
      margin: EdgeInsets.all(sizes.padding * 1.25),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding * 1.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your Fitness Tale starts here",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: sizes.titleFontSize,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.breaks * 0.5),
              Text(
                "Please create your profile",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: sizes.subtitleFontSize,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.breaks * 0.75),
              Icon(
                Icons.add,
                size: sizes.subtitleFontSize * 2.5,
                color: Theme.of(context).primaryColorLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
