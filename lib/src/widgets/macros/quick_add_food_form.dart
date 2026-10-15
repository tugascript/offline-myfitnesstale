import 'package:flutter/material.dart';

import '../../services/inputs/quick_food_log_input.dart';
import '../../utilities/converters.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../layout/app_text_form_field.dart';
import '../layout/responsive_fields.dart';

class QuickAddFoodForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Future<bool> Function(QuickFoodLogInput) onSubmit;

  const QuickAddFoodForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.onSubmit,
  });

  @override
  State<QuickAddFoodForm> createState() => _QuickAddFoodFormState();
}

class _QuickAddFoodFormState extends State<QuickAddFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _calories = TextEditingController(text: '0');
  final _protein = TextEditingController(text: '0');
  final _carbs = TextEditingController(text: '0');
  final _fat = TextEditingController(text: '0');
  bool _calculateCalories = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final controller in [_protein, _carbs, _fat]) {
      controller.addListener(_updateCalories);
    }
  }

  void _updateCalories() {
    if (!_calculateCalories) return;
    final protein = int.tryParse(_protein.text);
    final carbs = int.tryParse(_carbs.text);
    final fat = int.tryParse(_fat.text);
    _calories.text =
        protein == null ||
            carbs == null ||
            fat == null ||
            protein < 0 ||
            carbs < 0 ||
            fat < 0
        ? ''
        : Converters.macrosToCalories(
            protein: protein,
            carbs: carbs,
            fats: fat,
          ).toString();
  }

  @override
  void dispose() {
    for (final controller in [_name, _calories, _protein, _carbs, _fat]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final input = QuickFoodLogInput(
      name: _name.text.trim(),
      calories: int.parse(_calories.text),
      protein: int.parse(_protein.text),
      carbs: int.parse(_carbs.text),
      fat: int.parse(_fat.text),
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    final success = await widget.onSubmit(input);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!success) _error = 'Could not save this entry. Please try again.';
    });
  }

  Widget _number(
    String name,
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) => AppTextFormField(
    key: ValueKey('quick-add-$name-input'),
    theme: widget.theme,
    fontSize: widget.sizes.fontSize,
    padding: widget.sizes.padding,
    isLoading: _saving,
    controller: controller,
    readOnly: readOnly,
    keyboardType: TextInputType.number,
    labelText: label,
    validator: (value) {
      final number = int.tryParse(value ?? '');
      return number == null || number < 0
          ? 'Enter a non-negative whole number'
          : null;
    },
  );

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Log totals for this entry. No food is added to your library.',
          style: TextStyle(fontSize: widget.sizes.smallFontSize),
        ),
        SizedBox(height: widget.sizes.spacing),
        AppTextFormField(
          key: const ValueKey('quick-add-name-input'),
          theme: widget.theme,
          fontSize: widget.sizes.fontSize,
          padding: widget.sizes.padding,
          isLoading: _saving,
          controller: _name,
          labelText: 'Name *',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
        ),
        SizedBox(height: widget.sizes.spacing),
        ResponsiveFields(
          sizes: widget.sizes,
          children: [
            _number('protein', 'Protein (g) *', _protein),
            _number('carbs', 'Carbs (g) *', _carbs),
            _number('fat', 'Fat (g) *', _fat),
          ],
        ),
        SizedBox(height: widget.sizes.spacing),
        _number(
          'calories',
          'Calories (kcal) *',
          _calories,
          readOnly: _calculateCalories,
        ),
        CheckboxListTile(
          key: const ValueKey('quick-add-calculate-calories'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Calculate calories from macros',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
          value: _calculateCalories,
          onChanged: _saving
              ? null
              : (value) => setState(() {
                  _calculateCalories = value ?? false;
                  _updateCalories();
                }),
        ),
        if (_error != null) ...[
          SizedBox(height: widget.sizes.spacing),
          Text(
            _error!,
            style: TextStyle(
              fontSize: widget.sizes.fontSize,
              color: widget.theme.colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: widget.sizes.spacing),
        ElevatedButton(
          key: const ValueKey('quick-add-confirm-btn'),
          onPressed: _saving ? null : _submit,
          child: Text(
            _saving ? 'Saving…' : 'Log Entry',
            style: TextStyle(fontSize: widget.sizes.fontSize),
          ),
        ),
      ],
    ),
  );
}
