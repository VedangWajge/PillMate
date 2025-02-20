import 'package:flutter/material.dart';
import 'medicine_card.dart';

class MedicineList extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;
  final Function(int) onUndo;
  final Function(Map<String, dynamic>, String) onMedicineTaken;

  const MedicineList({
    Key? key,
    required this.medicines,
    required this.onEdit,
    required this.onDelete,
    required this.onUndo,
    required this.onMedicineTaken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Medicines',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (medicines.isEmpty)
          const Center(
            child: Text(
              'No medicines added yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...medicines.asMap().entries.map((entry) {
            final index = entry.key;
            final medicine = entry.value;
            return Dismissible(
              key: Key(medicine['name'] + index.toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                onDelete(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Medicine deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => onUndo(index),
                    ),
                  ),
                );
              },
              child: MedicineCard(
                name: medicine['name'] ?? '',
                dosage: medicine['dosage'] ?? '',
                times: List<String>.from(medicine['times'] ?? []),
                type: medicine['type'] ?? 'pill',
                days: List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true)),
                taken: Map<String, bool>.from(medicine['taken'] ?? {}),
                onTap: () => onEdit(index, medicine),
                onTake: (time) => onMedicineTaken(medicine, time),
              ),
            );
          }),
      ],
    );
  }
} 