import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch_in/provider/attendance%20provider.dart';
import 'package:punch_in/services/loaction_service.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLocationReady = false;
  String _locationInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await LocationService.initializeLocation();
      final position = await LocationService.getPosition();
      final address = await LocationService.getAddress();
      
      if (position != null && mounted) {
        setState(() {
          _locationInfo = 'Latitude: ${position.latitude.toStringAsFixed(6)}\n'
                         'Longitude: ${position.longitude.toStringAsFixed(6)}\n'
                         'Address: $address';
          _isLocationReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _initializeLocation,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance System'),
      ),
      body: !_isLocationReady
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Fetching location...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: _initializeLocation,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : Center(
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
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            bool isInRange = await LocationService.isWithinRange();
                            if (isInRange) {
                              await attendanceProvider.toggleAttendance();
                              if (mounted) {
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
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'You must be within ${LocationService.RADIUS_METERS} meters of the location to check in/out',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
                    ],
                  );
                },
              ),
            ),
    );
  }
}