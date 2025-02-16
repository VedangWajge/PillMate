import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _allergiesController;
  late TextEditingController _bloodTypeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile['name']);
    _emailController = TextEditingController(text: widget.userProfile['email']);
    _phoneController = TextEditingController(text: widget.userProfile['phone']);
    _emergencyContactController = TextEditingController(text: widget.userProfile['emergencyContact']);
    _allergiesController = TextEditingController(text: widget.userProfile['allergies']);
    _bloodTypeController = TextEditingController(text: widget.userProfile['bloodType']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _allergiesController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedProfile = {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
                'emergencyContact': _emergencyContactController.text,
                'allergies': _allergiesController.text,
                'bloodType': _bloodTypeController.text,
              };
              Navigator.pop(context, updatedProfile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Stack(
                children: [
                  const Icon(Icons.person, size: 50, color: Colors.white),
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement image picker
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Full Name', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Phone Number', Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(_emergencyContactController, 'Emergency Contact', Icons.emergency),
            const SizedBox(height: 16),
            _buildTextField(_allergiesController, 'Allergies', Icons.warning),
            const SizedBox(height: 16),
            _buildTextField(_bloodTypeController, 'Blood Type', Icons.bloodtype),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
} 