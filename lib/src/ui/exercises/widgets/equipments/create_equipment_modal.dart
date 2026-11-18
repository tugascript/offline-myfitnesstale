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

import '../../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../../../data/services/storage/local_file_storage_service.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../utils/nullable.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../view_models/exercise_cubit.dart';
import '../../view_models/states/exercise_state.dart';
import 'equipment_form.dart';

class CreateEquipmentModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final LocalFileStorageService? storageService;
  final EquipmentImagePicker? pickImageBytes;
  final EquipmentPictureEditor? editPictureBytes;

  const CreateEquipmentModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.storageService,
    this.pickImageBytes,
    this.editPictureBytes,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedStorage = storageService ?? LocalFileStorageService.create();

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
          storageService: resolvedStorage,
          pickImageBytes: pickImageBytes,
          editPictureBytes: editPictureBytes,
          onSubmit:
              ({
                required name,
                required picture,
                required uploadedPictureBytes,
              }) async {
                final cubit = context.read<ExerciseCubit>();
                String? newlySavedUri;
                var resolvedPicture = picture;

                if (uploadedPictureBytes != null) {
                  newlySavedUri = await resolvedStorage.savePictureBytes(
                    uploadedPictureBytes,
                    prefix: 'equipment',
                  );
                  resolvedPicture = PictureData(
                    storage: PictureStorage.files,
                    uri: newlySavedUri,
                  );
                }

                await cubit.createEquipment(
                  EquipmentInput(
                    name: name,
                    picture: Nullable(resolvedPicture),
                  ),
                );

                if (cubit.state.error != null) {
                  if (newlySavedUri != null) {
                    await resolvedStorage.deletePicture(newlySavedUri);
                  }
                  return;
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
        ),
      ),
    );
  }
}
