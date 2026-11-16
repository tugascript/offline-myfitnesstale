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
import 'package:myfitnesstale/src/data/models/sqlite/profile_model.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/home/screens/profile/profile_screen.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/widgets/profile/profile_edit_form.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  late ProfileCubit cubit;

  setUp(() async {
    await testDatabase.initialize();
    cubit = ProfileCubit(profileRepository: ProfileRepository.create());
    await cubit.onboardProfile(
      units: Units.metric,
      theme: ThemeType.system,
      name: 'Original Name',
      height: 175,
      gender: Gender.other,
      birthday: DateTime(1990),
      createWorkouts: false,
      notificationsOn: false,
    );
    final db = await testDatabase.db;
    await db.execute(
      "CREATE TRIGGER reject_profile_update "
      "BEFORE UPDATE ON ${Profile.table} "
      "BEGIN SELECT RAISE(ABORT, 'Forced save failure'); END",
    );
  });

  tearDown(() async {
    await cubit.close();
    await testDatabase.destroy();
  });

  testWidgets(
    'preserves profile edits after a failed save and supports retry',
    (tester) async {
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const ProfileScreen())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('profile-edit')));
      await tester.pump();
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'Edited Name');

      final save = find.text('SAVE');
      await tester.ensureVisible(save);
      await tester.runAsync(() async {
        final completed = cubit.stream.firstWhere((state) => !state.isLoading);
        await tester.tap(save);
        await completed;
      });
      await tester.pumpAndSettle();

      expect(find.text('Failed to update profile'), findsOneWidget);
      expect(find.byType(ProfileEditForm), findsOneWidget);
      expect(find.text('Edited Name'), findsOneWidget);
      expect(cubit.state.profile?.name, 'Original Name');

      await tester.runAsync(() async {
        final db = await testDatabase.db;
        await db.execute('DROP TRIGGER reject_profile_update');
        final completed = cubit.stream.firstWhere((state) => !state.isLoading);
        await tester.tap(save);
        await completed;
      });
      await tester.pumpAndSettle();

      expect(find.byType(ProfileEditForm), findsNothing);
      expect(cubit.state.profile?.name, 'Edited Name');
    },
  );
}
