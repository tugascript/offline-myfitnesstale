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
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/weight/dtos/weight_goal_dto.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/weight/screens/weight_goals_screen.dart';
import 'package:myfitnesstale/src/ui/weight/view_models/weight_record_cubit.dart';
import 'package:myfitnesstale/src/ui/weight/widgets/goal/active/current_weight_goal.dart';
import 'package:myfitnesstale/src/ui/weight/widgets/goal/active/empty_weight_goal.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit() : super(profileRepository: ProfileRepository.create()) {
    emit(
      ProfileState(
        profile: ProfileDto(
          id: 1,
          name: 'Tester',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ),
        system: const SystemDto(
          id: 1,
          units: Units.metric,
          theme: ThemeType.system,
          initialSetup: SetUpStatus.completed,
          notificationsOn: false,
        ),
        isLoading: false,
        isInitiated: true,
      ),
    );
  }
}

class _FakeWeightRecordCubit extends WeightRecordCubit {
  int activeGoalLoadCalls = 0;

  _FakeWeightRecordCubit({
    bool initialLoading = false,
    bool initialHistoryLoading = false,
  }) : super(weightRecordRepository: WeightRecordRepository.create()) {
    if (initialLoading || initialHistoryLoading) {
      emit(
        state.copyWith(
          isLoadingActiveGoal: initialLoading,
          isLoadingGoals: initialHistoryLoading,
        ),
      );
    }
  }

  @override
  Future<void> getActiveWeightGoal() async {
    activeGoalLoadCalls++;
  }

  @override
  Future<void> getWeightGoals({
    bool skipInProgress = false,
    int limit = 20,
    int offset = 0,
  }) async {}

  void setHistoryLoading(bool isLoadingGoals) {
    emit(state.copyWith(isLoadingGoals: isLoadingGoals));
  }

  void setActiveGoal(WeightGoalDto? goal) {
    emit(
      state.copyWith(
        activeWeightGoal: Nullable(goal),
        hasLoadedActiveGoal: true,
        isLoadingActiveGoal: false,
        activeGoalError: const Nullable(null),
      ),
    );
  }

  void emitActiveGoalError(String description) {
    final errorState = ErrorState(
      type: 'operationFailure',
      description: description,
    );
    emit(
      state.copyWith(
        activeWeightGoal: const Nullable(null),
        hasLoadedActiveGoal: false,
        isLoadingActiveGoal: false,
        activeGoalError: Nullable(errorState),
        error: Nullable(errorState),
      ),
    );
  }
}

void main() {
  final testDatabase = TestDatabase();

  setUpAll(() => testDatabase.initialize());

  tearDownAll(() => testDatabase.destroy());

  Widget buildScreen(WeightRecordCubit cubit) {
    final profileCubit = _ProfileCubit();
    final router = GoRouter(
      initialLocation: Routes.weightGoal.name,
      routes: [
        GoRoute(
          path: Routes.weightGoal.name,
          builder: (context, state) => const WeightGoalScreen(),
        ),
      ],
    );
    addTearDown(() async {
      await profileCubit.close();
      router.dispose();
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<WeightRecordCubit>.value(value: cubit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets(
    'WeightGoalScreen keeps skeleton when history finishes first, shows active/empty goal when loaded, and shows retry card + SnackBar on error',
    (tester) async {
      final cubit = _FakeWeightRecordCubit(
        initialLoading: true,
        initialHistoryLoading: true,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildScreen(cubit));
      await tester.pump();

      // History completes while active goal is still loading: must NOT flash EmptyWeightGoal.
      cubit.setHistoryLoading(false);
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmptyWeightGoal), findsNothing);
      expect(find.text('No weight goals'), findsNothing);
      expect(find.byType(CurrentWeightGoal), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CurrentWeightGoal),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );

      cubit.setActiveGoal(
        WeightGoalDto(
          id: 1,
          targetWeight: 72500,
          startDate: DateTime.utc(2026, 1, 1),
          status: ProgressStatus.inProgress,
          phase: WeightGoalPhase.maintain,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmptyWeightGoal), findsNothing);
      expect(find.byType(CurrentWeightGoal), findsOneWidget);
      expect(find.text('72.50 KG'), findsOneWidget);

      cubit.setActiveGoal(null);
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmptyWeightGoal), findsOneWidget);
      expect(find.text('No weight goals'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      cubit.emitActiveGoalError('Failed to get active weight goal');
      await tester.pumpAndSettle();

      expect(find.byType(EmptyWeightGoal), findsNothing);
      expect(find.text('Could not load active weight goal'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('active-weight-goal-retry')),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to get active weight goal'), findsOneWidget);

      final callsBeforeRetry = cubit.activeGoalLoadCalls;
      await tester.tap(find.byKey(const ValueKey('active-weight-goal-retry')));
      await tester.pump();
      expect(cubit.activeGoalLoadCalls, callsBeforeRetry + 1);
    },
  );

  testWidgets(
    'WeightGoalScreen shows EmptyWeightGoal without SnackBar when no active goal exists in DB',
    (tester) async {
      final cubit = WeightRecordCubit(
        weightRecordRepository: WeightRecordRepository.create(),
      );
      addTearDown(cubit.close);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildScreen(cubit));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(cubit.state.activeWeightGoal, isNull);
      expect(cubit.state.hasLoadedActiveGoal, isTrue);
      expect(cubit.state.activeGoalError, isNull);
      expect(cubit.state.error, isNull);
      expect(find.byType(EmptyWeightGoal), findsOneWidget);
      expect(find.text('No weight goals'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}
