import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_elevated_button.dart';
import '../../../layout/app_text_form_field.dart';

class WeightRecordForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;

  final DateTime initialDate;
  final int initialWeight;
  final int? initialBodyFatPercentage;

  final void Function({
    required int weight,
    int? bodyFat,
    required DateTime date,
  }) onSubmit;

  const WeightRecordForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.isLoading,
    required this.submitLabel,
    this.submitIcon,
    required this.initialDate,
    required this.initialWeight,
    this.initialBodyFatPercentage,
    required this.onSubmit,
  });

  @override
  State<WeightRecordForm> createState() => _WeightRecordFormState();
}

class _WeightRecordFormState extends State<WeightRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _dateController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    final double weight = widget.units == Units.imperial
        ? Converters.gramsToLbs(widget.initialWeight)
        : Converters.gramsToKg(widget.initialWeight);
    final double? bodyFatPercentage = widget.initialBodyFatPercentage != null
        ? Converters.intPercentToDouble(widget.initialBodyFatPercentage!)
        : null;
    _data = _FormData(
      date: widget.initialDate,
      weight: weight,
      bodyFatPercentage: bodyFatPercentage,
    );
    _weightController.text = weight.toStringAsFixed(2);
    _bodyFatController.text = bodyFatPercentage?.toStringAsFixed(2) ?? "";
    _dateController.text = _formatDate(widget.units, widget.initialDate);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
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
              padding: EdgeInsets.symmetric(horizontal: widget.sizes.padding),
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
              Icons.monitor_weight,
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
                  if (weight < 44 || weight > 661) {
                    return "Weight needs to be between 44 and 661 lbs";
                  }
                  break;
                case Units.metric:
                  if (weight < 20 || weight > 300) {
                    return "Weight needs to be between 20 and 300 kg";
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
          SizedBox(height: widget.sizes.inputSpacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            isLoading: widget.isLoading,
            controller: _bodyFatController,
            labelText: "Body Fat Percentage",
            hintText: "Enter the body fat percentage",
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding * 2,
            suffixIconConstraints: BoxConstraints(
              minWidth: widget.sizes.subtitleFontSize * 4,
              minHeight: widget.sizes.subtitleFontSize * 1.5,
            ),
            prefixIcon: Icon(
              Icons.percent,
              size: widget.sizes.subtitleFontSize * 1.2,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              final bodyFatPercentage = double.tryParse(value);
              if (bodyFatPercentage == null) {
                return "Please enter a valid body fat percentage";
              }

              if (bodyFatPercentage < 3 || bodyFatPercentage > 50) {
                return "Body fat percentage needs to be between 3 and 50";
              }

              return null;
            },
            onChanged: (value) {
              if (value == "") {
                _bodyFatController.text = "";
                setState(() {
                  _data.bodyFatPercentage = null;
                });
                return;
              }

              final parsed = double.tryParse(value);
              if (parsed == null) {
                _bodyFatController.text =
                    _data.bodyFatPercentage?.toString() ?? "";
                return;
              }

              setState(() {
                _data.bodyFatPercentage = parsed;
              });
            },
            onSaved: (value) {
              if (value == null) {
                return;
              }
              if (value == "") {
                _bodyFatController.text = "";
                setState(() {
                  _data.bodyFatPercentage = null;
                });
                return;
              }

              final parsed = double.tryParse(value);
              if (parsed == null) {
                return;
              }

              setState(() {
                _data.bodyFatPercentage = parsed;
              });
            },
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
                _dateController.text = _formatDate(widget.units, pickedDate);
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
                    weight: widget.units == Units.imperial
                        ? Converters.lbsToGrams(_data.weight)
                        : Converters.kgToGrams(_data.weight),
                    bodyFat: _data.bodyFatPercentage == null
                        ? null
                        : Converters.doublePercentToInt(
                            _data.bodyFatPercentage!,
                          ),
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

  String _formatDate(Units unit, DateTime date) {
    switch (unit) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy").format(date);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy").format(date);
    }
  }
}

final class _FormData {
  DateTime date;
  double weight;
  double? bodyFatPercentage;

  _FormData({
    required this.date,
    required this.weight,
    this.bodyFatPercentage,
  });
}
