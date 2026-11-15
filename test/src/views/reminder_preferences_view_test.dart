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

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/data/repositories/profile/dtos/system_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';

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
        remindersConfig: RemindersConfigDto(
          id: 1,
          workoutsOn: false,
          workoutsReminderTime: DateTime(2026, 1, 1, 8),
          weightRecordsOn: false,
          weightRecordsReminderTime: DateTime(2026, 1, 1, 8),
          macroTrackingOn: false,
          macroTrackingReminderTime: DateTime(2026, 1, 1, 8),
        ),
        isLoading: false,
        isInitiated: true,
      ),
    );
  }

  bool? updatedWorkoutsOn;
  bool? updatedWeightRecordsOn;

  @override
  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
    bool? macroTrackingOn,
  }) async {
    updatedWorkoutsOn = workoutsOn;
    updatedWeightRecordsOn = weightRecordsOn;
    emit(
      state.copyWith(
        remindersConfig: Nullable(
          state.remindersConfig!.copyWith(
            workoutsOn: workoutsOn,
            weightRecordsOn: weightRecordsOn,
          ),
        ),
      ),
    );
  }
}

void main() {
  const sizes = DataDisplaySizesList(
    viewPadding: 10,
    subtitleFontSize: 14,
    titleFontSize: 20,
    fontSize: 12,
    smallFontSize: 10,
    buttonIconSize: 18,
    buttonSize: 40,
    margins: 16,
    padding: 12,
    spacing: 12,
    inputSpacing: 8,
    elevation: 1,
  );
}
