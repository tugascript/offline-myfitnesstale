import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/enums.dart';

class WeightInputWidget extends StatefulWidget {
  final double? initialWeight;
  final Units units;
  final Function(double weight) onWeightChanged;
  final bool isLoading;

  const WeightInputWidget({
    super.key,
    this.initialWeight,
    required this.units,
    required this.onWeightChanged,
    this.isLoading = false,
  });

  @override
  State<WeightInputWidget> createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends State<WeightInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      _controller.text = _formatWeight(widget.initialWeight!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) {
    if (widget.units == Units.metric) {
      // Convert grams to kg for display
      return (weight / 1000).toStringAsFixed(1);
    } else {
      // Convert grams to lbs for display
      return (weight / 453.592).toStringAsFixed(1);
    }
  }

  double _parseWeight(String value) {
    final double? parsed = double.tryParse(value);
    if (parsed == null) return 0.0;

    if (widget.units == Units.metric) {
      // Convert kg to grams
      return parsed * 1000;
    } else {
      // Convert lbs to grams
      return parsed * 453.592;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText:
                widget.units == Units.metric ? 'Weight (kg)' : 'Weight (lbs)',
            border: const OutlineInputBorder(),
            suffixIcon: Icon(
              widget.units == Units.metric
                  ? Icons.monitor_weight
                  : Icons.monitor_weight_outlined,
            ),
            helperText: widget.units == Units.metric
                ? 'Enter weight in kilograms (e.g., 70.5)'
                : 'Enter weight in pounds (e.g., 155.0)',
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final weight = _parseWeight(value);
              widget.onWeightChanged(weight);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your weight';
            }
            final weight = double.tryParse(value);
            if (weight == null) {
              return 'Please enter a valid number';
            }
            if (weight <= 0) {
              return 'Weight must be greater than 0';
            }
            if (widget.units == Units.metric && weight > 500) {
              return 'Weight seems too high (kg)';
            }
            if (widget.units == Units.imperial && weight > 1100) {
              return 'Weight seems too high (lbs)';
            }
            return null;
          },
        ),
      ],
    );
  }
}
