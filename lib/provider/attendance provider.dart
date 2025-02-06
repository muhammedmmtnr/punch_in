import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AttendanceProvider with ChangeNotifier {
  bool _isPunchedIn = false;
  static const String PREF_KEY = 'isPunchedIn';

  bool get isPunchedIn => _isPunchedIn;

  AttendanceProvider() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    _isPunchedIn = prefs.getBool(PREF_KEY) ?? false;
    notifyListeners();
  }

  Future<void> toggleAttendance() async {
    _isPunchedIn = !_isPunchedIn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PREF_KEY, _isPunchedIn);
    notifyListeners();
  }
}