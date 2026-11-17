// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../view_models/profile_cubit.dart';
import '../../view_models/states/profile_state.dart';
import '../../widgets/profile/onboarding_form.dart';
import '../../widgets/profile/onboarding_intro.dart';

class OnboardingScreen extends StatelessWidget {
  static const name = "onboarding";

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: sizes.spacing),
              OnboardingIntro(
                sizes: sizes,
                title: "Welcome",
                subtitle: "Set up your profile to start on your fitness tale",
              ),
              SizedBox(height: sizes.spacing * 4),
              BlocListener<ProfileCubit, ProfileState>(
                listenWhen: (previous, current) {
                  final startedOnboarding =
                      !previous.isLoading &&
                      current.isLoading &&
                      current.profile == null;
                  final completedOnboarding =
                      previous.profile == null &&
                      current.profile != null &&
                      !current.isLoading;
                  return startedOnboarding || completedOnboarding;
                },
                listener: (context, state) {
                  final latest = context.read<ProfileCubit>().state;
                  if (latest.isLoading ||
                      (latest.profile != null &&
                          !latest.isLoading &&
                          latest.isInitiated)) {
                    GoRouter.maybeOf(context)?.go(Routes.home.name);
                  }
                },
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final draft = state.onboardingDraft;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.error != null) ...[
                          Card(
                            key: const ValueKey('onboarding-error'),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: Padding(
                              padding: EdgeInsets.all(sizes.padding),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  SizedBox(width: sizes.padding),
                                  Expanded(
                                    child: Text(
                                      state.error!.description,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: sizes.spacing),
                        ],
                        OnboardingForm(
                          sizes: sizes,
                          initialUnits: draft?.units ?? Units.metric,
                          initialThemeMode: draft?.theme ?? ThemeType.system,
                          initialName: draft?.name ?? "",
                          initialHeight: draft?.height ?? 176,
                          // average height for a male in cm
                          initialGender: draft?.gender ?? Gender.male,
                          initialBirthday:
                              draft?.birthday ??
                              DateTime.now().subtract(
                                Duration(days: (365.25 * 25).floor()),
                              ),
                          submitButtonLabel: "Create & get started",
                          isLoading: state.isLoading,
                          onSubmit:
                              ({
                                required Units units,
                                required ThemeType theme,
                                required String name,
                                required int height,
                                required Gender gender,
                                required DateTime birthday,
                                required bool preLoadWorkouts,
                                required bool notificationsOn,
                              }) {
                                context.read<ProfileCubit>().onboardProfile(
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
                          initialPreLoadWorkouts: draft?.createWorkouts ?? true,
                          initialNotificationsOn:
                              draft?.notificationsOn ?? false,
                        ),
                      ],
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
