import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Icon(
                  Icons.medical_services,
                  size: 100,
                  color: Color(0xFF009688),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Pill Mate',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your personal medication reminder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Column(
                  children: [
                    _buildFeatureItem(
                      Icons.access_time,
                      'Never miss a dose',
                      'Get timely reminders for your medications',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      Icons.calendar_today,
                      'Track your progress',
                      'Monitor your medication adherence',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      Icons.bar_chart,
                      'Detailed Reports',
                      'View your medication history and patterns',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    _buildButton(
                      context,
                      'Sign Up',
                      const Color(0xFF009688),
                      Colors.white,
                      () => Navigator.pushNamed(context, '/signup'),
                    ),
                    const SizedBox(height: 12),
                    _buildButton(
                      context,
                      'Sign In',
                      Colors.white,
                      const Color(0xFF009688),
                      () => Navigator.pushNamed(context, '/login'),
                      borderColor: const Color(0xFF009688),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF009688)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed, {
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
