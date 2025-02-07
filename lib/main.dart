
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch_in/provider/attendance%20provider.dart';
import 'package:punch_in/punch_in.dart';

void main() {
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: MaterialApp(
        title: 'Attendance System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}