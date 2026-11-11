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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/screens/loading_screen.dart';
import '../../macros/screens/macro_tracker_screen.dart';
import '../../workout_plans/screens/current_workout_plan_screen.dart';
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

  static Widget getPage(int index, {required bool isVisible}) {
    // Rebuild this configuration so its cached State sees tab activation.
    if (index == 1) {
      return CurrentWorkoutPlanScreen(isVisible: isVisible);
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
  int _currentIndex = 0;
  final Set<int> _visitedIndices = {0};

  @override
  void dispose() {
    _PageBuilder.clearBuiltPages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (!state.isInitiated) {
            return const LoadingScreen();
          }

          if (!state.isLoading && state.profile == null) {
            return CreateProfileButtonScreen();
          }

          return IndexedStack(
            index: _currentIndex,
            children: List.generate(_PageBuilder.pagesCount, (index) {
              if (_visitedIndices.contains(index)) {
                return _PageBuilder.getPage(
                  index,
                  isVisible: _currentIndex == index,
                );
              }
              return const LoadingScreen();
            }),
          );
        },
        listener: (context, state) {
          if (!state.isLoading && state.profile == null) {
            context.go(Routes.onboarding.name);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: const ValueKey('main-bottom-navigation'),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _visitedIndices.add(index);
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 20)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text('🏋️', style: TextStyle(fontSize: 20)),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Text('🍎', style: TextStyle(fontSize: 20)),
            label: 'Macros',
          ),
          BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 20)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
