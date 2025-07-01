import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const PlantenApp());
}

class PlantenApp extends StatelessWidget {
  const PlantenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ate's Forrest",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}