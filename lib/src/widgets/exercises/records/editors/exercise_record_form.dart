import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_number_wheel.dart';
import '../../../layout/app_elevated_button.dart';
import '../../../layout/app_text_form_field.dart';

class ExerciseRecordForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int exerciseId;

  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;

  final DateTime initialDate;
  final int initialWeight;
  final int initialReps;

  final void Function({
    required int exerciseId,
    required int weight,
    required int reps,
    required DateTime date,
  }) onSubmit;

  const ExerciseRecordForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exerciseId,
    required this.isLoading,
    required this.submitLabel,
    this.submitIcon,
    required this.initialDate,
    required this.initialWeight,
    required this.initialReps,
    required this.onSubmit,
  });

  @override
  State<ExerciseRecordForm> createState() => _ExerciseRecordFormState();
}

class _ExerciseRecordFormState extends State<ExerciseRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _dateController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    final double weight = widget.units == Units.imperial
        ? Converters.gramsToLbs(widget.initialWeight)
        : Converters.gramsToKg(widget.initialWeight);

    _data = _FormData(
      date: widget.initialDate,
      weight: weight,
      reps: widget.initialReps,
    );
    _weightController.text = weight.toStringAsFixed(2);
    _repsController.text = widget.initialReps.toString();
    _dateController.text = Formatters.formatDate(
      widget.units,
      widget.initialDate,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  theme: widget.theme,
                  readOnly: true,
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding * 2,
                  isLoading: widget.isLoading,
                  controller: _repsController,
                  labelText: "Reps",
                  hintText: "Enter the reps",
                  filled: true,
                  prefixIcon: Icon(
                    Icons.repeat_one,
                    size: widget.sizes.subtitleFontSize * 1.2,
                  ),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (sheetContext) => _RepsWheelSheetContent(
                        theme: widget.theme,
                        sizes: widget.sizes,
                        initialReps: _data.reps,
                        onRepsChanged: (value) {
                          _repsController.text = value;
                          final parsed = int.tryParse(value);
                          if (parsed == null) {
                            return;
                          }
                          setState(() {
                            _data.reps = parsed;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: widget.sizes.inputSpacing),
              Expanded(
                child: AppTextFormField(
                  filled: true,
                  theme: widget.theme,
                  maxLines: 1,
                  isLoading: widget.isLoading,
                  controller: _weightController,
                  labelText: "Weight",
                  hintText: "Enter the weight",
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding * 2,
                  suffixIconConstraints: BoxConstraints(
                    minWidth: widget.sizes.subtitleFontSize * 4,
                    minHeight: widget.sizes.subtitleFontSize * 1.5,
                  ),
                  suffixIcon: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: widget.sizes.padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.units == Units.imperial ? "LBS" : "KG",
                          style: TextStyle(
                            fontSize: widget.sizes.subtitleFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.scale,
                    size: widget.sizes.subtitleFontSize * 1.2,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the weight";
                    }

                    final weight = double.tryParse(value);
                    if (weight == null) {
                      return "Please enter a valid weight";
                    }

                    switch (widget.units) {
                      case Units.imperial:
                        if (weight < 0 || weight > 1367) {
                          return "Weight needs to be between 0 and 1367 lbs";
                        }
                        break;
                      case Units.metric:
                        if (weight < 0 || weight > 620) {
                          return "Weight needs to be between 0 and 620 kg";
                        }
                        break;
                    }

                    return null;
                  },
                  onChanged: (value) {
                    if (value == "") {
                      _weightController.text = "";
                      setState(() {
                        _data.weight = 0;
                      });
                      return;
                    }

                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      _weightController.text = _data.weight.toString();
                      return;
                    }

                    setState(() {
                      _data.weight = parsed;
                    });
                  },
                  onSaved: (value) {
                    if (value == null) {
                      return;
                    }
                    if (value == "") {
                      _weightController.text = "";
                      setState(() {
                        _data.weight = 0;
                      });
                      return;
                    }

                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return;
                    }

                    setState(() {
                      _data.weight = parsed;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          AppTextFormField(
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding * 2,
            filled: true,
            controller: _dateController,
            isLoading: widget.isLoading,
            labelText: "Date",
            hintText: "Enter the date",
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _data.date,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now,
              );
              if (pickedDate != null) {
                setState(() {
                  _data.date = pickedDate;
                });
                _dateController.text = Formatters.formatDate(
                  widget.units,
                  pickedDate,
                );
              }
            },
            prefixIcon: Icon(
              Icons.calendar_month,
              size: widget.sizes.subtitleFontSize * 1.2,
            ),
            keyboardType: TextInputType.datetime,
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              theme: widget.theme,
              isLoading: widget.isLoading,
              sizes: widget.sizes,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(
                    exerciseId: widget.exerciseId,
                    weight: widget.units == Units.imperial
                        ? Converters.lbsToGrams(_data.weight)
                        : Converters.kgToGrams(_data.weight),
                    reps: _data.reps,
                    date: _data.date,
                  );
                }
              },
              label: widget.submitLabel,
              icon: widget.submitIcon ?? Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  DateTime date;
  double weight;
  int reps;

  _FormData({
    required this.date,
    required this.weight,
    required this.reps,
  });
}

const int _repsMin = 1;
const int _repsMax = 10;

class _RepsWheelSheetContent extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int initialReps;
  final ValueChanged<String> onRepsChanged;

  const _RepsWheelSheetContent({
    required this.theme,
    required this.sizes,
    required this.initialReps,
    required this.onRepsChanged,
  });

  @override
  State<_RepsWheelSheetContent> createState() => _RepsWheelSheetContentState();
}

class _RepsWheelSheetContentState extends State<_RepsWheelSheetContent> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FixedExtentScrollController(initialItem: widget.initialReps - _repsMin);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final index = _controller.selectedItem;
    final val = _repsMin + index;
    widget.onRepsChanged(val.toString());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final wheelItemExtent = widget.sizes.subtitleFontSize * 3;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(widget.sizes.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Text(
                  'Reps',
                  style: TextStyle(
                    fontSize: widget.sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _onConfirm,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: wheelItemExtent * 5,
            width: double.infinity,
            child: AppNumberWheel(
              minValue: _repsMin,
              maxValue: _repsMax,
              scrollController: _controller,
              itemExtent: wheelItemExtent,
              fontSize: widget.sizes.subtitleFontSize,
            ),
          )
        ],
      ),
    );
  }
}
