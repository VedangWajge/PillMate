import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.teal.shade800, Colors.teal.shade400],
              ),
            ),
          ),
          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services, size: 80, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Join us today!',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    _buildForm(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 10)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField("Full Name", Icons.person, false),
            SizedBox(height: 10),
            _buildTextField("Age", Icons.calendar_today, false, isNumber: true),
            SizedBox(height: 10),
            _buildTextField("Email", Icons.email, false),
            SizedBox(height: 10),
            _buildTextField("Password", Icons.lock, true),
            SizedBox(height: 20),
            _buildButton(context, "Sign Up", Colors.teal, Colors.white, () {
              if (_formKey.currentState!.validate()) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text("Already have an account? Login", style: TextStyle(color: Colors.teal.shade700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool isPassword, {bool isNumber = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
