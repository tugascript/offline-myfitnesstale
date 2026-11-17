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

import '../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../../data/utils/json_data.dart';
import '../../../utils/nullable.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/widgets/layout/app_modal.dart';
import '../view_models/exercise_cubit.dart';
import '../view_models/states/exercise_state.dart';
import './equipment_form.dart';

class EditEquipmentModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final EquipmentDto equipment;

  const EditEquipmentModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.equipment,
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
          initialName: equipment.name,
          isLoading: state.isLoading,
          submitLabel: "UPDATE EQUIPMENT",
          submitIcon: Icons.save,
          onSubmit: ({required String name}) async {
            final existingPicture = equipment.picture;
            final cubit = context.read<ExerciseCubit>();
            await cubit.updateEquipment(
              equipment.id,
              EquipmentInput(
                name: name,
                picture: Nullable(
                  existingPicture != null
                      ? PictureData(
                          uri: existingPicture.uri,
                          storage: existingPicture.storage,
                        )
                      : null,
                ),
                isFavorite: equipment.isFavorite,
              ),
            );
            if (context.mounted && cubit.state.error == null) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
