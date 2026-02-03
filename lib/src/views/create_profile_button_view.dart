import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/layout/app_scaffold.dart';
import '../widgets/profile/create_profile_card.dart';
import 'onboarding_view.dart';

class CreateProfileButtonView extends StatelessWidget {
  const CreateProfileButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Start your Fitness Tale",
      body: Center(
        child: CreateProfileCard(
          onTap: () => context.go(OnboardingView.routeName),
        ),
      ),
    );
  }
}
