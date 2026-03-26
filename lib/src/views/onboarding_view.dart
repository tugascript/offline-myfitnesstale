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
import 'home/home_view.dart';

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
                      current.profile != null &&
                      !current.isLoading;
                },
                listener: (context, state) {
                  if (state.profile != null &&
                      !state.isLoading &&
                      state.isInitiated) {
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
                      initialBirthday: DateTime.now().subtract(
                        Duration(days: (365.25 * 25).floor()),
                      ),
                      submitButtonLabel: "Create & get started",
                      isLoading: state.isLoading,
                      onSubmit: ({
                        required Units units,
                        required ThemeType theme,
                        required String name,
                        required int height,
                        required Gender gender,
                        required DateTime birthday,
                        required bool preLoadWorkouts,
                        required bool notificationsOn,
                      }) async {
                        await context.read<ProfileCubit>().onboardProfile(
                              units: units,
                              theme: theme,
                              name: name,
                              height: height,
                              gender: gender,
                              birthday: birthday,
                              createWorkouts: preLoadWorkouts,
                              notificationsOn: notificationsOn,
                            );
                      },
                      initialPreLoadWorkouts: true,
                      initialNotificationsOn: false,
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
