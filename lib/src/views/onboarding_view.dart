import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../utilities/sizes/profile/onboarding_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/profile/onboarding_form.dart';
import '../widgets/profile/onboarding_intro.dart';

class OnboardingView extends StatelessWidget {
  static const routeName = "/onboarding";
  static const name = "onboarding";

  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = OnboardingSizes.getOnboardingSizes(
      breakPoint.screenSize,
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: sizes.breaks),
              OnboardingIntro(
                sizes: sizes,
                title: "Welcome",
                subtitle: "Set up your profile to start on your fitness tale",
              ),
              SizedBox(height: sizes.breaks * 4),
              BlocConsumer<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (!state.isLoading &&
                      state.profile != null &&
                      state.system != null) {
                    context.go('/');
                  }
                },
                builder: (context, state) {
                  return OnboardingForm(
                    sizes: sizes,
                    initialUnits: Units.metric,
                    initialThemeMode: ThemeType.system,
                    initialName: "",
                    initialHeight: 178,
                    initialGender: Gender.male,
                    submitButtonLabel: "Create & get started",
                    isLoading: state.isLoading,
                    onSubmit: context.read<ProfileCubit>().onboardProfile,
                    initialPreLoadWorkouts: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
