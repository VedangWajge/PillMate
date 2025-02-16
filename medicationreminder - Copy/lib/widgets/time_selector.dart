import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final String? label;

  const TimeSelector({
    Key? key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (time != null) {
          onTimeSelected(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 8),
            Text(
              label ?? 'Select Time',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Text(
              selectedTime.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
