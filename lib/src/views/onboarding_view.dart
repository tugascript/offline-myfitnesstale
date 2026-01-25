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
import 'home_view.dart';

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
              BlocListener<ProfileCubit, ProfileState>(
                listenWhen: (previous, current) {
                  // Only listen when transitioning from no profile to having profile
                  return previous.profile == null &&
                      previous.system == null &&
                      current.profile != null &&
                      current.system != null &&
                      !current.isLoading;
                },
                listener: (context, state) {
                  if (state.profile != null) {
                    context.go(HomeView.routeName);
                  }
                },
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return OnboardingForm(
                      sizes: sizes,
                      initialUnits: Units.metric,
                      initialThemeMode: ThemeType.system,
                      initialName: "",
                      initialHeight: 176, // average height for a male in oz
                      initialGender: Gender.male,
                      submitButtonLabel: "Create & get started",
                      isLoading: state.isLoading,
                      onSubmit: ({
                        required Units units,
                        required ThemeType theme,
                        required String name,
                        required int height,
                        required Gender gender,
                        required bool preLoadWorkouts,
                      }) async {
                        // Use a default birthday (25 years ago) if not provided
                        final defaultBirthday = DateTime.now().subtract(const Duration(days: 365 * 25));
                        await context.read<ProfileCubit>().onboardProfile(
                          units: units,
                          theme: theme,
                          name: name,
                          height: height,
                          gender: gender,
                          birthday: defaultBirthday,
                        );
                      },
                      initialPreLoadWorkouts: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
