import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../cubits/weight_record_cubit.dart';
import '../cubits/states/weight_record_state.dart';
import '../models/enums.dart';
import '../models/system_model.dart';
import '../models/weight_record_model.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/weight/weight_input_widget.dart';

class WeightLogView extends StatefulWidget {
  static const routeName = "/weight-log";
  static const name = "weight-log";

  const WeightLogView({super.key});

  @override
  State<WeightLogView> createState() => _WeightLogViewState();
}

class _WeightLogViewState extends State<WeightLogView> {
  final _formKey = GlobalKey<FormState>();
  double _weight = 0.0;
  int? _fatPercentage;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: "Log Weight",
      showBackButton: true,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, profileState) {
          return BlocConsumer<WeightRecordCubit, WeightRecordState>(
            listener: (context, weightState) {
              if (weightState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${weightState.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (!weightState.isLoading && _isLoading) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Weight logged successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            builder: (context, weightState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Weight Display
                      if (weightState.weightRecords.isNotEmpty)
                        _buildCurrentWeightCard(weightState.weightRecords.first,
                            profileState.system),

                      const SizedBox(height: 24),

                      // Weight Input
                      WeightInputWidget(
                        initialWeight: weightState.weightRecords.isNotEmpty
                            ? weightState.weightRecords.first.weight.toDouble()
                            : null,
                        units: profileState.system?.units ?? Units.metric,
                        onWeightChanged: (weight) {
                          setState(() {
                            _weight = weight;
                          });
                        },
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Fat Percentage Input (Optional)
                      _buildFatPercentageInput(),

                      const SizedBox(height: 24),

                      // Date Picker
                      _buildDatePicker(),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitWeight,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Log Weight',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Recent Weights
                      if (weightState.weightRecords.isNotEmpty)
                        _buildRecentWeights(
                            weightState.weightRecords, profileState.system),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeightCard(WeightRecord latestWeight, System? system) {
    final units = system?.units ?? Units.metric;
    final displayWeight = units == Units.metric
        ? '${(latestWeight.weight / 1000).toStringAsFixed(1)} kg'
        : '${(latestWeight.weight / 453.592).toStringAsFixed(1)} lbs';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weight',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              displayWeight,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            if (latestWeight.fatPercentage != null) ...[
              const SizedBox(height: 4),
              Text(
                'Body Fat: ${latestWeight.fatPercentage}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFatPercentageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Fat Percentage (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: !_isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Body Fat %',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.analytics),
            helperText: 'Enter your body fat percentage if known',
          ),
          onChanged: (value) {
            setState(() {
              _fatPercentage = int.tryParse(value);
            });
          },
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final fat = double.tryParse(value);
              if (fat == null) {
                return 'Please enter a valid number';
              }
              if (fat < 0 || fat > 50) {
                return 'Body fat should be between 0-50%';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoading ? null : _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentWeights(List<WeightRecord> weightRecords, System? system) {
    final units = system?.units ?? Units.metric;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Weights',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...weightRecords.take(5).map((record) {
          final displayWeight = units == Units.metric
              ? '${(record.weight / 1000).toStringAsFixed(1)} kg'
              : '${(record.weight / 453.592).toStringAsFixed(1)} lbs';

          final date =
              DateTime.fromMillisecondsSinceEpoch(record.recordDate * 1000);
          final dateString = '${date.day}/${date.month}/${date.year}';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: Text(displayWeight),
              subtitle: Text(dateString),
              trailing: record.fatPercentage != null
                  ? Text('${record.fatPercentage}% fat')
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitWeight() {
    if (_formKey.currentState!.validate()) {
      if (_weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid weight'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      context.read<WeightRecordCubit>().createWeightRecord(
            weight: _weight.round(),
            date: _selectedDate,
            fatPercentage: _fatPercentage,
          );
    }
  }
}
