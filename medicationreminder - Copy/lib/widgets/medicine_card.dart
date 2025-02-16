import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String dosage;
  final List<String> times;
  final String type;
  final List<bool> days;
  final VoidCallback? onTap;

  const MedicineCard({
    Key? key,
    required this.name,
    required this.dosage,
    required this.times,
    required this.type,
    required this.days,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    type == 'pill' ? Icons.medication :
                    type == 'syrup' ? Icons.local_drink :
                    Icons.vaccines,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$dosage mg',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: times.map((time) => Chip(
                  label: Text(time),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.teal),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _getDaysText(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  String _getDaysText() {
    final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = days.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => weekDays[entry.key])
        .toList();

    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.isEmpty) return 'No days selected';
    return selectedDays.join(', ');
  }
}