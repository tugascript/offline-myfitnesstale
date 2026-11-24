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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../macros/screens/macro_tracker_screen.dart';
import '../../macros/view_models/macro_tracking_cubit.dart';
import '../../workout_plans/screens/current_workout_plan_screen.dart';
import '../../workout_plans/view_models/workout_plan_record_cubit.dart';
import '../view_models/profile_cubit.dart';
import '../view_models/states/profile_state.dart';
import './home_screen.dart';
import './profile/create_profile_button_screen.dart';
import './profile/profile_screen.dart';

sealed class _PageBuilder {
  static int get pagesCount => _pages.length;

  static final List<Widget Function()> _pages = [
    () => const HomeScreen(),
    () => const CurrentWorkoutPlanScreen(),
    () => const MacroTrackerScreen(),
    () => const ProfileScreen(),
  ];

  static final Map<int, Widget> _builtPages = {};

  static Widget getPage(
    int index, {
    required bool isVisible,
    int macroGoalPromptTrigger = 0,
  }) {
    // Rebuild visibility-aware tabs so their cached State sees tab activation.
    if (index == 1) {
      return CurrentWorkoutPlanScreen(isVisible: isVisible);
    }
    if (index == 2) {
      return MacroTrackerScreen(
        isVisible: isVisible,
        goalPromptTrigger: macroGoalPromptTrigger,
      );
    }
    if (_builtPages.containsKey(index)) {
      return _builtPages[index]!;
    }

    _builtPages[index] = _pages[index]();
    return _builtPages[index]!;
  }

  static void clearBuiltPages() {
    _builtPages.clear();
  }
}

class MainNavigationScreen extends StatefulWidget {
  static const name = "main_navigation";

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const Duration _initialWarmUpDelay = Duration(milliseconds: 250);
  static const Duration _warmUpStepDelay = Duration(milliseconds: 150);

  int _currentIndex = 0;
  int _macroTabTapCount = 0;
  final Set<int> _visitedIndices = {0};
  Timer? _warmUpTimer;
  bool _warmUpStarted = false;

  bool _shouldRedirectToOnboarding(ProfileState state) =>
      !state.isLoading &&
      state.profile == null &&
      ((state.isInitiated && state.error == null) ||
          state.onboardingDraft != null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<ProfileCubit>().state;
      if (_shouldRedirectToOnboarding(state)) {
        GoRouter.maybeOf(context)?.go(Routes.onboarding.name);
      }
    });
  }

  @override
  void dispose() {
    _warmUpTimer?.cancel();
    _PageBuilder.clearBuiltPages();
    super.dispose();
  }

  int? _nextUnvisitedIndex() {
    for (var i = 0; i < _PageBuilder.pagesCount; i++) {
      if (!_visitedIndices.contains(i)) {
        return i;
      }
    }
    return null;
  }

  bool _isHomeActiveDataLoading() {
    final workoutState = context.read<WorkoutPlanRecordCubit>().state;
    final macroState = context.read<MacroTrackingCubit>().state;
    return workoutState.isLoading || macroState.isLoading;
  }

  void _startWarmUpIfNeeded() {
    if (_warmUpStarted || _nextUnvisitedIndex() == null) return;
    _warmUpStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleNextWarmUp(_initialWarmUpDelay);
    });
  }

  void _scheduleNextWarmUp(Duration delay) {
    if (!mounted || _nextUnvisitedIndex() == null) return;
    _warmUpTimer?.cancel();
    _warmUpTimer = Timer(delay, () {
      if (!mounted) return;
      final profileState = context.read<ProfileCubit>().state;
      if (profileState.profile == null || profileState.isLoading) {
        _warmUpStarted = false;
        return;
      }
      if (_isHomeActiveDataLoading()) {
        _scheduleNextWarmUp(_warmUpStepDelay);
        return;
      }
      final nextIndex = _nextUnvisitedIndex();
      if (nextIndex == null) return;
      setState(() {
        _visitedIndices.add(nextIndex);
      });
      _scheduleNextWarmUp(_warmUpStepDelay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (_shouldRedirectToOnboarding(state)) {
          GoRouter.maybeOf(context)?.go(Routes.onboarding.name);
        }
      },
      builder: (context, state) {
        final hasStartupError =
            state.profile == null &&
            state.error != null &&
            state.onboardingDraft == null;
        final isHomeLoading =
            !hasStartupError &&
            (!state.isInitiated || (state.isLoading && state.profile == null));

        if (!hasStartupError &&
            !isHomeLoading &&
            !state.isLoading &&
            state.profile == null) {
          return Scaffold(body: CreateProfileButtonScreen());
        }

        if (!hasStartupError &&
            !isHomeLoading &&
            !state.isLoading &&
            state.profile != null) {
          _startWarmUpIfNeeded();
        }

        final activeIndex = isHomeLoading ? 0 : _currentIndex;

        return Scaffold(
          body: IndexedStack(
            index: activeIndex,
            children: List.generate(_PageBuilder.pagesCount, (index) {
              if (_visitedIndices.contains(index)) {
                return TickerMode(
                  enabled: activeIndex == index,
                  child: _PageBuilder.getPage(
                    index,
                    isVisible: activeIndex == index,
                    macroGoalPromptTrigger: _macroTabTapCount,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
          bottomNavigationBar: BottomNavigationBar(
            key: const ValueKey('main-bottom-navigation'),
            type: BottomNavigationBarType.fixed,
            currentIndex: activeIndex,
            onTap: (index) {
              if (isHomeLoading) return;
              setState(() {
                _visitedIndices.add(index);
                _currentIndex = index;
                if (index == 2) {
                  _macroTabTapCount++;
                }
              });
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            selectedFontSize: sizes.fontSize,
            unselectedFontSize: sizes.fontSize,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: sizes.mediumIconSize),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center, size: sizes.mediumIconSize),
                label: 'Plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu, size: sizes.mediumIconSize),
                label: 'Macros',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: sizes.mediumIconSize),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
