import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class WelcomeSection extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const WelcomeSection({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: sizes.elevation,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return Text(
                    "Welcome back ${state.profile?.name ?? "to My Fitness Tale"}!",
                    style: TextStyle(
                      fontSize: sizes.titleFontSize * 1.15,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "Let's continue your fitness tale!",
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize * 1.15,
                  color:
                      isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
