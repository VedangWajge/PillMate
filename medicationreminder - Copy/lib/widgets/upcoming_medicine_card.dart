import 'package:flutter/material.dart';

class UpcomingMedicineCard extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;
  final Function(Map<String, dynamic>, String) onMedicineTaken;

  const UpcomingMedicineCard({
    Key? key,
    required this.medicines,
    required this.onMedicineTaken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return _buildEmptyCard('No medicines scheduled');
    }

    // Find the next upcoming dose
    final now = TimeOfDay.now();
    Map<String, dynamic>? nextMedicine;
    String? nextDoseTimeStr;

    for (var medicine in medicines) {
      if (medicine['times'] == null || medicine['times'].isEmpty) continue;
      
      for (String timeStr in medicine['times']) {
        final timeParts = timeStr.split(':');
        final medicineTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1].split(' ')[0]),
        );
        
        if (nextDoseTimeStr == null || 
            _compareTimeOfDay(medicineTime, now) > 0) {
          nextDoseTimeStr = timeStr;
          nextMedicine = medicine;
          break;
        }
      }
    }

    if (nextMedicine == null || nextDoseTimeStr == null) {
      return _buildEmptyCard('No upcoming doses');
    }

    return _buildUpcomingDoseCard(nextMedicine, nextDoseTimeStr);
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Dose',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDoseCard(Map<String, dynamic> medicine, String timeStr) {
    final isTaken = medicine['taken']?[timeStr] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isTaken 
                ? [Colors.grey.shade200, Colors.grey.shade100]
                : [Colors.teal.shade400, Colors.teal.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTaken ? Colors.grey.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.access_time,
              color: isTaken ? Colors.grey : Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            timeStr,
            style: TextStyle(
              color: isTaken ? Colors.grey : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${medicine['name']} - ${medicine['dosage']}mg',
            style: TextStyle(
              color: isTaken ? Colors.grey : Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          trailing: isTaken 
              ? const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                )
              : ElevatedButton(
                  onPressed: () => onMedicineTaken(medicine, timeStr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TAKE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 - minutes2;
  }
} 