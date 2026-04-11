import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/app_dropdown.dart';
import '../layout/app_number_wheel.dart';
import '../layout/app_text_form_field.dart';

/// Difficulty type + value wheel, matching active-set logging behavior.
class WorkoutSetExerciseDifficultyInput extends StatefulWidget {
  final WorkoutSetExerciseDifficultyType initialDifficultyType;
  final int initialDifficultyValue;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final void Function(
    WorkoutSetExerciseDifficultyType type,
    int value,
  ) onChanged;

  const WorkoutSetExerciseDifficultyInput({
    super.key,
    required this.initialDifficultyType,
    required this.initialDifficultyValue,
    required this.theme,
    required this.sizes,
    required this.onChanged,
  });

  @override
  State<WorkoutSetExerciseDifficultyInput> createState() =>
      _WorkoutSetExerciseDifficultyInputState();
}

class _WorkoutSetExerciseDifficultyInputState
    extends State<WorkoutSetExerciseDifficultyInput> {
  late WorkoutSetExerciseDifficultyType _type;
  late int _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _type = widget.initialDifficultyType;
    _value = widget.initialDifficultyValue;
    _controller = TextEditingController(text: _formatValue(_value));
    // Defer so parents can safely call setState / update ancestors (not during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(_type, _value);
    });
  }

  @override
  void didUpdateWidget(covariant WorkoutSetExerciseDifficultyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDifficultyType != widget.initialDifficultyType ||
        oldWidget.initialDifficultyValue != widget.initialDifficultyValue) {
      _type = widget.initialDifficultyType;
      _value = widget.initialDifficultyValue;
      
      final String formattedText = _formatValue(_value);
      
      // Updating controllers inside didUpdateWidget can synchronously trigger
      // form validations or internal widget re-builds, throwing: 
      // "setState() or markNeedsBuild() called during build"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.text != formattedText) {
          _controller.text = formattedText;
        }
        widget.onChanged(_type, _value);
      });
    }
  }

  String _formatValue(int v) {
    if (_type == WorkoutSetExerciseDifficultyType.rmp) return '$v%';
    return '$v';
  }

  (int, int) get _range => (_type.minValue, _type.maxValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWheel() {
    final (minVal, maxVal) = _range;
    int initial = _value.clamp(minVal, maxVal);
    final controller = FixedExtentScrollController(
      initialItem: initial - minVal,
    );
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    'Difficulty (${_type.value})',
                    style: TextStyle(
                      fontSize: widget.sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final idx = controller.selectedItem;
                      final val = minVal + idx;
                      setState(() {
                        _value = val;
                        _controller.text = _formatValue(val);
                      });
                      widget.onChanged(_type, val);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: AppNumberWheel(
                minValue: minVal,
                maxValue: maxVal,
                scrollController: controller,
                itemExtent: widget.sizes.subtitleFontSize * 3,
                fontSize: widget.sizes.subtitleFontSize,
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AppTextFormField(
            theme: widget.theme,
            controller: _controller,
            readOnly: true,
            onTap: _openWheel,
            labelText: 'Difficulty',
            hintText: 'Value',
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding,
            isLoading: false,
            filled: true,
            prefixIcon: Icon(Icons.bolt, size: widget.sizes.fontSize * 1.2),
          ),
        ),
        SizedBox(width: widget.sizes.inputSpacing),
        Expanded(
          flex: 3,
          child: AppDropdown<WorkoutSetExerciseDifficultyType>(
            value: _type,
            emptyLabel: 'None',
            showEmptyValue: false,
            items: WorkoutSetExerciseDifficultyType.values,
            labelBuilder: (t) => t.value,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                _value = _value.clamp(v.minValue, v.maxValue);
                _controller.text = _formatValue(_value);
              });
              widget.onChanged(_type, _value);
            },
            onSaved: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                _value = _value.clamp(v.minValue, v.maxValue);
                _controller.text = _formatValue(_value);
              });
              widget.onChanged(_type, _value);
            },
            fontSize: widget.sizes.fontSize,
            padding: widget.sizes.padding * 0.4,
            filled: true,
          ),
        ),
      ],
    );
  }
}
