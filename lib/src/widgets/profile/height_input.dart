import 'package:flutter/material.dart';

import '../../utilities/converters.dart';

final class HeightInput extends StatefulWidget {
  final bool isMetric;
  final int initialHeight;
  final void Function(int) onChanged;
  final void Function(int) onSaved;

  const HeightInput({
    super.key,
    required this.initialHeight,
    required this.isMetric,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  State<HeightInput> createState() => _HeightInputState();
}

class _HeightInputState extends State<HeightInput> {
  final TextEditingController _cmController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isMetric) {
      _cmController.text = widget.initialHeight.toString();
      return;
    }

    final (int, int) feetAndInches =
        Converters().cmToFeetAndInches(widget.initialHeight);
    _feetController.text = feetAndInches.$1.toString();
    _inchesController.text = feetAndInches.$2.toString();
  }

  @override
  void dispose() {
    _cmController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMetric
        ? TextFormField(
            controller: _cmController,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: Icon(Icons.straighten),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                widget.onChanged(int.parse(value));
              }
            },
            onSaved: (value) {
              if (value != null && value.isNotEmpty) {
                widget.onSaved(int.parse(value));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a height';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          )
        : Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _feetController,
                  decoration: const InputDecoration(
                    labelText: 'Feet',
                    prefixIcon: Icon(Icons.square_foot),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _updateHeight();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter feet';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _inchesController,
                  decoration: const InputDecoration(
                    labelText: 'Inches',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _updateHeight();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter inches';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
  }

  void _updateHeight() {
    final int feet = int.tryParse(_feetController.text) ?? 0;
    final int inches = int.tryParse(_inchesController.text) ?? 0;
    final int totalCm = Converters().feetAndInchesToCm(feet, inches);
    widget.onChanged(totalCm);
    widget.onSaved(totalCm);
  }
}
