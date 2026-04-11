import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_text_form_field.dart';

const int _maxMinutes = 60;

String formatRestDurationMmSs(int totalSecs) {
  final m = totalSecs ~/ 60;
  final s = totalSecs % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Read-only field that opens an mm:ss wheel picker; reports total seconds on confirm.
class WorkoutRestDurationInput extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialTotalSecs;
  final ValueChanged<int> onChanged;

  const WorkoutRestDurationInput({
    super.key,
    required this.theme,
    required this.sizes,
    required this.initialTotalSecs,
    required this.onChanged,
  });

  @override
  State<WorkoutRestDurationInput> createState() =>
      _WorkoutRestDurationInputState();
}

class _WorkoutRestDurationInputState extends State<WorkoutRestDurationInput> {
  late final TextEditingController _controller;
  late int _totalSecs;

  @override
  void initState() {
    super.initState();
    _totalSecs = _clampTotal(widget.initialTotalSecs);
    _controller =
        TextEditingController(text: formatRestDurationMmSs(_totalSecs));
  }

  @override
  void didUpdateWidget(covariant WorkoutRestDurationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTotalSecs != widget.initialTotalSecs) {
      _totalSecs = _clampTotal(widget.initialTotalSecs);
      _controller.text = formatRestDurationMmSs(_totalSecs);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _clampTotal(int secs) {
    final maxSecs = _maxMinutes * 60 + 59;
    return secs.clamp(0, maxSecs);
  }

  void _openWheel() {
    var mins = (_totalSecs ~/ 60).clamp(0, _maxMinutes);
    var secs = _totalSecs % 60;
    if (mins == _maxMinutes) secs = 0;

    final minutesController = FixedExtentScrollController(initialItem: mins);
    final secondsController = FixedExtentScrollController(initialItem: secs);

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
                    'Rest',
                    style: TextStyle(
                      fontSize: widget.sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      int m =
                          minutesController.selectedItem.clamp(0, _maxMinutes);
                      int s = secondsController.selectedItem.clamp(0, 59);
                      if (m == _maxMinutes) s = 0;
                      final total = m * 60 + s;
                      setState(() {
                        _totalSecs = total;
                        _controller.text = formatRestDurationMmSs(total);
                      });
                      widget.onChanged(total);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.sizes.subtitleFontSize * 3 * 5,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: widget.sizes.subtitleFontSize * 3,
                      scrollController: minutesController,
                      onSelectedItemChanged: (_) {},
                      children: List.generate(
                        _maxMinutes + 1,
                        (index) => Center(
                          child: Text(
                            '$index',
                            style: TextStyle(
                              fontSize: widget.sizes.subtitleFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: widget.sizes.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: widget.sizes.subtitleFontSize * 3,
                      scrollController: secondsController,
                      onSelectedItemChanged: (_) {},
                      children: List.generate(
                        60,
                        (index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: widget.sizes.subtitleFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      minutesController.dispose();
      secondsController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      theme: widget.theme,
      controller: _controller,
      readOnly: true,
      onTap: _openWheel,
      labelText: 'Rest',
      hintText: '0:00',
      fontSize: widget.sizes.fontSize,
      padding: widget.sizes.padding,
      isLoading: false,
      filled: true,
      prefixIcon: Icon(Icons.timer, size: widget.sizes.fontSize * 1.2),
    );
  }
}
