import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;
  final List<Map<String, dynamic>> takenMedicines;
  final VoidCallback onUpdate;

  const CalendarPage({
    Key? key,
    required this.medicines,
    required this.takenMedicines,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateEvents();
  }

  @override
  void didUpdateWidget(CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medicines != widget.medicines) {
      _updateEvents();
    }
  }

  void _updateEvents() {
    setState(() {
      _events.clear();
      for (var medicine in widget.medicines) {
        List<bool> days = List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true));
        List<String> times = List<String>.from(medicine['times'] ?? []);
        DateTime startDate = DateTime.parse(medicine['startDate']);
        DateTime endDate = DateTime.parse(medicine['endDate']);

        for (DateTime date = startDate;
            date.isBefore(endDate.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          int weekday = date.weekday - 1;
          if (days[weekday]) {
            final eventDate = DateTime(date.year, date.month, date.day);
            for (String time in times) {
              _events.update(
                eventDate,
                (list) => [...list, '${medicine['name']} - $time'],
                ifAbsent: () => ['${medicine['name']} - $time'],
              );
            }
          }
        }
      }
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getEventsForDay(_selectedDay ?? _focusedDay).length,
            itemBuilder: (context, index) {
              final events = _getEventsForDay(_selectedDay ?? _focusedDay);
              final eventStr = events[index].toString();
              final medicineName = eventStr.split(' - ')[0];
              final time = eventStr.split(' - ')[1];
              
              final medicine = widget.medicines.firstWhere(
                (m) => m['name'] == medicineName,
                orElse: () => {},
              );
              
              final isTaken = medicine['taken']?[time] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.grey.shade100 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: isTaken ? Colors.grey : Colors.teal,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    medicineName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isTaken ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: isTaken ? Colors.grey : Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.grey.shade100 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      isTaken ? 'TAKEN' : 'TAKE',
                      style: TextStyle(
                        color: isTaken ? Colors.grey : Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: isTaken ? null : () => _markMedicineTaken(medicine, time),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _markMedicineTaken(Map<String, dynamic> medicine, String time) {
    setState(() {
      medicine['taken'] ??= <String, bool>{};
      medicine['taken'][time] = true;
      
      widget.takenMedicines.add({
        'name': medicine['name'],
        'takenAt': DateTime.now().toIso8601String(),
        'scheduledTime': time,
        'medicine': medicine,
      });
    });

    widget.onUpdate();
  }
} 