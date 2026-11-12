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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../widgets/profile/create_profile_card.dart';

class CreateProfileButtonScreen extends StatelessWidget {
  const CreateProfileButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Start your Fitness Tale",
      body: Center(
        child: CreateProfileCard(
          onTap: () => context.go(Routes.onboarding.name),
        ),
      ),
    );
  }
}
