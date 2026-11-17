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
import 'package:myfitnesstale/src/data/repositories/core/dtos/picture_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/equipment_details_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/equipments_list_screen.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/states/exercise_state.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/create_equipment_modal.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/edit_equipment_modal.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

class _FakeExerciseCubit extends ExerciseCubit {
  final bool shouldFail;
  final List<EquipmentInput> createdInputs = [];
  final List<(int, EquipmentInput)> updatedCalls = [];

  _FakeExerciseCubit({this.shouldFail = false, EquipmentDto? initialEquipment})
    : super(exerciseRepository: ExerciseRepository.create()) {
    if (initialEquipment != null) {
      emit(
        state.copyWith(
          equipments: [initialEquipment],
          equipmentPagination: state.equipmentPagination.copyWith(total: 1),
          selectedEquipment: Nullable(
            SelectedEquipment(
              equipment: initialEquipment,
              relatedExercises: const [],
            ),
          ),
        ),
      );
    }
  }

  @override
  Future<void> getEquipments({
    String? name,
    required int limit,
    required int offset,
  }) async {}

  @override
  Future<void> getEquipment(int id) async {}

  @override
  Future<void> createEquipment(
    EquipmentInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    createdInputs.add(input);
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to create equipment',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final created = EquipmentDto(
      id: 99,
      name: input.name,
      isFavorite: input.isFavorite,
      createdBy: createdBy,
    );
    emit(
      state.copyWith(
        equipments: [...state.equipments, created],
        equipmentPagination: state.equipmentPagination.copyWith(
          total: state.equipments.length + 1,
        ),
        selectedEquipment: Nullable(
          SelectedEquipment(equipment: created, relatedExercises: const []),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  @override
  Future<void> updateEquipment(int id, EquipmentInput input) async {
    updatedCalls.add((id, input));
    if (shouldFail) {
      emit(
        state.copyWith(
          error: const Nullable(
            ErrorState(
              type: 'operationFailure',
              description: 'Failed to update equipment',
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final updated = EquipmentDto(
      id: id,
      name: input.name,
      picture: input.picture.value != null
          ? PictureDto(
              storage: input.picture.value!.storage,
              uri: input.picture.value!.uri,
            )
          : null,
      isFavorite: input.isFavorite,
      createdBy: CreatedBy.user,
    );
    emit(
      state.copyWith(
        equipments: state.equipments
            .map((e) => e.id == id ? updated : e)
            .toList(),
        selectedEquipment: Nullable(
          SelectedEquipment(equipment: updated, relatedExercises: const []),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}

void main() {
  testWidgets(
    'EquipmentsListScreen FAB opens CreateEquipmentModal, creates equipment, and closes modal',
    (tester) async {
      final cubit = _FakeExerciseCubit(
        initialEquipment: const EquipmentDto(
          id: 1,
          name: 'Barbell',
          createdBy: CreatedBy.system,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: const MaterialApp(home: EquipmentsListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('equipment-add')));
      await tester.pumpAndSettle();

      expect(find.byType(CreateEquipmentModal), findsOneWidget);
      expect(find.text('CREATE EQUIPMENT'), findsOneWidget);

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Trap Bar',
      );
      await tester.tap(find.text('CREATE EQUIPMENT'));
      await tester.pumpAndSettle();

      expect(cubit.createdInputs, hasLength(1));
      expect(cubit.createdInputs.first.name, 'Trap Bar');
      expect(find.byType(CreateEquipmentModal), findsNothing);
      expect(find.text('Trap Bar'), findsOneWidget);
    },
  );

  testWidgets(
    'Failed equipment creation keeps CreateEquipmentModal open and displays error',
    (tester) async {
      final cubit = _FakeExerciseCubit(
        shouldFail: true,
        initialEquipment: const EquipmentDto(
          id: 1,
          name: 'Barbell',
          createdBy: CreatedBy.system,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: const MaterialApp(home: EquipmentsListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('equipment-add')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Trap Bar',
      );
      await tester.tap(find.text('CREATE EQUIPMENT'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateEquipmentModal), findsOneWidget);
      expect(find.text('Failed to create equipment'), findsOneWidget);
    },
  );

  testWidgets(
    'EquipmentDetailsScreen edit button opens EditEquipmentModal, updates equipment preserving metadata, and closes modal',
    (tester) async {
      const existing = EquipmentDto(
        id: 12,
        name: 'Safety Squat Bar',
        picture: PictureDto(storage: PictureStorage.files, uri: 'ssb.png'),
        isFavorite: true,
        createdBy: CreatedBy.user,
      );
      final cubit = _FakeExerciseCubit(initialEquipment: existing);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/equipments/12',
        routes: [
          GoRoute(
            path: '/equipments/:id',
            builder: (_, _) => const EquipmentDetailsScreen(equipmentId: 12),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('EDIT'));
      await tester.pumpAndSettle();

      expect(find.byType(EditEquipmentModal), findsOneWidget);
      expect(find.text('UPDATE EQUIPMENT'), findsOneWidget);
      expect(find.text('Safety Squat Bar'), findsOneWidget);

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Cambered Bar',
      );
      await tester.tap(find.text('UPDATE EQUIPMENT'));
      await tester.pumpAndSettle();

      expect(cubit.updatedCalls, hasLength(1));
      final (updatedId, updatedInput) = cubit.updatedCalls.first;
      expect(updatedId, 12);
      expect(updatedInput.name, 'Cambered Bar');
      expect(updatedInput.isFavorite, isTrue);
      expect(updatedInput.picture.value?.uri, 'ssb.png');
      expect(updatedInput.picture.value?.storage, PictureStorage.files);
      expect(find.byType(EditEquipmentModal), findsNothing);
      expect(find.textContaining('CAMBERED BAR'), findsOneWidget);
    },
  );

  testWidgets(
    'Failed equipment update keeps EditEquipmentModal open and displays error',
    (tester) async {
      const existing = EquipmentDto(
        id: 12,
        name: 'Safety Squat Bar',
        createdBy: CreatedBy.user,
      );
      final cubit = _FakeExerciseCubit(
        shouldFail: true,
        initialEquipment: existing,
      );
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/equipments/12',
        routes: [
          GoRoute(
            path: '/equipments/:id',
            builder: (_, _) => const EquipmentDetailsScreen(equipmentId: 12),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<ExerciseCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('EDIT'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Name',
        ),
        'Cambered Bar',
      );
      await tester.tap(find.text('UPDATE EQUIPMENT'));
      await tester.pumpAndSettle();

      expect(find.byType(EditEquipmentModal), findsOneWidget);
      expect(find.text('Failed to update equipment'), findsOneWidget);
    },
  );
}
