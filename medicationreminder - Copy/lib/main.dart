import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_medicine_page.dart';
import 'pages/calendar_page.dart';
import 'pages/reports_page.dart';
// import 'pages/medicine_details_page.dart';

void main() {
  runApp(MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => WelcomePage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignUpPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/add-medicine':
            final medicine = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AddMedicinePage(editMedicine: medicine),
            );
          case '/calendar':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => CalendarPage(
                  medicines: List<Map<String, dynamic>>.from(args['medicines'] ?? []),
                  takenMedicines: List<Map<String, dynamic>>.from(args['takenMedicines'] ?? []),
                  onUpdate: args['onUpdate'] as VoidCallback? ?? (() {}),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => CalendarPage(
                medicines: const [],
                takenMedicines: const [],
                onUpdate: () {},
              ),
            );
          case '/reports':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ReportsPage(
                  medicines: List<Map<String, dynamic>>.from(args['medicines'] ?? []),
                  takenMedicines: List<Map<String, dynamic>>.from(args['takenMedicines'] ?? []),
                  onUpdate: args['onUpdate'] as VoidCallback? ?? (() {}),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => ReportsPage(
                medicines: const [],
                takenMedicines: const [],
                onUpdate: () {},
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => WelcomePage());
        }
      },
    );
  }
}