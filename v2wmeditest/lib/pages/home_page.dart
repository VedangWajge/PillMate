import 'package:flutter/material.dart';
import '../pages/add_medicine_page.dart';
import '../pages/edit_profile_page.dart';
import '../pages/reports_page.dart';
import '../pages/calendar_page.dart';
import '../pages/support_page.dart';
import '../widgets/upcoming_medicine_card.dart';
import '../widgets/medicine_list.dart';
import '../widgets/home_navigation_bar.dart';
import '../widgets/home_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The main home page of the application.
/// Manages the navigation between different sections and medicine data.
class HomePage extends StatefulWidget {
  final VoidCallback onLogout;  // Add logout callback

  const HomePage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// List of all medicines
  final List<Map<String, dynamic>> medicines = [];
  
  /// List of taken medicines with timestamps
  final List<Map<String, dynamic>> takenMedicines = [];
  
  /// Currently selected tab index
  int _selectedIndex = 0;
  
  /// Map of medicine events by date
  final Map<DateTime, List<Map<String, dynamic>>> _medicineEvents = {};
  
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _updateMedicineEvents();
    _loadUserData();
  }

  Future<void> _loadSavedData() async {
    try {
      // TODO: Implement loading saved data from local storage
      setState(() {
        // Update state with loaded data
      });
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  void _saveMedicineData() {
    try {
      // TODO: Implement saving data to local storage
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void _updateMedicineEvents() {
    // Avoid calling setState if we're in the middle of a build
    if (!mounted) return;
    
    setState(() {
      _medicineEvents.clear();
      for (var medicine in medicines) {
        List<bool> days = List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true));
        DateTime startDate = DateTime.parse(medicine['startDate']);
        DateTime endDate = DateTime.parse(medicine['endDate']);
        
        for (DateTime date = startDate;
             date.isBefore(endDate.add(const Duration(days: 1)));
             date = date.add(const Duration(days: 1))) {
          
          int weekday = date.weekday - 1;
          if (days[weekday]) {
            final eventDate = DateTime(date.year, date.month, date.day);
            _medicineEvents.update(
              eventDate,
              (list) => [...list, medicine],
              ifAbsent: () => [medicine],
            );
          }
        }
      }
    });
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userData = {
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'uid': user.uid,
        // Add any other fields you need
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: HomeNavigationBar(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddMedicine,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return ReportsPage(
          medicines: medicines,
          takenMedicines: takenMedicines,
          onUpdate: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMedicineEvents();
            });
          },
        );
      case 2:
        return CalendarPage(
          medicines: medicines,
          takenMedicines: takenMedicines,
          onUpdate: _updateMedicineEvents,
        );
      case 3:
        return const SupportPage();
      case 4:
        return EditProfilePage(
          userProfile: _userData,
          onProfileUpdated: _handleProfileUpdate,
          onLogout: widget.onLogout,  // Pass the logout callback
        );
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UpcomingMedicineCard(
          medicines: medicines,
          onMedicineTaken: _markMedicineTaken,
        ),
        const SizedBox(height: 24),
        MedicineList(
          medicines: medicines,
          onEdit: _editMedicine,
          onDelete: (index) {
            setState(() {
              medicines.removeAt(index);
              _updateMedicineEvents();
              _saveMedicineData();
            });
          },
          onUndo: (index) {
            final deletedMedicine = medicines[index];
            setState(() {
              medicines.insert(index, deletedMedicine);
              _updateMedicineEvents();
              _saveMedicineData();
            });
          },
          onMedicineTaken: _markMedicineTaken,
        ),
      ],
    );
  }

  void _editMedicine(int index, Map<String, dynamic> medicine) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/add-medicine',
        arguments: medicine,
      );
      
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          medicines[index] = result;
          _updateMedicineEvents();
          _saveMedicineData();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to edit medicine. Please try again.'),
        ),
      );
    }
  }

  void _handleProfileUpdate(Map<String, dynamic> newProfile) {
    setState(() {
      _userData = newProfile;
      _saveMedicineData(); // Save updated profile data
    });
  }

  void _navigateToAddMedicine() async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/add-medicine',
      );
      
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          medicines.add(result);
          _updateMedicineEvents();
          _saveMedicineData();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add medicine. Please try again.'),
        ),
      );
    }
  }

  void _markMedicineTaken(Map<String, dynamic> medicine, String time) {
    setState(() {
      // Initialize taken map if it doesn't exist
      medicine['taken'] ??= <String, bool>{};
      // Mark the specific time as taken
      medicine['taken'][time] = true;
      
      takenMedicines.add({
        'name': medicine['name'],
        'takenAt': DateTime.now().toIso8601String(),
        'scheduledTime': time,
        'medicine': medicine,
      });
      _updateMedicineEvents();
      _saveMedicineData();
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userProfile: _userData,
          onProfileUpdated: (updatedProfile) {
            setState(() {
              _userData = updatedProfile;
            });
          },
          onLogout: widget.onLogout,
        ),
      ),
    );
  }
}