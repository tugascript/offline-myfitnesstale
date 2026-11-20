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

import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/youtube_video_utils.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/layout/dynamic_list_input.dart';
import '../../view_models/exercise_cubit.dart';
import '../../view_models/states/exercise_state.dart';

class ExerciseForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;

  final String initialName;
  final String? initialDescription;
  final String? initialVideoUrl;
  final MuscleGroup? initialMuscleGroup;
  final Set<Muscle> initialPrimaryMuscles;
  final Set<Muscle> initialSecondaryMuscles;
  final Set<int> initialEquipmentIds;
  final Difficulty? initialDifficulty;
  final ExerciseWeightProgress initialWeightProgress;
  final bool initialIsFavorite;

  final void Function({
    required String name,
    required String? description,
    required String? videoUrl,
    required MuscleGroup muscleGroup,
    required Set<Muscle> primaryMuscles,
    required Set<Muscle> secondaryMuscles,
    required Set<int> equipmentIds,
    required Difficulty? difficulty,
    required ExerciseWeightProgress weightProgress,
    required bool isFavorite,
  })
  onSubmit;

  const ExerciseForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.submitLabel,
    this.submitIcon,
    required this.initialName,
    required this.initialDescription,
    this.initialVideoUrl,
    required this.initialMuscleGroup,
    required this.initialPrimaryMuscles,
    required this.initialSecondaryMuscles,
    required this.initialEquipmentIds,
    required this.initialDifficulty,
    this.initialWeightProgress = ExerciseWeightProgress.positive,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ExerciseCubit>().getSelectionEquipments();
      }
    });
    _data = _FormData(
      name: widget.initialName,
      description: widget.initialDescription ?? '',
      videoUrl: widget.initialVideoUrl ?? '',
      muscleGroup: widget.initialMuscleGroup,
      primaryMuscles: {...widget.initialPrimaryMuscles},
      secondaryMuscles: {...widget.initialSecondaryMuscles},
      equipmentIds: {...widget.initialEquipmentIds},
      difficulty: widget.initialDifficulty,
      weightProgress: widget.initialWeightProgress,
      isFavorite: widget.initialIsFavorite,
    );
    _nameController.text = _data.name;
    _descriptionController.text = _data.description;
    _videoUrlController.text = _data.videoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  bool get _hasAvailableGroupMuscles {
    final muscleGroup = _data.muscleGroup;
    if (muscleGroup == null) {
      return false;
    }
    return Muscle.fromMuscleGroup(muscleGroup).any(
      (m) =>
          !_data.primaryMuscles.contains(m) &&
          !_data.secondaryMuscles.contains(m),
    );
  }

  List<Muscle> _muscleDropdownItems({
    required Muscle currentItem,
    required Set<Muscle> excludedMuscles,
  }) {
    final muscleGroup = _data.muscleGroup;
    final availableMuscles = muscleGroup != null
        ? Muscle.fromMuscleGroup(muscleGroup)
        : Muscle.values.toSet();
    final items = availableMuscles
        .where((m) => m == currentItem || !excludedMuscles.contains(m))
        .toList();
    if (!items.contains(currentItem)) {
      items.insert(0, currentItem);
    }
    return items;
  }

  void _addMuscle(Set<Muscle> targetMuscles) {
    final muscleGroup = _data.muscleGroup;
    if (muscleGroup == null) {
      return;
    }
    for (final m in Muscle.fromMuscleGroup(muscleGroup)) {
      if (!(_data.primaryMuscles.contains(m) ||
          _data.secondaryMuscles.contains(m))) {
        setState(() {
          targetMuscles.add(m);
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: AppTextFormField(
                  filled: true,
                  theme: widget.theme,
                  maxLines: 1,
                  isLoading: widget.isLoading,
                  controller: _nameController,
                  labelText: "Name",
                  hintText: "Enter exercise name",
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding,
                  onChanged: (value) {
                    setState(() {
                      _data.name = value;
                    });
                  },
                  onSaved: (value) {
                    if (value != null) {
                      setState(() {
                        _data.name = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _data.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.theme.colorScheme.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _data.isFavorite = !_data.isFavorite;
                  });
                },
                tooltip: _data.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _descriptionController,
            labelText: "Description",
            hintText: "Enter exercise description",
            maxLines: 4,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            onChanged: (value) {
              setState(() {
                _data.description = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.description = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _videoUrlController,
            labelText: "YouTube Video URL",
            hintText: "https://www.youtube.com/watch?v=...",
            maxLines: 1,
            keyboardType: TextInputType.url,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            prefixIcon: Icon(
              Icons.ondemand_video,
              size: widget.sizes.subtitleFontSize,
            ),
            suffixIconConstraints: BoxConstraints.tightFor(
              width: widget.sizes.subtitleFontSize * 2.2,
              height: widget.sizes.subtitleFontSize * 2.2,
            ),
            suffixIcon: _data.videoUrl.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.clear,
                      size: widget.sizes.subtitleFontSize,
                    ),
                    onPressed: () {
                      _videoUrlController.clear();
                      setState(() {
                        _data.videoUrl = '';
                      });
                    },
                    tooltip: 'Clear video URL',
                  )
                : null,
            onChanged: (value) {
              setState(() {
                _data.videoUrl = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.videoUrl = value;
                });
              }
            },
            validator: YoutubeVideoUtils.validateOptionalUrl,
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<MuscleGroup>(
            theme: widget.theme,
            isLoading: widget.isLoading,
            value: _data.muscleGroup,
            filled: true,
            emptyLabel: 'Muscle Group',
            labelText: 'Muscle Group',
            items: MuscleGroup.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: (d) => EnumDisplayNames.getMuscleGroupDisplayName(d),
            onChanged: (value) {
              setState(() {
                _data.muscleGroup = value;
                if (value == null) {
                  _data.primaryMuscles.clear();
                  _data.secondaryMuscles.clear();
                } else {
                  final allowedMuscles = Muscle.fromMuscleGroup(value);
                  _data.primaryMuscles.retainAll(allowedMuscles);
                  _data.secondaryMuscles.retainAll(allowedMuscles);
                }
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.muscleGroup = value;
                });
              }
            },
            validator: (value) =>
                value == null ? 'Please select a muscle group' : null,
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<Difficulty>(
            theme: widget.theme,
            isLoading: widget.isLoading,
            value: _data.difficulty,
            filled: true,
            emptyLabel: 'Difficulty',
            labelText: 'Difficulty',
            items: Difficulty.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: (d) => EnumDisplayNames.getDifficultyDisplayName(d),
            onChanged: (value) {
              setState(() {
                _data.difficulty = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.difficulty = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<ExerciseWeightProgress>(
            theme: widget.theme,
            isLoading: widget.isLoading,
            value: _data.weightProgress,
            filled: true,
            emptyLabel: 'Weight Progress',
            showEmptyValue: false,
            items: ExerciseWeightProgress.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelText: 'Weight Progress',
            labelBuilder: (d) =>
                EnumDisplayNames.getExerciseWeightProgressDisplayName(d),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _data.weightProgress = value;
                });
              }
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.weightProgress = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          Text(
            "🥇 Primary Muscles",
            style: TextStyle(
              fontSize: widget.sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.sizes.spacing),
          DynamicListInput<Muscle>(
            filled: true,
            theme: widget.theme,
            handlesPadding: widget.sizes.thirdPadding,
            items: _data.primaryMuscles.toList(),
            addEnabled: _hasAvailableGroupMuscles,
            itemBuilder: (context, index, item) {
              return AppDropdown<Muscle>(
                theme: widget.theme,
                isLoading: widget.isLoading,
                filled: true,
                value: item,
                emptyLabel: 'Primary Muscle',
                items: _muscleDropdownItems(
                  currentItem: item,
                  excludedMuscles: _data.secondaryMuscles,
                ),
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                labelBuilder: (d) => EnumDisplayNames.getMuscleDisplayName(d),
                onChanged: (value) {
                  setState(() {
                    _data.primaryMuscles.remove(item);
                    if (value != null) {
                      _data.primaryMuscles.add(value);
                    }
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.primaryMuscles.add(value);
                    });
                  }
                },
              );
            },
            onChanged: (value) {
              setState(() {
                _data.primaryMuscles = value.toSet();
              });
            },
            onAdd: () => _addMuscle(_data.primaryMuscles),
            keyBuilder: (item) => ValueKey(item),
            addLabel: 'Add Muscle',
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            spacing: widget.sizes.spacing,
            isLoading: widget.isLoading,
          ),
          SizedBox(height: widget.sizes.spacing),
          Text(
            "🥈 Secondary Muscles",
            style: TextStyle(
              fontSize: widget.sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.sizes.spacing),
          DynamicListInput<Muscle>(
            theme: widget.theme,
            handlesPadding: widget.sizes.thirdPadding,
            items: _data.secondaryMuscles.toList(),
            filled: true,
            addEnabled: _hasAvailableGroupMuscles,
            itemBuilder: (context, index, item) {
              return AppDropdown<Muscle>(
                theme: widget.theme,
                isLoading: widget.isLoading,
                value: item,
                filled: true,
                emptyLabel: 'Secondary Muscle',
                items: _muscleDropdownItems(
                  currentItem: item,
                  excludedMuscles: _data.primaryMuscles,
                ),
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                labelBuilder: (d) => EnumDisplayNames.getMuscleDisplayName(d),
                onChanged: (value) {
                  setState(() {
                    _data.secondaryMuscles.remove(item);
                    if (value != null) {
                      _data.secondaryMuscles.add(value);
                    }
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.secondaryMuscles.add(value);
                    });
                  }
                },
              );
            },
            onChanged: (value) {
              setState(() {
                _data.secondaryMuscles = value.toSet();
              });
            },
            onAdd: () => _addMuscle(_data.secondaryMuscles),
            keyBuilder: (item) => ValueKey(item),
            addLabel: 'Add Muscle',
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            spacing: widget.sizes.spacing,
            isLoading: widget.isLoading,
          ),
          SizedBox(height: widget.sizes.spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.fitness_center, size: widget.sizes.subtitleFontSize),
              Text(
                " Equipments",
                style: TextStyle(
                  fontSize: widget.sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          BlocBuilder<ExerciseCubit, ExerciseState>(
            builder: (context, state) {
              final equipmentIds = state.equipmentSelection.keys.toList();
              if (equipmentIds.isEmpty) {
                return const SizedBox.shrink();
              }

              return DynamicListInput<int>(
                theme: widget.theme,
                handlesPadding: widget.sizes.thirdPadding,
                items: _data.equipmentIds.toList(),
                filled: true,
                itemBuilder: (context, index, item) {
                  return AppDropdown<int>(
                    theme: widget.theme,
                    isLoading: widget.isLoading,
                    value: item,
                    filled: true,
                    emptyLabel: 'Equipment',
                    items: equipmentIds,
                    fontSize: widget.sizes.subtitleFontSize,
                    padding: widget.sizes.padding,
                    labelBuilder: (d) => state.equipmentSelection[d]!,
                    onChanged: (value) {
                      setState(() {
                        _data.equipmentIds.remove(item);
                        if (value != null) {
                          _data.equipmentIds.add(value);
                        }
                      });
                    },
                    onSaved: (value) {
                      if (value != null) {
                        setState(() {
                          _data.equipmentIds.add(value);
                        });
                      }
                    },
                  );
                },
                onChanged: (value) {
                  setState(() {
                    _data.equipmentIds = value.toSet();
                  });
                },
                onAdd: () {
                  if (equipmentIds.isEmpty ||
                      _data.equipmentIds.length >= equipmentIds.length) {
                    return;
                  }

                  for (final id in equipmentIds) {
                    if (!_data.equipmentIds.contains(id)) {
                      setState(() {
                        _data.equipmentIds.add(id);
                      });
                      break;
                    }
                  }
                },
                keyBuilder: (item) => ValueKey(item),
                addLabel: 'Add Equipment',
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                spacing: widget.sizes.spacing,
                isLoading: state.isLoading,
              );
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppElevatedButton(
            theme: widget.theme,
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  _data.muscleGroup != null) {
                _formKey.currentState!.save();
                widget.onSubmit(
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  videoUrl: _videoUrlController.text.trim().isEmpty
                      ? null
                      : _videoUrlController.text.trim(),
                  muscleGroup: _data.muscleGroup!,
                  primaryMuscles: _data.primaryMuscles,
                  secondaryMuscles: _data.secondaryMuscles,
                  equipmentIds: _data.equipmentIds,
                  difficulty: _data.difficulty,
                  weightProgress: _data.weightProgress,
                  isFavorite: _data.isFavorite,
                );
              }
            },
            isLoading: widget.isLoading,
            sizes: widget.sizes,
            label: widget.submitLabel,
            icon: widget.submitIcon ?? Icons.add,
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;
  String description;
  String videoUrl;
  MuscleGroup? muscleGroup;
  Set<Muscle> primaryMuscles;
  Set<Muscle> secondaryMuscles;
  Set<int> equipmentIds;
  Difficulty? difficulty;
  ExerciseWeightProgress weightProgress;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.muscleGroup,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipmentIds,
    required this.difficulty,
    required this.weightProgress,
    required this.isFavorite,
  });
}
