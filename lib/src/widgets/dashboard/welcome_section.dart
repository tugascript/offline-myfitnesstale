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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.2),
            Theme.of(context).primaryColor.withValues(alpha: 0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
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
            "Ready to continue the fitness tale?",
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
