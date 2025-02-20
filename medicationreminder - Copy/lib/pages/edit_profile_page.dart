import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const EditProfilePage({
    Key? key,
    required this.userProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

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
              try {
                if (_validateInputs()) {
                  final updatedProfile = {
                    'name': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                    'phone': _phoneController.text.trim(),
                    'emergencyContact': _emergencyContactController.text.trim(),
                    'allergies': _allergiesController.text.trim(),
                    'bloodType': _bloodTypeController.text.trim(),
                  };
                  widget.onProfileUpdated(updatedProfile);
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update profile. Please try again.'),
                  ),
                );
              }
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

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return false;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }
    if (!_isValidPhone(_phoneController.text.trim())) {
      _showError('Please enter a valid phone number');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }
} 