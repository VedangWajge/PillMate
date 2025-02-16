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
      routes: {
        '/': (context) => WelcomePage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/add-medicine': (context) => AddMedicinePage(),
        '/calendar': (context) => CalendarPage(
          takenMedicines: [],
          onUpdate: () {},
        ),
        '/reports': (context) => ReportsPage(
          medicines: [],
          takenMedicines: [],
          onUpdate: () {},
        ),
      },
    );
  }
}