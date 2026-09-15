import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_dropdown.dart';
import '../../../layout/app_elevated_button.dart';
import '../../../layout/app_text_form_field.dart';

class WeightGoalForm extends StatefulWidget {
  final ThemeData theme;
  final Units units;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;

  final WeightGoalPhase initialPhase;
  final int initialWeight;
  final int? initialFatPercentage;

  final void Function({
    required int weight,
    required WeightGoalPhase phase,
    int? fatPercentage,
  }) onSubmit;

  const WeightGoalForm({
    super.key,
    required this.theme,
    required this.units,
    required this.sizes,
    required this.isLoading,
    required this.submitLabel,
    required this.initialWeight,
    required this.initialPhase,
    required this.onSubmit,
    this.initialFatPercentage,
    this.submitIcon,
  });

  @override
  State<WeightGoalForm> createState() => _WeightGoalFormState();
}

class _WeightGoalFormState extends State<WeightGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    final double weight = widget.units == Units.imperial
        ? Converters.gramsToLbs(widget.initialWeight)
        : Converters.gramsToKg(widget.initialWeight);
    final double? fatPercentage = widget.initialFatPercentage != null
        ? Converters.intPercentToDouble(widget.initialFatPercentage!)
        : null;
    _data = _FormData(
      weight: weight,
      phase: widget.initialPhase,
      fatPercentage: fatPercentage,
    );
    _weightController.text = weight.toStringAsFixed(2);
    _fatPercentageController.text = fatPercentage?.toStringAsFixed(2) ?? "";
  }

  @override
  void dispose() {
    _weightController.dispose();
    _fatPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppDropdown<WeightGoalPhase>(
            value: _data.phase,
            emptyLabel: "Phase",
            labelText: "Phase",
            showEmptyValue: false,
            items: WeightGoalPhase.values,
            prefixIcon: Icon(
              _getIconForPhase(_data.phase),
              size: widget.sizes.subtitleFontSize * 1.2,
            ),
            labelBuilder: (p) => Converters.capitalizeString(p.name),
            onChanged: (phase) {
              if (widget.isLoading) {
                return;
              }
              if (phase == null) {
                return;
              }
              setState(() {
                _data.phase = phase;
              });
            },
            onSaved: (phase) {
              if (widget.isLoading) {
                return;
              }
              if (phase == null) {
                return;
              }
              setState(() {
                _data.phase = phase;
              });
            },
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            filled: true,
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            isLoading: false,
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
                _weightController.text = _data.weight.toString();
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
            controller: _fatPercentageController,
            labelText: "Body Fat Percentage",
            hintText: "Enter the body fat percentage",
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding * 2,
            suffixIconConstraints: BoxConstraints(
              minWidth: widget.sizes.subtitleFontSize * 4,
              minHeight: widget.sizes.subtitleFontSize * 1.5,
            ),
            prefixIcon: Icon(
              Icons.water_drop_outlined,
              size: widget.sizes.subtitleFontSize * 1.2,
            ),
            suffixIcon: Icon(
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
                _fatPercentageController.text = "";
                setState(() {
                  _data.fatPercentage = null;
                });
                return;
              }

              final parsed = double.tryParse(value);
              if (parsed == null) {
                _fatPercentageController.text =
                    _data.fatPercentage?.toString() ?? "";
                return;
              }

              setState(() {
                _data.fatPercentage = parsed;
              });
            },
            onSaved: (value) {
              if (value == null) {
                return;
              }
              if (value == "") {
                _fatPercentageController.text = "";
                setState(() {
                  _data.fatPercentage = null;
                });
                return;
              }

              final parsed = double.tryParse(value);
              if (parsed == null) {
                return;
              }

              setState(() {
                _data.fatPercentage = parsed;
              });
            },
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              theme: widget.theme,
              isLoading: widget.isLoading,
              sizes: widget.sizes,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  widget.onSubmit(
                    weight: widget.units == Units.imperial
                        ? Converters.lbsToGrams(_data.weight)
                        : Converters.kgToGrams(_data.weight),
                    phase: _data.phase,
                    fatPercentage: _data.fatPercentage != null
                        ? Converters.doublePercentToInt(_data.fatPercentage!)
                        : null,
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

  IconData _getIconForPhase(WeightGoalPhase phase) {
    switch (phase) {
      case WeightGoalPhase.cut:
        return Icons.trending_down;
      case WeightGoalPhase.bulk:
        return Icons.trending_up;
      case WeightGoalPhase.maintain:
        return Icons.trending_flat;
    }
  }
}

final class _FormData {
  WeightGoalPhase phase;
  double weight;
  double? fatPercentage;

  _FormData({
    required this.phase,
    required this.weight,
    this.fatPercentage,
  });
}
