import 'package:flutter/material.dart';
import '../widgets/medicine_card.dart';
import '../pages/add_medicine_page.dart';
import '../pages/edit_profile_page.dart';
import 'package:table_calendar/table_calendar.dart';
import '../pages/reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> medicines = [];
  List<Map<String, dynamic>> takenMedicines = [];
  int _selectedIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;  // Start with week view
  Map<String, dynamic> userProfile = {
    'name': 'Vedang Wajge',
    'email': 'vedangtest@example.com',
    'phone': '+91 8920015230',
    'emergencyContact': '+1 234 567 8901',
    'allergies': 'None',
    'bloodType': 'O+',
  };
  Map<DateTime, List<Map<String, dynamic>>> _medicineEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateMedicineEvents();
  }

  void _updateMedicineEvents() {
    _medicineEvents.clear();
    for (var medicine in medicines) {
      List<bool> days = List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true));
      DateTime startDate = DateTime.parse(medicine['startDate']);
      DateTime endDate = DateTime.parse(medicine['endDate']);
      
      // Create events for each day between start and end date
      for (DateTime date = startDate;
           date.isBefore(endDate.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {
        
        int weekday = date.weekday - 1; // 0-6 for Monday-Sunday
        
        if (days[weekday]) {
          DateTime eventDate = DateTime(date.year, date.month, date.day);
          if (!_medicineEvents.containsKey(eventDate)) {
            _medicineEvents[eventDate] = [];
          }
          _medicineEvents[eventDate]!.add(medicine);
        }
      }
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _medicineEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicine Reminder',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Keep track of your medications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.teal.withAlpha(25),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.teal),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _selectedIndex == 0 
          ? _buildHomeTab()
          : _selectedIndex == 1
              ? _buildReportsTab()
              : _selectedIndex == 2
                  ? _buildCalendarTab()
                  : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMedicinePage(),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    medicines.add(result);
                  });
                }
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUpcomingSection(),
        const SizedBox(height: 24),
        _buildAllMedicinesSection(context),
      ],
    );
  }

  Widget _buildReportsTab() {
    return ReportsPage(
      medicines: medicines,
      takenMedicines: takenMedicines,
      onUpdate: _updateReports,
    );
  }

  Widget _buildCalendarTab() {
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
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              _updateMedicineEvents();
            });
          },
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildScheduleList(),
        ),
      ],
    );
  }

  Widget _buildScheduleList() {
    if (_selectedDay == null) return const SizedBox();

    final medicinesForDay = _getEventsForDay(_selectedDay!);

    if (medicinesForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No medications scheduled for\n${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicinesForDay.length,
      itemBuilder: (context, index) {
        final medicine = medicinesForDay[index];
        final times = List<String>.from(medicine['times'] ?? []);

        return Column(
          children: times.map((time) {
            final isTaken = takenMedicines.any((taken) => 
              taken['name'] == medicine['name'] && 
              taken['scheduledTime'] == time &&
              DateTime.parse(taken['takenAt']).day == _selectedDay!.day &&
              DateTime.parse(taken['takenAt']).month == _selectedDay!.month &&
              DateTime.parse(taken['takenAt']).year == _selectedDay!.year
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(
                    Icons.medication,
                    color: Colors.teal.shade700,
                  ),
                ),
                title: Text(
                  medicine['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: isTaken 
                  ? Icon(Icons.check_circle, color: Colors.green[600])
                  : TextButton(
                      onPressed: () => _markMedicineTaken(medicine, time),
                      child: const Text('TAKE'),
                    ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    onPressed: () => _editProfile(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userProfile['name'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile['email'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileInfo(),
          const SizedBox(height: 24),
          _buildProfileOption(Icons.settings, 'Settings'),
          _buildProfileOption(Icons.notifications, 'Notifications'),
          _buildProfileOption(Icons.security, 'Privacy'),
          _buildProfileOption(Icons.help, 'Help & Support'),
          _buildProfileOption(Icons.logout, 'Logout', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.phone, 'Phone', userProfile['phone'] ?? ''),
            const Divider(),
            _buildInfoRow(Icons.emergency, 'Emergency Contact', userProfile['emergencyContact'] ?? ''),
            const Divider(),
            _buildInfoRow(Icons.warning, 'Allergies', userProfile['allergies'] ?? ''),
            const Divider(),
            _buildInfoRow(Icons.bloodtype, 'Blood Type', userProfile['bloodType'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userProfile: userProfile),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        userProfile = result;
      });
    }
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.teal),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
    );
  }

  Widget _buildUpcomingSection() {
    if (medicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Dose',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No medicines scheduled',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Find the next upcoming dose
    final now = TimeOfDay.now();
    Map<String, dynamic>? nextMedicine;
    TimeOfDay? nextDoseTime;
    String? nextDoseTimeStr;

    for (var medicine in medicines) {
      if (medicine['times'] == null || medicine['times'].isEmpty) continue;
      
      for (String timeStr in medicine['times']) {
        final doseTime = _parseTimeOfDay(timeStr);
        if (nextDoseTime == null) {
          nextDoseTime = doseTime;
          nextDoseTimeStr = timeStr;
          nextMedicine = medicine;
        } else {
          if (_isTimeEarlier(doseTime, nextDoseTime, now)) {
            nextDoseTime = doseTime;
            nextDoseTimeStr = timeStr;
            nextMedicine = medicine;
          }
        }
      }
    }

    if (nextMedicine == null || nextDoseTimeStr == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Dose',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No upcoming doses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                nextDoseTimeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${nextMedicine['name']} - ${nextMedicine['dosage']}mg',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.toLowerCase().split(' ');
    final timeParts = parts[0].split(':');
    int hours = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);
    
    if (parts[1] == 'pm' && hours != 12) {
      hours += 12;
    } else if (parts[1] == 'am' && hours == 12) {
      hours = 0;
    }
    
    return TimeOfDay(hour: hours, minute: minutes);
  }

  // Helper method to compare times considering the current time
  bool _isTimeEarlier(TimeOfDay time1, TimeOfDay time2, TimeOfDay now) {
    final time1Minutes = time1.hour * 60 + time1.minute;
    final time2Minutes = time2.hour * 60 + time2.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    // If one time is before now and the other is after, prefer the one after
    if ((time1Minutes < nowMinutes) != (time2Minutes < nowMinutes)) {
      return time1Minutes > nowMinutes;
    }

    // If both times are before or after now, compare them directly
    return time1Minutes < time2Minutes;
  }

  Widget _buildAllMedicinesSection(BuildContext context) {
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
                setState(() {
                  medicines.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Medicine deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        setState(() {
                          medicines.insert(index, medicine);
                        });
                      },
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
                onTap: () => _editMedicine(context, index, medicine),
              ),
            );
          }),
      ],
    );
  }

  void _editMedicine(BuildContext context, int index, Map<String, dynamic> medicine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(
          editMedicine: medicine,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        medicines[index] = result;
      });
    }
  }

  void _markMedicineTaken(Map<String, dynamic> medicine, String time) {
    setState(() {
      takenMedicines.add({
        ...medicine,
        'takenAt': DateTime.now().toIso8601String(),
        'scheduledTime': time,
      });
    });

    // Notify the ReportsPage to update its data
    _updateReports();
  }

  void _updateReports() {
    // This method can be used to notify the ReportsPage to refresh its data
    // You can implement a callback or use a state management solution
    // For simplicity, we can just call setState here if ReportsPage is a direct child
    // Otherwise, consider using a state management solution like Provider or Riverpod
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsPage(
          medicines: medicines,
          takenMedicines: takenMedicines,
          onUpdate: () {
            // This will be called to refresh the reports
            setState(() {
              // You can add any additional logic here if needed
            });
          },
        ),
      ),
    );
  }
}