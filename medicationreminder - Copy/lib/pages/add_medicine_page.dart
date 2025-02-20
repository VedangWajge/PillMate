import 'package:flutter/material.dart';
import '../widgets/time_selector.dart';

class AddMedicinePage extends StatefulWidget {
  final Map<String, dynamic>? editMedicine;

  const AddMedicinePage({Key? key, this.editMedicine}) : super(key: key);

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late List<TimeOfDay> _selectedTimes;
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late int _dosesPerDay;
  List<bool> _selectedDays = List.generate(7, (index) => true); // All days selected by default
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Add start and end date
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30)); // Default 30 days

  @override
  void initState() {
    super.initState();
    _selectedType = widget.editMedicine?['type'] ?? 'pill';
    _nameController = TextEditingController(text: widget.editMedicine?['name'] ?? '');
    _dosageController = TextEditingController(text: widget.editMedicine?['dosage'] ?? '');
    
    if (widget.editMedicine != null) {
      List<dynamic> times = widget.editMedicine!['times'];
      _dosesPerDay = times.length;
      _selectedTimes = times.map((t) => _parseTimeOfDay(t)).toList();
      _selectedDays = List<bool>.from(widget.editMedicine!['days'] ?? List.generate(7, (index) => true));
      _startDate = DateTime.parse(widget.editMedicine!['startDate'] ?? DateTime.now().toIso8601String());
      _endDate = DateTime.parse(widget.editMedicine!['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String());
    } else {
      _dosesPerDay = 1;
      _selectedTimes = [TimeOfDay.now()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _updateDosesPerDay(int doses) {
    setState(() {
      _dosesPerDay = doses;
      if (_selectedTimes.length < doses) {
        // Add new times
        while (_selectedTimes.length < doses) {
          _selectedTimes.add(TimeOfDay.now());
        }
      } else if (_selectedTimes.length > doses) {
        // Remove extra times
        _selectedTimes = _selectedTimes.sublist(0, doses);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editMedicine != null ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMedicineTypeSelector(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.medical_services),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medicine name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage (mg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dosage';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            _buildDosesPerDaySelector(),
            const SizedBox(height: 24),
            _buildDaysSelector(),
            const SizedBox(height: 24),
            _buildTimeSelectors(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final medicineData = {
                    'name': _nameController.text,
                    'dosage': _dosageController.text,
                    'times': _selectedTimes.map((time) => time.format(context)).toList(),
                    'type': _selectedType,
                    'days': _selectedDays,
                    'startDate': _startDate.toIso8601String(),
                    'endDate': _endDate.toIso8601String(),
                    'taken': <String, bool>{},
                  };
                  Navigator.pop(context, medicineData);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(widget.editMedicine != null ? 'Update Medicine' : 'Add Medicine'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                      if (_startDate.isAfter(_endDate)) {
                        _endDate = _startDate.add(const Duration(days: 1));
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDosesPerDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doses per Day',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((doses) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () => _updateDosesPerDay(doses),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dosesPerDay == doses ? Colors.teal : Colors.grey[200],
                    foregroundColor: _dosesPerDay == doses ? Colors.white : Colors.black,
                  ),
                  child: Text('$doses'),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Days of Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            return FilterChip(
              label: Text(_weekDays[index]),
              selected: _selectedDays[index],
              onSelected: (bool selected) {
                setState(() {
                  _selectedDays[index] = selected;
                });
              },
              selectedColor: Colors.teal,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedDays[index] ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Times',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_dosesPerDay, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TimeSelector(
              selectedTime: _selectedTimes[index],
              onTimeSelected: (time) {
                setState(() {
                  _selectedTimes[index] = time;
                });
              },
              label: 'Dose ${index + 1}',
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMedicineTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicine Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildTypeOption('pill', Icons.medication),
            SizedBox(width: 16),
            _buildTypeOption('syrup', Icons.local_drink),
            SizedBox(width: 16),
            _buildTypeOption('injection', Icons.vaccines),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}