import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/exercise_cubit.dart';
import '../../cubits/states/exercise_state.dart';
import '../../services/dtos/equipment_dto.dart';

class EquipmentSelectionWidget extends StatefulWidget {
  final List<int> selectedEquipmentIds;
  final Function(List<int>) onSelectionChanged;

  const EquipmentSelectionWidget({
    super.key,
    required this.selectedEquipmentIds,
    required this.onSelectionChanged,
  });

  @override
  State<EquipmentSelectionWidget> createState() =>
      _EquipmentSelectionWidgetState();
}

class _EquipmentSelectionWidgetState extends State<EquipmentSelectionWidget> {
  late List<int> _selectedEquipmentIds;

  @override
  void initState() {
    super.initState();
    _selectedEquipmentIds = List.from(widget.selectedEquipmentIds);
    _loadData();
  }

  void _loadData() {
    context.read<ExerciseCubit>().getEquipments(limit: 1000, offset: 0);
  }

  void _toggleEquipment(int equipmentId) {
    setState(() {
      if (_selectedEquipmentIds.contains(equipmentId)) {
        _selectedEquipmentIds.remove(equipmentId);
      } else {
        _selectedEquipmentIds.add(equipmentId);
      }
      widget.onSelectionChanged(_selectedEquipmentIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, exerciseState) {
        if (exerciseState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final equipments = exerciseState.equipments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Equipment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Selected Equipment Chips
            if (_selectedEquipmentIds.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedEquipmentIds.map((equipmentId) {
                  final equipment = equipments.firstWhere(
                    (e) => e.id == equipmentId,
                    orElse: () => EquipmentDto(
                      id: equipmentId,
                      name: 'Unknown Equipment',
                    ),
                  );
                  return Chip(
                    label: Text(equipment.name),
                    onDeleted: () => _toggleEquipment(equipmentId),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Equipment List
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: equipments.length,
                itemBuilder: (context, index) {
                  final equipment = equipments[index];
                  final isSelected =
                      _selectedEquipmentIds.contains(equipment.id);
                  return CheckboxListTile(
                    title: Text(equipment.name),
                    value: isSelected,
                    onChanged: (_) => _toggleEquipment(equipment.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
