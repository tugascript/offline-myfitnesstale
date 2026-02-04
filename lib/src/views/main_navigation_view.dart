import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import 'create_profile_button_view.dart';
import 'home_view.dart';
import 'loading_view.dart';
import 'onboarding_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
import 'workout_plan_list_view.dart';

sealed class _PageBuilder {
  static const int pagesCount = 4;

  static final List<Widget Function()> _pages = [
    () => const HomeView(),
    () => const WorkoutPlanListView(),
    () => const ProgressView(),
    () => const ProfileView(),
  ];

  static final Map<int, Widget> _builtPages = {};

  static Widget getPage(int index) {
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

class MainNavigationView extends StatefulWidget {
  static const routeName = "/";
  static const name = "main_navigation";

  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
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
            return const LoadingView();
          }

          if (!state.isLoading && state.profile == null) {
            return CreateProfileButtonView();
          }

          return IndexedStack(
            index: _currentIndex,
            children: List.generate(_PageBuilder.pagesCount, (index) {
              if (_visitedIndices.contains(index)) {
                return _PageBuilder.getPage(index);
              }
              return const LoadingView();
            }),
          );
        },
        listener: (context, state) {
          if (!state.isLoading && state.profile == null) {
            context.go(OnboardingView.routeName);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Workout Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
