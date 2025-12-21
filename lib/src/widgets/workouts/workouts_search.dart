import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/sizes/workouts_sizes.dart';

class WorkoutsSearch extends StatefulWidget {
  final WorkoutsSizesList sizes;
  final bool isLoading;
  final String initialName;
  final Difficulty? initialDifficulty;
  final void Function({
    required String name,
    required Difficulty? difficulty,
  }) onSubmit;

  const WorkoutsSearch({
    super.key,
    required this.isLoading,
    required this.sizes,
    required this.initialName,
    required this.initialDifficulty,
    required this.onSubmit,
  });

  @override
  State<WorkoutsSearch> createState() => _WorkoutsSearchState();
}

class _WorkoutsSearchState extends State<WorkoutsSearch> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      difficulty: widget.initialDifficulty,
    );
    _nameController.text = _data.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
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
            decoration: InputDecoration(
              hintText: 'Search workouts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _data.name.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _data.name = '';
                        });
                        _nameController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.sizes.radius),
              ),
            ),
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Difficulty?>(
                  initialValue: _data.difficulty,
                  items: [
                    const DropdownMenuItem<Difficulty?>(
                      value: null,
                      child: Text('All Difficulties'),
                    ),
                    ...Difficulty.values.map(
                      (d) => DropdownMenuItem<Difficulty?>(
                        value: d,
                        child: Text(_difficultyLabel(d)),
                      ),
                    )
                  ],
                  onChanged: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      _data.difficulty = value;
                    });
                  },
                ),
              ),
              SizedBox(width: widget.sizes.inputSpacing),
              IconButton(
                icon: widget.isLoading
                    ? SizedBox(
                        width: widget.sizes.loadingSize,
                        height: widget.sizes.loadingSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: widget.sizes.buttonIconSize,
                        color: Theme.of(context).primaryColor,
                      ),
                onPressed: () {
                  setState(() {
                    if (!widget.isLoading) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onSubmit(
                          name: _data.name,
                          difficulty: _data.difficulty,
                        );
                      }
                    }
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

String _difficultyLabel(Difficulty d) {
  switch (d) {
    case Difficulty.beginner:
      return 'Beginner';
    case Difficulty.beginnerIntermediate:
      return 'Beginner / Intermediate';
    case Difficulty.intermediate:
      return 'Intermediate';
    case Difficulty.intermediateAdvanced:
      return 'Intermediate / Advanced';
    case Difficulty.advanced:
      return 'Advanced';
  }
}

final class _FormData {
  String name;
  Difficulty? difficulty;

  _FormData({
    required this.name,
    required this.difficulty,
  });
}
