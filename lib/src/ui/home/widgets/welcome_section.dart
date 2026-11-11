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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../view_models/profile_cubit.dart';
import '../view_models/states/profile_state.dart';

class WelcomeSection extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const WelcomeSection({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: sizes.elevation,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return Text(
                    "Welcome back ${state.profile?.name ?? "to My Fitness Tale"}!",
                    style: TextStyle(
                      fontSize: sizes.titleFontSize * 1.15,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "Let's continue your fitness tale!",
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize * 1.15,
                  color: isDarkTheme
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
