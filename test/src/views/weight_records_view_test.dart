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
import 'package:myfitnesstale/src/data/repositories/weight/dtos/weight_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/ui/core/widgets/icons_switch.dart';
import 'package:myfitnesstale/src/ui/core/widgets/not_found_list.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/weight/screens/weight_records_screen.dart';
import 'package:myfitnesstale/src/ui/weight/view_models/weight_record_cubit.dart';
import 'package:myfitnesstale/src/ui/weight/widgets/records/empty_weight_record.dart';
import 'package:myfitnesstale/src/ui/weight/widgets/records/latest_weight_record_card.dart';
import 'package:myfitnesstale/src/ui/weight/widgets/records/weight_records_list.dart';
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
  _FakeWeightRecordCubit()
    : super(weightRecordRepository: WeightRecordRepository.create());

  @override
  Future<void> getLatestRecordedWeightRecord() async {}

  @override
  Future<void> getWeightRecords({
    (DateTime start, DateTime end)? dateRange,
    int limit = 20,
    int offset = 0,
  }) async {}

  void setLoadingFlags({
    bool? isLoading,
    bool? isLoadingLatest,
    bool? isLoadingRecords,
    bool? isLoadingActiveGoal,
    bool? isLoadingGoals,
  }) {
    emit(
      state.copyWith(
        isLoading: isLoading,
        isLoadingLatest: isLoadingLatest,
        isLoadingRecords: isLoadingRecords,
        isLoadingActiveGoal: isLoadingActiveGoal,
        isLoadingGoals: isLoadingGoals,
      ),
    );
  }

  void setLatestRecord(WeightRecordDto? record) {
    emit(
      state.copyWith(
        latestWeightRecord: Nullable(record),
        isLoadingLatest: false,
      ),
    );
  }

  void setRecords(List<WeightRecordDto> records) {
    emit(state.copyWith(weightRecords: records, isLoadingRecords: false));
  }
}

void main() {
  final testDatabase = TestDatabase();

  setUpAll(() => testDatabase.initialize());

  tearDownAll(() => testDatabase.destroy());

  Widget buildScreen(WeightRecordCubit cubit) {
    final profileCubit = _ProfileCubit();
    final router = GoRouter(
      initialLocation: Routes.weightRecords.name,
      routes: [
        GoRoute(
          path: Routes.weightRecords.name,
          builder: (context, state) => const WeightRecordsScreen(),
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
    'LatestWeightRecord and WeightRecordsHistory ignore unrelated goal/mutation loaders and only gate on their own loading flags',
    (tester) async {
      final cubit = _FakeWeightRecordCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildScreen(cubit));
      await tester.pump();

      // Empty latest and empty history remain visible even when goal loaders and mutations are active.
      cubit.setLoadingFlags(
        isLoading: true,
        isLoadingActiveGoal: true,
        isLoadingGoals: true,
        isLoadingLatest: false,
        isLoadingRecords: false,
      );
      await tester.pump();
      await tester.pump();

      expect(cubit.state.isLoading, isTrue);
      expect(find.byType(EmptyWeightRecord), findsOneWidget);
      expect(find.byType(NotFoundList), findsOneWidget);
      expect(find.text('Empty history'), findsOneWidget);

      // Cached latest weight record is NOT skeletonized while goal/history loaders run.
      final record = WeightRecordDto(
        id: 1,
        weight: 74500,
        recordDate: DateTime(2026, 3, 1),
      );
      cubit.setLatestRecord(record);
      cubit.setLoadingFlags(
        isLoading: true,
        isLoadingActiveGoal: true,
        isLoadingGoals: true,
        isLoadingRecords: true,
        isLoadingLatest: false,
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmptyWeightRecord), findsNothing);
      expect(find.byType(LatestWeightRecordCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LatestWeightRecordCard),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && !w.enabled,
          ),
        ),
        findsOneWidget,
      );

      // While isLoadingRecords is true and records are empty, Empty history is hidden and list view skeletonizes.
      expect(find.byType(NotFoundList), findsNothing);
      await tester.tap(find.byType(IconsSwitch));
      await tester.pump();
      expect(find.byType(WeightRecordsList), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WeightRecordsList),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );

      // Once isLoadingRecords finishes empty, Empty history appears even while goal loaders remain active.
      cubit.setRecords(const []);
      await tester.pump();
      await tester.pump();

      expect(cubit.state.isLoadingActiveGoal, isTrue);
      expect(cubit.state.isLoadingGoals, isTrue);
      expect(find.byType(NotFoundList), findsOneWidget);
      expect(find.text('Empty history'), findsOneWidget);

      // When isLoadingLatest is true, LatestWeightRecordCard skeletonizes and EmptyWeightRecord is hidden.
      cubit.setLatestRecord(null);
      cubit.setLoadingFlags(
        isLoading: false,
        isLoadingActiveGoal: false,
        isLoadingGoals: false,
        isLoadingRecords: false,
        isLoadingLatest: true,
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmptyWeightRecord), findsNothing);
      expect(find.byType(LatestWeightRecordCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LatestWeightRecordCard),
          matching: find.byWidgetPredicate(
            (w) => w is Skeletonizer && w.enabled,
          ),
        ),
        findsOneWidget,
      );
    },
  );
}
