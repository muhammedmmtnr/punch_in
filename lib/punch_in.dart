
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch_in/provider/attendance%20provider.dart';
import 'package:punch_in/services/loaction_service.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _currentDistance;

  Future<void> _updateDistance() async {
    try {
      double distance = await LocationService.getCurrentDistance();
      setState(() {
        _currentDistance = distance;
      });
    } catch (e) {
      print('Error getting distance: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _updateDistance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance System'),
      ),
      body: Center(
        child: Consumer<AttendanceProvider>(
          builder: (context, attendanceProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  attendanceProvider.isPunchedIn 
                      ? Icons.check_circle_outline 
                      : Icons.radio_button_unchecked,
                  size: 100,
                  color: attendanceProvider.isPunchedIn 
                      ? Colors.green 
                      : Colors.grey,
                ),
                SizedBox(height: 20),
                Text(
                  attendanceProvider.isPunchedIn 
                      ? 'Currently Checked In'
                      : 'Currently Checked Out',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                if (_currentDistance != null)
                  Text(
                    'Distance to target: ${_currentDistance!.toStringAsFixed(1)} meters',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      bool isInRange = await LocationService.isWithinRange();
                      if (isInRange) {
                        await attendanceProvider.toggleAttendance();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              attendanceProvider.isPunchedIn
                                  ? 'Successfully checked in!'
                                  : 'Successfully checked out!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        double distance = await LocationService.getCurrentDistance();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You must be within 50 meters of the location to check in/out. '
                              'Current distance: ${distance.toStringAsFixed(1)} meters',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      await _updateDistance();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    attendanceProvider.isPunchedIn ? 'Check Out' : 'Check In',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateDistance,
                  child: Text('Refresh Distance'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}