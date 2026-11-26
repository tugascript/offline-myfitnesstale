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

import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../../data/utils/display_names.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/favourite_checkbox.dart';
import '../../../../core/widgets/layout/app_dropdown.dart';
import '../../../../core/widgets/layout/app_text_form_field.dart';
import '../../../../exercises/view_models/exercise_cubit.dart';
import '../../../../exercises/view_models/states/exercise_state.dart';
import '../editors/set_exercise_search_list.dart';

class CardioExerciseSearchModal extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<ExerciseDto> onExerciseSelected;

  const CardioExerciseSearchModal({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.onExerciseSelected,
  });

  @override
  State<CardioExerciseSearchModal> createState() =>
      _CardioExerciseSearchModalState();
}

class _CardioExerciseSearchModalState extends State<CardioExerciseSearchModal> {
  final _nameController = TextEditingController();
  String _name = '';
  bool _isFavorite = false;
  CardioBaseMode? _baseMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<ExerciseCubit>().getSelectionExercises(
      type: ExerciseType.cardio,
      name: _name,
      isFavorite: _isFavorite,
      cardioBaseMode: _baseMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = widget.sizes.padding / 2;
    final spacing = widget.sizes.spacing / 2;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      insetPadding: EdgeInsets.all(widget.sizes.margins),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          listener: (context, state) {
            if (state.isLoading) {
              return;
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error?.description ?? 'Something went wrong',
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isBusy = state.isLoading || widget.isLoading;
            return Column(
              children: [
                AppTextFormField(
                  theme: theme,
                  isLoading: isBusy,
                  controller: _nameController,
                  hintText: 'Search Cardio Exercises...',
                  fontSize: widget.sizes.fontSize,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  padding: padding,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  onFieldSubmitted: (_) => _search(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Icon(Icons.search, size: widget.sizes.fontSize),
                  ),
                  suffixIcon: _name.isNotEmpty
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.clear,
                            size: widget.sizes.smallFontSize,
                          ),
                          onPressed: () {
                            setState(() {
                              _name = '';
                            });
                            _nameController.clear();
                          },
                        )
                      : null,
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    HeartCheckbox(
                      value: _isFavorite,
                      size: widget.sizes.fontSize * 2,
                      onChanged: (value) {
                        setState(() {
                          _isFavorite = value;
                        });
                      },
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: AppDropdown<CardioBaseMode>(
                        theme: theme,
                        isLoading: isBusy,
                        value: _baseMode,
                        emptyLabel: 'All Modes',
                        items: CardioBaseMode.values,
                        fontSize: widget.sizes.fontSize,
                        padding: padding / 5,
                        labelBuilder:
                            EnumDisplayNames.getCardioBaseModeDisplayName,
                        onChanged: (value) {
                          setState(() {
                            _baseMode = value;
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _baseMode = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: spacing),
                    IconButton(
                      onPressed: isBusy ? null : _search,
                      tooltip: 'Search',
                      icon: Icon(
                        Icons.search,
                        size: widget.sizes.fontSize * 1.6,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing),
                Expanded(
                  child: SetExerciseSearchList(
                    sizes: widget.sizes,
                    isLoading: isBusy,
                    exercises: state.exerciseSelection,
                    onExerciseSelected: widget.onExerciseSelected,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
