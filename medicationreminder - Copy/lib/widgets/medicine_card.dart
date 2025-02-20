import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String dosage;
  final List<String> times;
  final String type;
  final List<bool> days;
  final VoidCallback onTap;
  final Function(String) onTake;
  final Map<String, bool> taken;

  const MedicineCard({
    Key? key,
    required this.name,
    required this.dosage,
    required this.times,
    required this.type,
    required this.days,
    required this.onTap,
    required this.onTake,
    required this.taken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dosage mg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMedicineIcon(type),
                      color: Colors.teal,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((time) {
                  bool isTaken = taken[time] ?? false;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isTaken ? null : [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ActionChip(
                      label: Text(time),
                      onPressed: isTaken ? null : () => onTake(time),
                      backgroundColor: isTaken 
                        ? Colors.grey.withOpacity(0.1) 
                        : Colors.teal.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: isTaken ? Colors.grey : Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                      avatar: isTaken 
                        ? const Icon(Icons.check_circle, size: 18, color: Colors.grey) 
                        : const Icon(Icons.access_time, size: 18, color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 4,
                    children: _buildDayIndicators(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onTap,
                      color: Colors.teal,
                      tooltip: 'Edit Medicine',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDayIndicators() {
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List.generate(7, (index) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: days[index] 
              ? Colors.teal 
              : Colors.grey.withOpacity(0.1),
          border: Border.all(
            color: days[index] 
                ? Colors.teal 
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            weekDays[index],
            style: TextStyle(
              color: days[index] ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  IconData _getMedicineIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
        return Icons.medication;
      case 'syrup':
        return Icons.local_drink;
      case 'injection':
        return Icons.vaccines;
      default:
        return Icons.medication;
    }
  }
}