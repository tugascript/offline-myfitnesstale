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
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/layout/app_modal.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import './equipment_form.dart';

class CreateEquipmentModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateEquipmentModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) => EquipmentForm(
          theme: theme,
          sizes: sizes,
          initialName: '',
          isLoading: state.isLoading,
          submitLabel: "CREATE EQUIPMENT",
          onSubmit: ({required String name}) async {
            final cubit = context.read<ExerciseCubit>();
            await cubit.createEquipment(EquipmentInput(name: name));
            if (context.mounted && cubit.state.error == null) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
