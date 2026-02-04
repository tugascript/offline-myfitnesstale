import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profile_cubit.dart';
import '../../cubits/states/profile_state.dart';
import '../../utilities/sizes/home_sizes.dart';

class WelcomeSection extends StatelessWidget {
  final HomeSizesList sizes;

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
        color: isDarkTheme ? theme.primaryColorDark : theme.primaryColorLight,
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
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              SizedBox(height: sizes.breaks / 3),
              Text(
                "Let's continue your fitness tale!",
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
