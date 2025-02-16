import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;
  final List<Map<String, dynamic>> takenMedicines;
  final VoidCallback onUpdate;
  
  const ReportsPage({
    Key? key, 
    required this.medicines,
    required this.takenMedicines,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Year'];
  Map<String, dynamic> _adherenceStats = {
    'total': 0,
    'taken': 0,
    'missed': 0,
    'rate': '0.0'
  };
  List<Map<String, dynamic>> _medicationHistory = [];

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  @override
  void didUpdateWidget(ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medicines != widget.medicines) {
      _updateStats();
    }
  }

  void _updateStats() {
    setState(() {
      _adherenceStats = _calculateAdherenceStats();
      _medicationHistory = _generateMedicationHistory();
    });
    
    // Call the onUpdate callback to notify HomePage
    widget.onUpdate();
  }

  Map<String, dynamic> _calculateAdherenceStats() {
    int totalDoses = 0;
    int takenDoses = 0;
    
    // Get the date range based on selected period
    DateTime now = DateTime.now();
    DateTime startDate;
    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    for (var medicine in widget.medicines) {
      List<bool> days = List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true));
      List<String> times = List<String>.from(medicine['times'] ?? []);
      DateTime medicineStartDate = DateTime.parse(medicine['startDate']);
      DateTime medicineEndDate = DateTime.parse(medicine['endDate']);

      // Only consider medicines within the selected period
      if (medicineEndDate.isBefore(startDate) || medicineStartDate.isAfter(now)) {
        continue;
      }

      // Calculate doses for each day in the period
      for (DateTime date = startDate;
           date.isBefore(now.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {
        if (date.isBefore(medicineStartDate) || date.isAfter(medicineEndDate)) {
          continue;
        }

        if (days[date.weekday - 1]) {
          totalDoses += times.length;
          // Simulate taken doses (you should replace this with actual tracking data)
          if (date.isBefore(now)) {
            takenDoses += times.length;
          }
        }
      }
    }

    double adherenceRate = totalDoses > 0 ? (takenDoses / totalDoses) * 100 : 0;

    return {
      'total': totalDoses,
      'taken': takenDoses,
      'missed': totalDoses - takenDoses,
      'rate': adherenceRate.toStringAsFixed(1),
    };
  }

  List<Map<String, dynamic>> _generateMedicationHistory() {
    List<Map<String, dynamic>> history = [];
    DateTime now = DateTime.now();

    for (var medicine in widget.medicines) {
      List<String> times = List<String>.from(medicine['times'] ?? []);
      for (var time in times) {
        // Add each dose to history
        history.add({
          'name': medicine['name'],
          'time': time,
          'date': now,
          'status': 'Taken', // You should track actual status
        });
      }
    }

    // Sort by date and time
    history.sort((a, b) => b['date'].compareTo(a['date']));
    return history;
  }

  List<FlSpot> _generateChartData() {
    List<FlSpot> spots = [];
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      double adherenceForDay = _calculateDayAdherence(date);
      spots.add(FlSpot((6 - i).toDouble(), adherenceForDay));
    }
    
    return spots;
  }

  double _calculateDayAdherence(DateTime date) {
    int totalDoses = 0;
    int takenDoses = 0;

    for (var medicine in widget.medicines) {
      List<bool> days = List<bool>.from(medicine['days'] ?? List.generate(7, (index) => true));
      List<String> times = List<String>.from(medicine['times'] ?? []);
      DateTime startDate = DateTime.parse(medicine['startDate']);
      DateTime endDate = DateTime.parse(medicine['endDate']);

      if (date.isBefore(startDate) || date.isAfter(endDate)) {
        continue;
      }

      if (days[date.weekday - 1]) {
        totalDoses += times.length;
        if (date.isBefore(DateTime.now())) {
          takenDoses += times.length;
        }
      }
    }

    return totalDoses > 0 ? (takenDoses / totalDoses) * 5 : 0; // Scale to chart height
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicine Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Track your medication adherence',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildAdherenceCard(),
            const SizedBox(height: 24),
            _buildAdherenceChart(),
            const SizedBox(height: 24),
            _buildMedicationHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.teal : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdherenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adherence Rate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_adherenceStats['rate']}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAdherenceStats('Taken', _adherenceStats['taken'].toString()),
              _buildAdherenceStats('Missed', _adherenceStats['missed'].toString()),
              _buildAdherenceStats('Total', _adherenceStats['total'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceStats(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.now().subtract(Duration(days: (6 - value).toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateChartData(),
              isCurved: true,
              color: Colors.teal,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationHistory() {
    if (_medicationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medication history available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _medicationHistory.length,
          itemBuilder: (context, index) {
            final medication = _medicationHistory[index];
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
                  medication['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Taken at ${medication['time']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    medication['status'],
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 