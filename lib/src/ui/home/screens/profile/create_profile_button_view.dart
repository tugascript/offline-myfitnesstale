import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routing.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../widgets/profile/create_profile_card.dart';

class CreateProfileButtonView extends StatelessWidget {
  const CreateProfileButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Start your Fitness Tale",
      body: Center(
        child: CreateProfileCard(
          onTap: () => context.go(Routes.onboarding.name),
        ),
      ),
    );
  }
}
