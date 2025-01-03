import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/map_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Schedule App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalendarScreen(),
    );
  }
}
