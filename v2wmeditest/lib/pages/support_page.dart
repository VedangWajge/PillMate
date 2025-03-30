import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> doctors = const [
    {
      'name': 'Dr. Priya Sharma',
      'speciality': 'General Physician',
      'qualification': 'MBBS, MD (Internal Medicine)',
      'phone': '+91 98765 43210',
      'email': 'dr.priya@example.com',
      'address': '123 Apollo Clinic\nBandra West, Mumbai 400050',
      'image': 'assets/images/doctor1.jpg',
      'availability': {
        'weekdays': '10:00 AM - 6:00 PM',
        'saturday': '10:00 AM - 2:00 PM',
        'sunday': 'Emergency Only'
      }
    },
    {
      'name': 'Dr. Rajesh Patel',
      'speciality': 'Cardiologist',
      'qualification': 'MBBS, DM (Cardiology)',
      'phone': '+91 98765 43211',
      'email': 'dr.rajesh@example.com',
      'address': '456 Heart Care Center\nJuhu, Mumbai 400049',
      'image': 'assets/images/doctor2.jpg',
      'availability': {
        'weekdays': '11:00 AM - 7:00 PM',
        'saturday': '11:00 AM - 3:00 PM',
        'sunday': 'Closed'
      }
    },
    {
      'name': 'Dr. Suresh Kumar',
      'speciality': 'Pediatrician',
      'qualification': 'MBBS, MD (Pediatrics)',
      'phone': '+91 98765 43212',
      'email': 'dr.suresh@example.com',
      'address': '789 Children\'s Hospital\nAndheri East, Mumbai 400069',
      'image': 'assets/images/doctor3.jpg',
      'availability': {
        'weekdays': '9:00 AM - 5:00 PM',
        'saturday': '9:00 AM - 1:00 PM',
        'sunday': 'Emergency Only'
      }
    },
    {
      'name': 'Dr. Anjali Desai',
      'speciality': 'Neurologist',
      'qualification': 'MBBS, DM (Neurology)',
      'phone': '+91 98765 43213',
      'email': 'dr.anjali@example.com',
      'address': '321 Neuro Care Institute\nPowai, Mumbai 400076',
      'image': 'assets/images/doctor4.jpg',
      'availability': {
        'weekdays': '10:30 AM - 6:30 PM',
        'saturday': '10:30 AM - 2:30 PM',
        'sunday': 'Closed'
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildDoctorCard(context, doctor);
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDoctorDetails(context, doctor),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: AssetImage(doctor['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor['speciality'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor['qualification'],
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.teal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetails(BuildContext context, Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DoctorDetailsSheet(doctor: doctor),
    );
  }
}

class DoctorDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsSheet({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(doctor['image']),
                backgroundColor: Colors.teal.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor['speciality'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoTile(Icons.phone, 'Phone', doctor['phone']),
          _buildInfoTile(Icons.email, 'Email', doctor['email']),
          _buildInfoTile(Icons.location_on, 'Address', doctor['address']),
          const SizedBox(height: 16),
          const Text(
            'Availability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildAvailabilityTile('Weekdays', doctor['availability']['weekdays']),
          _buildAvailabilityTile('Saturday', doctor['availability']['saturday']),
          _buildAvailabilityTile('Sunday', doctor['availability']['sunday']),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTile(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 