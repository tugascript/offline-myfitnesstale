import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myfitnesstale/src/cubits/weight_record_cubit.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import 'home_view.dart';
import 'loading_view.dart';
import 'onboarding_view.dart';
import 'profile_view.dart';
import 'progress_view.dart';
import 'workouts_view.dart';

class MainNavigationView extends StatefulWidget {
  static const routeName = "/";
  static const name = "main_navigation";

  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const WorkoutsView(),
    const ProgressView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (!state.isInitiated) {
            context.read<ProfileCubit>().loadInitialData();
            context.read<WeightRecordCubit>().getLatestRecordedWeightRecord();
            return const LoadingView();
          }

          return IndexedStack(
            index: _currentIndex,
            children: _pages,
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
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
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
